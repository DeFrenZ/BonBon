import XCTest
import BonBon

final class ValidatedTests: XCTestCase {
	// MARK: Setup

	private var validValue: Int = 1
	private var anotherValidValue: Int = 3
	private var invalidValue: Int = -1
	private var validator: (Int) throws -> Void = {
		guard $0 >= 0 else { throw NumberValidationError.isNegative }
	}
	private var predicate: (Int) -> Bool = { $0 >= 0 }
	private var sequence: [Int] = [0, 1, 2, 3, 4]
	private var halfOpenRange: Range<Int> = 0 ..< 5
	private var closedRange: ClosedRange<Int> = 0 ... 4
	private lazy var validated: Validated<Int> = try! Validated(value: self.validValue, validator: self.validator)

	// MARK: Unit tests
	
	func test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue() {
		assertCreationSucceedsWithSameValue(try Validated(value: validValue, validator: validator))
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

	func test_whenCreatingAValidatedValueWithAPredicate_andThePredicatePasses_thenItSucceeds_andItHasTheSameValue() {
		assertCreationSucceedsWithSameValue(try Validated(value: validValue, predicate: predicate))
	}

	func test_whenCreatingAValidatedValueWithAPredicate_andThePredicateFails_thenItFails() {
		tryAndAssertThrowsValidationError(try Validated(value: invalidValue, predicate: predicate))
	}

	func test_whenCreatingAValidatedValueWithASequence_andTheSequenceContainsTheValue_thenItSucceeds_andItHasTheSameValue() {
		assertCreationSucceedsWithSameValue(try Validated(value: validValue, validValues: sequence))
	}

	func test_whenCreatingAValidatedValueWithASequence_andTheSequenceDoesntContainTheValue_thenItFails() {
		tryAndAssertThrowsValidationError(try Validated(value: invalidValue, validValues: sequence))
	}

	func test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue() {
		assertCreationSucceedsWithSameValue(try Validated(value: validValue, validRange: halfOpenRange))
	}

	func test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeDoesntContainTheValue_thenItFails() {
		tryAndAssertThrowsValidationError(try Validated(value: invalidValue, validRange: halfOpenRange))
	}

	func test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue() {
		assertCreationSucceedsWithSameValue(try Validated(value: validValue, validRange: closedRange))
	}

	func test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeDoesntContainTheValue_thenItFails() {
		tryAndAssertThrowsValidationError(try Validated(value: invalidValue, validRange: closedRange))
	}

	// MARK: - Private utilities

	private enum NumberValidationError: Error {
		case isNegative
	}

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

	private func assertCreationSucceedsWithSameValue(_ function: @autoclosure () throws -> Validated<Int>, file: StaticString = #file, line: UInt = #line) {
		let validated = tryAndAssertDoesntThrow(try function())
		XCTAssertEqual(validated?.value, validValue, "The object should have the same value.")
	}

	// MARK: Linux support

	static var allTests: [(String, (ValidatedTests) -> () throws -> Void)] {
		return [
			("test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValue_andTheValidationPasses_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails", test_whenCreatingAValidatedValue_andTheValidationFails_thenItFails),
			("test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue", test_whenSettingANewValue_andTheValidationPasses_thenItSucceeds_andItHasTheNewValue),
			("test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue", test_whenSettingANewValue_andTheValidationFails_thenItFails_andItKeepsTheOldValue),
			("test_whenCreatingAValidatedValueWithAPredicate_andThePredicatePasses_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValueWithAPredicate_andThePredicatePasses_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValueWithAPredicate_andThePredicateFails_thenItFails", test_whenCreatingAValidatedValueWithAPredicate_andThePredicateFails_thenItFails),
			("test_whenCreatingAValidatedValueWithASequence_andTheSequenceContainsTheValue_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValueWithASequence_andTheSequenceContainsTheValue_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValueWithASequence_andTheSequenceDoesntContainTheValue_thenItFails", test_whenCreatingAValidatedValueWithASequence_andTheSequenceDoesntContainTheValue_thenItFails),
			("test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeDoesntContainTheValue_thenItFails", test_whenCreatingAValidatedValueWithAnHalfOpenRange_andTheRangeDoesntContainTheValue_thenItFails),
			("test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue", test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeContainsTheValue_thenItSucceeds_andItHasTheSameValue),
			("test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeDoesntContainTheValue_thenItFails", test_whenCreatingAValidatedValueWithAClosedRange_andTheRangeDoesntContainTheValue_thenItFails),
		]
	}
}
