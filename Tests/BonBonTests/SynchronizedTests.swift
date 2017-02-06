import XCTest
import BonBon

final class SynchronizedTests: XCTestCase {
	var syncNumber: Synchronized<Int>!
	var queue: DispatchQueue!
	override func setUp() {
		super.setUp()

		syncNumber = Synchronized(0)
		queue = DispatchQueue(label: "\(invocation!.selector)", attributes: .concurrent)
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
