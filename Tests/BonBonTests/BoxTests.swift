import XCTest
import BonBon

final class BoxTests: XCTestCase {
	// MARK: Setup

	private var value: Int = 1
	private var anotherValue: Int = 2
	private lazy var box: ImmutableBox<Int> = .init(wrapping: self.value)
	private var mapValue: String = "1"

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

	func test_whenCopyingABox_theCopyWrapsTheSameValue() {
		let copy = box.copy()
		XCTAssertEqual(copy.value, box.value, "The wrapped value of the copy should be the same as from the original.")
	}

	func test_whenMutableCopyingABox_theCopyWrapsTheSameValue() {
		let copy = box.mutableCopy()
		XCTAssertEqual(copy.value, box.value, "The wrapped value of the copy should be the same as from the original.")
	}

	func test_whenMappingABox_theResultWrapsTheExpectedValue() {
		let mapped = box.map(String.init)
		XCTAssertEqual(mapped.value, mapValue, "The wrapped value of the map result should be the expected one.")
	}

	func test_whenFlatMappingABox_theResultWrapsTheExpectedValue() {
		let mapped = box.flatMap({ ImmutableBox(wrapping: String($0)) })
		XCTAssertEqual(mapped.value, mapValue, "The wrapped value of the flatMap result should be the expected one.")
	}

	// MARK: Linux support

	static var allTests: [(String, (BoxTests) -> () throws -> Void)] {
		return [
			("test_whenCreatingAnImmutableBoxWithAValue_itWrapsThatValue", test_whenCreatingAnImmutableBoxWithAValue_itWrapsThatValue),
			("test_whenCreatingAMutableBoxWithAValue_itWrapsThatValue", test_whenCreatingAMutableBoxWithAValue_itWrapsThatValue),
			("test_whenSettingANewWrappedValueToAMutableBox_itWrapsTheNewValue", test_whenSettingANewWrappedValueToAMutableBox_itWrapsTheNewValue),
			("test_whenCopyingABox_theCopyWrapsTheSameValue", test_whenCopyingABox_theCopyWrapsTheSameValue),
			("test_whenMutableCopyingABox_theCopyWrapsTheSameValue", test_whenMutableCopyingABox_theCopyWrapsTheSameValue),
			("test_whenMappingABox_theResultWrapsTheExpectedValue", test_whenMappingABox_theResultWrapsTheExpectedValue),
			("test_whenFlatMappingABox_theResultWrapsTheExpectedValue", test_whenFlatMappingABox_theResultWrapsTheExpectedValue),
		]
	}
}
