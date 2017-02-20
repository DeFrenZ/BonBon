import XCTest
@testable import BonBon

final class LockTests: AsynchronousTestCase {
	// MARK: Setup

	private static let numberOfConcurrentTasks = 1000
	private static let numberOfRunsInPerformanceTest = 100_000

	private var locks: [Lock]!
	private var unbalancedLocks: [UnbalancedLock]!
	private var concurrentLocks: [ConcurrentLock]!
	private var concurrentUnbalancedLocks: [ConcurrentUnbalancedLock]!

	override func setUp() {
		super.setUp()

		locks = [
			MutexLock(),
			ReadWriteLock(),
			SemaphoreLock(),
			QueueLock(),
		]
		if #available(OSX 10.12, *) {
			locks.append(UnfairLock())
		}

		unbalancedLocks = locks.flatMap({ $0 as? UnbalancedLock })
		concurrentLocks = locks.flatMap({ $0 as? ConcurrentLock })
		concurrentUnbalancedLocks = locks.flatMap({ $0 as? ConcurrentUnbalancedLock })
	}

	// MARK: Unit tests

	func test_whenNonConcurrentAccessesAreRequestedAtTheSameTime_thenOnlyOneAtATimeExecutes() {
		for lock in locks {
			var number = 0
			queue.async {
				lock.sync {
					sleep(for: shortWaitLimit)
					number += 1
				}
			}

			sleep(for: shortWait)
			lock.sync {
				XCTAssertEqual(number, 1, "The second access should wait for the first one to complete.")
			}
		}
	}

	func test_whenManyNonConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteSequentially() {
		for lock in locks {
			var number = 0
			for _ in 0 ..< LockTests.numberOfConcurrentTasks {
				queue.async(group: group) {
					lock.sync {
						number += 1
					}
				}
			}
			group.wait()
			lock.sync {
				XCTAssertEqual(number, LockTests.numberOfConcurrentTasks, "All accesses should have completed sequentially.")
			}
		}
	}

	func test_whenConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteTogether() {
		for lock in concurrentLocks {
			for _ in 0 ..< LockTests.numberOfConcurrentTasks {
				queue.async(group: group) {
					lock.concurrentSync {
						sleep(for: shortWait)
					}
				}
			}
			guard group.wait(for: shortWaitLimit) == .success else {
				return XCTFail("Concurrent accesses should complete within the given time.")
			}
		}
	}

	// MARK: Performance tests
	//	- note: Performance isn't currently the best, but for the sake of
	//		natural-looking APIs and having a ready-to-use utility, it is kept
	//		as-is. With smarter capturing and inlining ~10x performance can be
	//		reached, if really needed.
	//	- seealso: [Cocoa With Love: Mutexes and closure capture in Swift]
	//		(https://www.cocoawithlove.com/blog/2016/06/02/threads-and-mutexes.html)

	func test_whenUsingAMutexLock_thenPerformanceDoesntRegress() {
		measureLockPerformance(MutexLock())
	}

	func test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress() {
		measureLockPerformance(ReadWriteLock())
	}

	func test_whenUsingASemaphoreLock_thenPerformanceDoesntRegress() {
		measureLockPerformance(SemaphoreLock())
	}

	func test_whenUsingAQueueLock_thenPerformanceDoesntRegress() {
		measureLockPerformance(QueueLock())
	}

	@available(OSX 10.12, *)
	func test_whenUsingAnUnfairLock_thenPerformanceDoesntRegress() {
		measureLockPerformance(UnfairLock())
	}

	func test_whenUsingAReadWriteLock_andAccessingConcurrently_thenPerformanceDoesntRegress() {
		measureConcurrentLockPerformance(ReadWriteLock())
	}

	func test_whenUsingAQueueLock_andAccessingConcurrently_thenPerformanceDoesntRegress() {
		measureConcurrentLockPerformance(QueueLock())
	}

	// MARK: Private utilities

	private func measureLockPerformance(_ lock: Lock) {
		measure(times: LockTests.numberOfRunsInPerformanceTest) { lock.sync {} }
	}

	private func measureConcurrentLockPerformance(_ lock: ConcurrentLock) {
		measure(times: LockTests.numberOfRunsInPerformanceTest) { lock.concurrentSync {} }
	}

	// MARK: Linux support

	static var allTests: [(String, (LockTests) -> () throws -> Void)] {
		return [
			("test_whenNonConcurrentAccessesAreRequestedAtTheSameTime_thenOnlyOneAtATimeExecutes", test_whenNonConcurrentAccessesAreRequestedAtTheSameTime_thenOnlyOneAtATimeExecutes),
			("test_whenConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteTogether", test_whenConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteTogether),
			("test_whenUsingAMutexLock_thenPerformanceDoesntRegress", test_whenUsingAMutexLock_thenPerformanceDoesntRegress),
			("test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress", test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress),
			("test_whenUsingASemaphoreLock_thenPerformanceDoesntRegress", test_whenUsingASemaphoreLock_thenPerformanceDoesntRegress),
			("test_whenUsingAQueueLock_thenPerformanceDoesntRegress", test_whenUsingAQueueLock_thenPerformanceDoesntRegress),
			("test_whenUsingAReadWriteLock_andAccessingConcurrently_thenPerformanceDoesntRegress", test_whenUsingAReadWriteLock_andAccessingConcurrently_thenPerformanceDoesntRegress),
			("test_whenUsingAQueueLock_andAccessingConcurrently_thenPerformanceDoesntRegress", test_whenUsingAQueueLock_andAccessingConcurrently_thenPerformanceDoesntRegress),
		]
	}
}
