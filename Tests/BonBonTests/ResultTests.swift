import XCTest
import BonBon

final class ResultTests: XCTestCase {
	// MARK: Setup

	private var value: Int = 1
	private var error: TestError = .init(code: 42)
	
	// MARK: Unit tests

	func test_whenInitializingWithSomeValueAndNilError_thenItsASuccessWrappingTheValue() {
		let result = Result(value: value, error: nil)
		if case .success(let value) = result {
			XCTAssertEqual(value, self.value, "The wrapped value should be the given one.")
		} else {
			XCTFail("It should be a `success`.")
		}
	}

	func test_whenInitializingWithNilValueAndSomeError_thenItsAFailureWrappingTheError() {
		let result = Result<Int>(value: nil, error: error)
		if case .failure(let error) = result {
			if let error = error as? TestError, error == self.error {} else {
				XCTFail("The wrapped error should be the given one.")
			}
		} else {
			XCTFail("It should be a `failure`.")
		}
	}

	func test_whenInitializingWithSomeValueAndSomeError_thenItsASuccessWrappingTheValue() {
		let result = Result(value: value, error: error, allowInconsistentArguments: true)
		if case .success(let value) = result {
			XCTAssertEqual(value, self.value, "The wrapped value should be the given one.")
		} else {
			XCTFail("It should be a `success`.")
		}
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
}
