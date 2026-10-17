import 'package:isolate_demo/models/worker_message.dart';
import 'package:isolate_demo/models/task_result.dart';
import 'package:isolate_demo/models/parse_summary.dart';
import 'package:isolate_demo/services/json_parser.dart';

import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/services/processing.dart';

void exitEarly(WorkerRequest _) {}

void crash(WorkerRequest _) => throw StateError('intentional test crash');

void waitForever(WorkerRequest _) {
  ReceivePort().listen((_) {});
}

void progressThenWait(WorkerRequest request) {
  request.reply.send(const WorkerProgress(1, 10));
  ReceivePort().listen((_) {});
}

ParseResult programmingFailure(String _) => throw StateError('parser bug');

ParseResult typeFailure(String _) {
  final dynamic value = 'not an int';
  return ParseResult(ParseSummary(count: value as int, totalAmount: 0), 0);
}

void caughtProgrammingFailure(WorkerRequest request) =>
    sendWorkerResult(request, programmingFailure);

void caughtTypeFailure(WorkerRequest request) =>
    sendWorkerResult(request, typeFailure);

String records(int count, int amount) =>
    '[${List.filled(count, '{"amount":$amount}').join(',')}]';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'caught programming and type errors retain type and remote stack',
    () async {
      for (final entry in [caughtProgrammingFailure, caughtTypeFailure]) {
        try {
          await SpawnJob(entryPoint: entry).run('[]');
          fail('Expected remote failure');
        } on RemoteWorkerException catch (error, stack) {
          expect(
            error.errorType,
            entry == caughtProgrammingFailure
                ? 'StateError'
                : contains('TypeError'),
          );
          expect(
            stack.toString(),
            contains(
              entry == caughtProgrammingFailure
                  ? 'programmingFailure'
                  : 'typeFailure',
            ),
          );
        }
      }
      // A later job still succeeds after failed workers have been cleaned up.
      expect(
        (await SpawnJob().run('[]')).summary,
        const ParseSummary(count: 0, totalAmount: 0),
      );
    },
  );

  test('data error keeps its remote stack', () async {
    try {
      await SpawnJob().run('[{"amount":true}]');
      fail('Expected data failure');
    } on FormatException catch (error, stack) {
      expect(error.message, contains('amount'));
      expect(stack.toString(), contains('parseAndSummarize'));
    }
  });

  test('three native modes return equivalent summaries', () async {
    for (final input in ['[]', '[{"amount":-1},{"amount":21}]']) {
      for (final mode in ProcessingMode.values) {
        final result = await processJson(mode, input);
        expect(
          result.summary,
          input == '[]'
              ? const ParseSummary(count: 0, totalAmount: 0)
              : const ParseSummary(count: 2, totalAmount: 20),
        );
        expect(result.elapsedMs, greaterThanOrEqualTo(result.parseMs));
      }
    }
  });

  test('all modes propagate malformed JSON and schema failures', () async {
    for (final mode in ProcessingMode.values) {
      for (final input in ['[', '{}', '[{"amount":"3"}]']) {
        await expectLater(processJson(mode, input), throwsFormatException);
      }
    }
  });

  test('exit without result and uncaught error cannot hang', () async {
    await expectLater(
      SpawnJob(entryPoint: exitEarly).run('[]'),
      throwsStateError,
    );
    await expectLater(
      SpawnJob(entryPoint: crash).run('[]'),
      throwsA(isA<RemoteWorkerException>()),
    );
  });

  test('timeout kills waiting worker and rejects reuse', () async {
    final job = SpawnJob(
      entryPoint: waitForever,
      timeout: const Duration(milliseconds: 100),
    );
    await expectLater(job.run('[]'), throwsA(isA<TimeoutException>()));
    await expectLater(job.run('[]'), throwsStateError);
  });

  test(
    'dispose/cancel during spawn settles future and cleanup is idempotent',
    () async {
      final job = SpawnJob(entryPoint: waitForever);
      final future = job.run('[]');
      final expectation = expectLater(future, throwsA(isA<WorkerCancelled>()));
      job.cancel();
      job.cancel();
      await expectation;
      // Cho future Isolate.spawn hoàn tất sau cancel để thử nhánh late cleanup.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    },
  );

  test('parser reports increasing progress and ends at done == total', () {
    final calls = <(int, int)>[];
    parseAndSummarize(records(25, 1), onProgress: (d, t) => calls.add((d, t)));
    final done = calls.map((c) => c.$1).toList();
    expect(calls.last, (25, 25));
    expect(done, orderedEquals([...done]..sort()));
    expect(calls.length, lessThanOrEqualTo(11));
  });

  test('spawn sends progress through the port before the result', () async {
    final seen = <double>[];
    final result = await SpawnJob(onProgress: seen.add).run(records(40, 2));
    expect(result.summary, const ParseSummary(count: 40, totalAmount: 80));
    expect(seen, isNotEmpty);
    expect(seen, orderedEquals([...seen]..sort()));
    expect(seen.last, 1.0);
  });

  test('cancel after the first progress message kills the worker', () async {
    late final SpawnJob job;
    job = SpawnJob(
      entryPoint: progressThenWait,
      onProgress: (_) => job.cancel(),
    );
    await expectLater(job.run('[]'), throwsA(isA<WorkerCancelled>()));
  });
}
