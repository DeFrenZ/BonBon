import XCTest
import BonBon

final class SynchronizedTests: AsynchronousTestCase {
	var syncNumber: Synchronized<Int>!
	override func setUp() {
		super.setUp()
		syncNumber = Synchronized(0)
	}

	func test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes() {
		queue.async {
			self.syncNumber.atomicallyUpdate {
				sleep(for: shortWaitLimit)
				$0 += 1
			}
		}

		sleep(for: shortWait)
		XCTAssertEqual(syncNumber.value, 1)
	}
}
