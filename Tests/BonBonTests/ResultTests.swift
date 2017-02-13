import XCTest
import BonBon

final class ResultTests: XCTestCase {
	// MARK: Setup

	private var value: Int = 1
	private var error: TestError = .init(code: 42)
	private lazy var successResult: Result<Int> = .success(self.value)
	private lazy var failureResult: Result<Int> = .failure(self.error)
	private var mapValue: String = "1"
	private var mapError: TestError = .init(code: 88)
	
	// MARK: Unit tests

	func test_whenInitializingWithSomeValueAndNilError_thenItsASuccessWrappingTheValue() {
		let result = Result(value: value, error: nil)
		assertIsSuccessWithSetupValue(result)
	}

	func test_whenInitializingWithNilValueAndSomeError_thenItsAFailureWrappingTheError() {
		let result = Result<Int>(value: nil, error: error)
		assertIsFailureWithSetupError(result)
	}

	func test_whenInitializingWithSomeValueAndSomeError_thenItsASuccessWrappingTheValue() {
		let result = Result(value: value, error: error, allowInconsistentArguments: true)
		assertIsSuccessWithSetupValue(result)
	}

	func test_whenInitializingWithNilValueAndNilError_thenItsAFailure() {
		let result = Result<Int>(value: nil, error: nil, allowInconsistentArguments: true)
		if case .success = result {
			XCTFail("It should be a `failure`.")
		}
	}

	func test_whenHavingASuccess_thenValueIsTheWrappedOne() {
		assertIsSetupValue(successResult.value)
	}

	func test_whenHavingAFailure_thenValueIsNil() {
		XCTAssertEqual(failureResult.value, nil, "The wrapped value should be nil.")
	}

	func test_whenHavingASuccess_thenErrorIsNil() {
		XCTAssert(successResult.error == nil, "The wrapped error should be nil.")
	}

	func test_whenHavingAFailure_thenErrorIsTheWrappedOne() {
		assertIsSetupError(failureResult.error)
	}

	func test_whenInitializingWithSuccessfulOperation_thenItsASuccess() {
		let operation = { self.value }
		let result = Result(operation)
		assertIsSuccessWithSetupValue(result)
	}

	func test_whenInitializingWithFailingOperation_thenItsAFailure() {
		let operation = { () -> Int in throw self.error }
		let result = Result(operation)
		assertIsFailureWithSetupError(result)
	}

	func test_whenUnwrappingASuccess_thenItReturnsTheWrappedValue() {
		do {
			assertIsSetupValue(try successResult.unwrap())
		} catch {
			XCTFail("The unwrap shouldn't throw.")
		}
	}

	func test_whenUnwrappingAFailure_thenItThrowsTheWrappedError() {
		do {
			_ = try failureResult.unwrap()
			XCTFail("The unwrap should throw.")
		} catch let error {
			assertIsSetupError(error)
		}
	}

	func test_whenMappingASuccess_thenItReturnsTheValueTransformed() {
		let result = successResult.map({ _ in self.mapValue })
		assertIsSuccessWithMapValue(result)
	}

	func test_whenMappingAFailure_thenItReturnsTheSameErrorAsBefore() {
		let result = failureResult.map({ _ in self.mapValue })
		assertIsFailureWithSetupError(result)
	}

	func test_whenFlatMappingASuccess_andTheTransformSucceeds_thenItReturnsTheValueTransformed() {
		let result = successResult.flatMap({ _ in .success(self.mapValue) })
		assertIsSuccessWithMapValue(result)
	}

	func test_whenFlatMappingASuccess_andTheTransformFails_thenItReturnsTheTransformError() {
		let result = successResult.flatMap({ _ -> Result<String> in .failure(self.mapError) })
		assertIsFailureWithMapError(result)
	}

	func test_whenFlatMappingAFailure_andTheTransformSucceeds_thenItReturnsTheSameErrorAsBefore() {
		let result = failureResult.flatMap({ _ in .success(self.mapValue) })
		assertIsFailureWithSetupError(result)
	}

	func test_whenFlatMappingAFailure_andTheTransformFails_thenItReturnsTheSameErrorAsBefore() {
		let result = failureResult.flatMap({ _ -> Result<String> in .failure(self.mapError) })
		assertIsFailureWithSetupError(result)
	}

	// MARK: - Private utilities

	private struct TestError: Error, Equatable {
		var code: Int = 0
		static func == (lhs: TestError, rhs: TestError) -> Bool {
			return lhs.code == rhs.code
		}
	}

	func assertIsSetupValue(_ value: Int?, file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(value, self.value, "The value should be the setup value.", file: file, line: line)
	}

	func assertIsSetupError(_ error: Error?, file: StaticString = #file, line: UInt = #line) {
		if let error = error as? TestError, error == self.error {} else {
			XCTFail("The error should be the setup error.", file: file, line: line)
		}
	}

	func assertIsMapValue(_ value: String?, file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(value, self.mapValue, "The value should be the map value.", file: file, line: line)
	}

	func assertIsMapError(_ error: Error?, file: StaticString = #file, line: UInt = #line) {
		if let error = error as? TestError, error == self.mapError {} else {
			XCTFail("The error should be the map error.", file: file, line: line)
		}
	}

	func assertIsSuccessWithSetupValue(_ result: Result<Int>, file: StaticString = #file, line: UInt = #line) {
		if case .success(let value) = result {
			assertIsSetupValue(value, file: file, line: line)
		} else {
			XCTFail("The result should be a `success`.", file: file, line: line)
		}
	}

	func assertIsFailureWithSetupError <T> (_ result: Result<T>, file: StaticString = #file, line: UInt = #line) {
		if case .failure(let error) = result {
			assertIsSetupError(error, file: file, line: line)
		} else {
			XCTFail("The result should be a `failure`.", file: file, line: line)
		}
	}

	func assertIsSuccessWithMapValue(_ result: Result<String>, file: StaticString = #file, line: UInt = #line) {
		if case .success(let value) = result {
			assertIsMapValue(value, file: file, line: line)
		} else {
			XCTFail("The result should be a `success`.", file: file, line: line)
		}
	}

	func assertIsFailureWithMapError <T> (_ result: Result<T>, file: StaticString = #file, line: UInt = #line) {
		if case .failure(let error) = result {
			assertIsMapError(error, file: file, line: line)
		} else {
			XCTFail("The result should be a `failure`.", file: file, line: line)
		}
	}
}
