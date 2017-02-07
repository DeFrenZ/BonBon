import XCTest
import BonBon

final class SynchronizedTests: AsynchronousTestCase {
	// MARK: Setup

	private var syncNumber: Synchronized<Int> = .init(0)

	// MARK: Unit tests

	func test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes() {
		queue.async {
			self.syncNumber.atomicallyUpdate {
				sleep(for: shortWaitLimit)
				$0 += 1
			}
		}

		sleep(for: shortWait)
		XCTAssertEqual(syncNumber.value, 1, "The second access should wait for the atomic update to complete.")
	}

	// MARK: Linux support

	static var allTests: [(String, (SynchronizedTests) -> () throws -> Void)] {
		return [
			("test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes", test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes),
		]
	}
}
