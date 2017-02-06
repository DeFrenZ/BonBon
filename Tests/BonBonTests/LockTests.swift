import XCTest
@testable import BonBon

final class LockTests: AsynchronousTestCase {
	// MARK: Setup

	private static let numberOfConcurrentTasks = 1000
	private static let numberOfRunsInPerformanceTest = 100_000

	private var mutex: MutexLock!
	private var readWrite: ReadWriteLock!
	private var locks: [Lock]!
	private var concurrentLocks: [ConcurrentLock]!

	override func setUp() {
		super.setUp()

		mutex = MutexLock()
		readWrite = ReadWriteLock()
		locks = [mutex, readWrite]
		concurrentLocks = [readWrite]
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
				XCTFail("Concurrent accesses should complete within the given time.")
				return
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
		measure(times: LockTests.numberOfRunsInPerformanceTest) {
			self.mutex.sync {}
		}
	}

	func test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress() {
		measure(times: LockTests.numberOfRunsInPerformanceTest) {
			self.readWrite.sync {}
		}
	}

	func test_whenUsingAConcurrentLock_andAccessingConcurrently_thenPerformanceDoesntRegress() {
		measure(times: LockTests.numberOfRunsInPerformanceTest) {
			self.readWrite.concurrentSync {}
		}
	}

	// MARK: Linux support

	static var allTests: [(String, (LockTests) -> () throws -> Void)] {
		return [
			("test_whenNonConcurrentAccessesAreRequestedAtTheSameTime_thenOnlyOneAtATimeExecutes", test_whenNonConcurrentAccessesAreRequestedAtTheSameTime_thenOnlyOneAtATimeExecutes),
			("test_whenConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteTogether", test_whenConcurrentAccessesAreRequestedAtTheSameTime_thenAllExecuteTogether),
			("test_whenUsingAMutexLock_thenPerformanceDoesntRegress", test_whenUsingAMutexLock_thenPerformanceDoesntRegress),
			("test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress", test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress),
			("test_whenUsingAConcurrentLock_andAccessingConcurrently_thenPerformanceDoesntRegress", test_whenUsingAConcurrentLock_andAccessingConcurrently_thenPerformanceDoesntRegress),
		]
	}
}
