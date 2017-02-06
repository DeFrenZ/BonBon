import XCTest
@testable import BonBon

final class LockTests: XCTestCase {
	var locks: [Lock]!
	var concurrentLocks: [ConcurrentLock]!
	var queue: DispatchQueue!
	var group: DispatchGroup!
	override func setUp() {
		super.setUp()

		let mutex = MutexLock()
		let readWrite = ReadWriteLock()
		locks = [mutex, readWrite]
		concurrentLocks = [readWrite]
		queue = DispatchQueue(label: "\(invocation!.selector)", attributes: .concurrent)
		group = DispatchGroup()
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
}
