import XCTest
import BonBon

final class BoxTests: XCTestCase {
	// MARK: Setup

	private var value: Int = 1
	private var anotherValue: Int = 2

	// MARK: Unit tests

	func test_whenCreatingAnImmutableBoxWithAValue_itWrapsThatValue() {
		let box = ImmutableBox(wrapping: value)
		XCTAssertEqual(box.value, value, "The wrapped value should be the initializer one.")
	}

	func test_whenCreatingAMutableBoxWithAValue_itWrapsThatValue() {
		let box = MutableBox(wrapping: value)
		XCTAssertEqual(box.value, value, "The wrapped value should be the initializer one.")
	}

	func test_whenSettingANewWrappedValueToAMutableBox_itWrapsTheNewValue() {
		let box = MutableBox(wrapping: value)
		box.value = anotherValue
		XCTAssertEqual(box.value, anotherValue, "The wrapped value should be the set one.")
	}
}
