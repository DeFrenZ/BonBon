import XCTest
import BonBon

final class ObservableTests: XCTestCase {
	// MARK: Setup

	private var observableNumber: Observable<Int> = .init(0)
	private var expectedUpdate: (Int, Int)?
	private var expectedMappedUpdate: (String, String)?

	// MARK: Unit tests

	func test_whenObservableUpdates_thenItNotifiesObservers() {
		observableNumber.subscribe(self, onUpdate: { self.expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == (0, 1), "The update block should've been triggered.")
	}

	func test_whenObservableUpdates_andValueIsChanged_thenItNotifiesChangeObservers() {
		observableNumber.subscribe(self, onChange: { self.expectedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedUpdate! == (0, 1), "The update block should've been triggered.")
	}

	func test_whenObservableUpdates_andValueIsntChanged_thenItDoesntNotifyChangeObservers() {
		observableNumber.subscribe(self, onChange: { self.expectedUpdate = $0 })
		observableNumber.value = 0
		XCTAssertNil(expectedUpdate, "The update block shouldn't have been triggered.")
	}

	func test_whenObservableUpdates_andAnObserverIsUnsubscribed_thenItDoesntNotifyIt() {
		observableNumber.subscribe(self, onUpdate: { self.expectedUpdate = $0 })
		observableNumber.unsubscribe(self)
		observableNumber.value = 1
		XCTAssertNil(expectedUpdate, "The update block shouldn't have been triggered.")
	}

	func test_whenObservableUpdates_andAnObserverGotReleased_thenItDoesntNotifyIt() {
		do {
			let observer = SubscriptionOwner()
			observableNumber.subscribe(observer, onUpdate: { self.expectedUpdate = $0 })
		}
		observableNumber.value = 1
		XCTAssertNil(expectedUpdate, "The update block shouldn't have been triggered.")
	}

	func test_whenObservableUpdates_andItsMappedToAnother_thenTheOtherNotifiesObservers() {
		let observableString = observableNumber.map(String.init)
		observableString.subscribe(self, onUpdate: { self.expectedMappedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedMappedUpdate! == ("0", "1"), "The update block shouldn't have been triggered.")
	}

	func test_whenObservableUpdates_andItsFlatMappedToAnother_thenTheOtherNotifiesObservers() {
		let observableString = observableNumber.flatMap({ Observable(String($0)) })
		observableString.subscribe(self, onUpdate: { self.expectedMappedUpdate = $0 })
		observableNumber.value = 1
		XCTAssert(expectedMappedUpdate! == ("0", "1"), "The update block shouldn't have been triggered.")
	}

	// MARK: Linux support

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
