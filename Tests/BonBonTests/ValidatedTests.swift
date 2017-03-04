import XCTest
import BonBon

final class ValidatedTests: XCTestCase {
	// MARK: Setup

	private enum NumberValidationError: Error {
		case isNegative
	}
	private var validValue: Int = 1
	private var anotherValidValue: Int = 3
	private var invalidValue: Int = -1
	private var validator: (Int) throws -> Void = {
		guard $0 >= 0 else { throw NumberValidationError.isNegative }
	}
	private lazy var validated: Validated<Int> = try! Validated(value: self.validValue, validator: self.validator)

	// MARK: Unit tests
	
	func test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds() {
		let validated = try? Validated(value: validValue, validator: validator)
		XCTAssertNotNil(validated)
	}

	func test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails() {
		let validated = try? Validated(value: invalidValue, validator: validator)
		XCTAssertNil(validated)
	}

	func test_whenCreatingAValidatedValue_andTheValidationPasses_thenItHasTheSameValue() {
		let validated = try? Validated(value: validValue, validator: validator)
		XCTAssertEqual(validated?.value, validValue)
	}

	func test_whenSettingANewValue_andTheValidationPasses_thenItHasTheNewValue() {
		var validated = self.validated
		try? validated.set(to: anotherValidValue)
		XCTAssertEqual(validated.value, anotherValidValue)
	}

	func test_whenSettingANewValue_andTheValidationFails_thenItKeepsTheOldValue() {
		var validated = self.validated
		try? validated.set(to: invalidValue)
		XCTAssertEqual(validated.value, validValue)
	}

	// MARK: Linux support

	static var allTests: [(String, (ValidatedTests) -> () throws -> Void)] {
		return [
			("test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds", test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds),
			("test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails", test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails),
			("test_whenCreatingAValidatedValue_andTheValidationPasses_thenItHasTheSameValue", test_whenCreatingAValidatedValue_andTheValidationPasses_thenItHasTheSameValue),
			("test_whenSettingANewValue_andTheValidationPasses_thenItHasTheNewValue", test_whenSettingANewValue_andTheValidationPasses_thenItHasTheNewValue),
			("test_whenSettingANewValue_andTheValidationFails_thenItKeepsTheOldValue", test_whenSettingANewValue_andTheValidationFails_thenItKeepsTheOldValue),
		]
	}
}
