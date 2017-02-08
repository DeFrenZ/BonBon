import XCTest
import BonBon

final class SynchronizedTests: AsynchronousTestCase {
	// MARK: Setup

	private var syncNumber: Synchronized<Int> = .init(0)

	// MARK: Unit tests

	func test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes() {
		increaseSynchronizedNumberSlowly()
		XCTAssertEqual(syncNumber.value, 1, "The second access should wait for the atomic update to complete.")
	}

	func test_whenSynchronizedIsBusy_andItsMapped_thenTheResultIsAppliedAfterItsFreed() {
		increaseSynchronizedNumberSlowly()
		let mapResult = syncNumber.map({ $0 + 1 })
		XCTAssertEqual(mapResult.value, 2, "The map should wait for the atomic update to complete.")
	}

	func test_whenSynchronizedIsBusy_andItsFlatMapped_thenTheResultIsAppliedAfterItsFreed() {
		increaseSynchronizedNumberSlowly()
		let mapResult = syncNumber.flatMap({ Synchronized($0 + 1) })
		XCTAssertEqual(mapResult.value, 2, "The flatMap should wait for the atomic update to complete.")
	}

	// MARK: Private utilities

	private func increaseSynchronizedNumberSlowly() {
		queue.async {
			self.syncNumber.atomicallyUpdate {
				sleep(for: shortWaitLimit)
				$0 += 1
			}
		}
		sleep(for: shortWait)
	}

	// MARK: Linux support

	static var allTests: [(String, (SynchronizedTests) -> () throws -> Void)] {
		return [
			("test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes", test_whenSynchronizedAccessesArePerformedConcurrently_thenOnlyOneAtATimeExecutes),
			("test_whenSynchronizedIsBusy_andItsMapped_thenTheResultIsAppliedAfterItsFreed", test_whenSynchronizedIsBusy_andItsMapped_thenTheResultIsAppliedAfterItsFreed),
			("test_whenSynchronizedIsBusy_andItsFlatMapped_thenTheResultIsAppliedAfterItsFreed", test_whenSynchronizedIsBusy_andItsFlatMapped_thenTheResultIsAppliedAfterItsFreed),
		]
	}
}
