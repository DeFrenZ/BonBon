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
	
	func test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue() {
		do {
			let validated = try Validated(value: validValue, validator: validator)
			XCTAssertEqual(validated.value, validValue)
		} catch {
			XCTFail()
		}
	}

	func test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails() {
		do {
			_ = try Validated(value: invalidValue, validator: validator)
			XCTFail()
		} catch is ValidationError<Int> {
		} catch {
			XCTFail()
		}
	}

	func test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue() {
		var validated = self.validated
		do {
			try validated.set(to: anotherValidValue)
		} catch {
			XCTFail()
		}
		XCTAssertEqual(validated.value, anotherValidValue)
	}

	func test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue() {
		var validated = self.validated
		do {
			try validated.set(to: invalidValue)
			XCTFail()
		} catch is ValidationError<Int> {
			XCTAssertEqual(validated.value, validValue)
		} catch {
			XCTFail()
		}
	}

	// MARK: Linux support

	static var allTests: [(String, (ValidatedTests) -> () throws -> Void)] {
		return [
			("test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails", test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails),
			("test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue", test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue),
			("test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue", test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue),
		]
	}
}
