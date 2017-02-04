import XCTest
import BonBon

final class ObservableTests: XCTestCase {
	func test_whenObservableUpdates_thenItNotifiesObservers() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		observableNumber.subscribe(self, onUpdate: { expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == (0, 1))
	}

	func test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		observableNumber.subscribe(self, onChange: { expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == (0, 1))
	}

	func test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		observableNumber.subscribe(self, onChange: { expectedUpdate = $0 })
		observableNumber.value = 0
		XCTAssertNil(expectedUpdate)
	}

	func test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		observableNumber.subscribe(self, onUpdate: { expectedUpdate = $0 })
		observableNumber.unsubscribe(self)
		observableNumber.value = 1
		XCTAssertNil(expectedUpdate)
	}

	static var allTests: [(String, (ObservableTests) -> () throws -> Void)] {
		return [
			("test_whenObservableUpdates_thenItNotifiesObservers", test_whenObservableUpdates_thenItNotifiesObservers),
			("test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers", test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers),
			("test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers", test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers),
			("test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt", test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt),
		]
	}
}
