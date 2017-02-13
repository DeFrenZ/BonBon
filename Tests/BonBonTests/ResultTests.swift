import XCTest
import BonBon

final class ResultTests: XCTestCase {
	// MARK: Setup

	private var value: Int = 1
	private var error: TestError = .init(code: 42)
	
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
}
