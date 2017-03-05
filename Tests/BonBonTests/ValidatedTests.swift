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
		let validated = tryAndAssertDoesntThrow(try Validated(value: validValue, validator: validator))
		XCTAssertEqual(validated?.value, validValue, "The object should have the same value.")
	}

	func test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails() {
		tryAndAssertThrowsValidationError(try Validated(value: invalidValue, validator: validator))
	}

	func test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue() {
		var validated = self.validated
		tryAndAssertDoesntThrow(try validated.set(to: anotherValidValue))
		XCTAssertEqual(validated.value, anotherValidValue, "The object should have the new value.")
	}

	func test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue() {
		var validated = self.validated
		tryAndAssertThrowsValidationError(try validated.set(to: invalidValue))
		XCTAssertEqual(validated.value, validValue, "The object should have the old value.")
	}

	// MARK: - Private utilities

	private func tryAndAssertDoesntThrow <T> (_ function: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) -> T? {
		do {
			return try function()
		} catch {
			XCTFail("The function shouldn't throw an error.", file: file, line: line)
			return nil
		}
	}

	private func tryAndAssertThrowsValidationError <T> (_ function: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) {
		do {
			_ = try function()
			XCTFail("The function should throw an error.", file: file, line: line)
		} catch is ValidationError<Int> {
		} catch {
			XCTFail("The function should throw a validation error, instead of \(error).", file: file, line: line)
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
