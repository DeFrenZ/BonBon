import XCTest
import BonBon

final class ObservableTests: XCTestCase {
	func testObserverReceivesUpdates() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		observableNumber.subscribe(onUpdate: { expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == (0, 1))
	}

	static var allTests: [(String, (ObservableTests) -> () throws -> Void)] {
		return [
			("testObserverReceivesUpdates", testObserverReceivesUpdates),
		]
	}
}
