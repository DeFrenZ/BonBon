import XCTest
@testable import BonBon

final class LockTests: AsynchronousTestCase {
	var mutex: MutexLock!
	var readWrite: ReadWriteLock!
	var locks: [Lock]!
	var concurrentLocks: [ConcurrentLock]!
	override func setUp() {
		super.setUp()

		mutex = MutexLock()
		readWrite = ReadWriteLock()
		locks = [mutex, readWrite]
		concurrentLocks = [readWrite]
	}

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
		let numberOfConcurrentTasks = 1000
		for lock in concurrentLocks {
			for _ in 0 ..< numberOfConcurrentTasks {
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

	func test_whenUsingAMutexLock_thenPerformanceDoesntRegress() {
		measure(times: numberOfRunsInPerformanceTest) {
			self.mutex.sync {}
		}
	}

	func test_whenUsingAReadWriteLock_thenPerformanceDoesntRegress() {
		measure(times: numberOfRunsInPerformanceTest) {
			self.readWrite.sync {}
		}
	}

	func test_whenUsingAConcurrentLock_andAccessingConcurrently_thenPerformanceDoesntRegress() {
		measure(times: numberOfRunsInPerformanceTest) {
			self.readWrite.concurrentSync {}
		}
	}
}

private let numberOfRunsInPerformanceTest = 1_000_000
