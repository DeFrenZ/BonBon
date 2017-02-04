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

	func test_whenObservableUpdates_andAnObserverGotReleased_thenItDoesntNotifyIt() {
		let observableNumber = Observable(0)
		var expectedUpdate: (Int, Int)?
		do {
			let observer = SubscriptionOwner()
			observableNumber.subscribe(observer, onUpdate: { expectedUpdate = $0 })
		}
		observableNumber.value = 1
		XCTAssertNil(expectedUpdate)
	}

	func test_whenObservableUpdates_andItsMappedToAnother_thenTheOtherNotifiesObservers() {
		let observableNumber = Observable(0)
		let observableString = observableNumber.map(String.init)
		var expectedUpdate: (String, String)?
		observableString.subscribe(self, onUpdate: { expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == ("0", "1"))
	}

	func test_whenObservableUpdates_andItsFlatMappedToAnother_thenTheOtherNotifiesObservers() {
		let observableNumber = Observable(0)
		let observableString = observableNumber.flatMap({ Observable(String($0)) })
		var expectedUpdate: (String, String)?
		observableString.subscribe(self, onUpdate: { expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == ("0", "1"))
	}

	static var allTests: [(String, (ObservableTests) -> () throws -> Void)] {
		return [
			("test_whenObservableUpdates_thenItNotifiesObservers", test_whenObservableUpdates_thenItNotifiesObservers),
			("test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers", test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers),
			("test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers", test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers),
			("test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt", test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt),
			("test_whenObservableUpdates_andAnObserverGotReleased_thenItDoesntNotifyIt", test_whenObservableUpdates_andAnObserverGotReleased_thenItDoesntNotifyIt),
			("test_whenObservableUpdates_andItsMappedToAnother_thenTheOtherNotifiesObservers", test_whenObservableUpdates_andItsMappedToAnother_thenTheOtherNotifiesObservers),
			("test_whenObservableUpdates_andItsFlatMappedToAnother_thenTheOtherNotifiesObservers", test_whenObservableUpdates_andItsFlatMappedToAnother_thenTheOtherNotifiesObservers),
		]
	}
}
