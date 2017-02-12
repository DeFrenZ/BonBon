/// A wrapper around the result of an operation. It either holds a successful
/// result of the declared type, or an error that occurred in executing it.
/// This implementation opted for non-strongly typed errors as it works better
/// together with the existing Swift error handling.
///	- seealso: [Result Type](https://en.wikipedia.org/wiki/Result_type)
public enum Result<Value> {
	/// The value returned from a successful execution.
	case success(Value)
	/// A thrown error from a failed execution.
	case failure(Error)
}

// MARK: - Interoperation with `Optional`s

/// A convenience error to use when something went wrong, but no information
/// about the failure is available.
public struct UnknownError: Error {}

extension Result {
	/// A conveniece initializer for converting a couple of `Optional`s to a
	/// `Result`. Only one of the two given `Optional`s should be `.some`, but
	/// the other cases are handled sensibly as well.
	///
	///	- parameter value: The optional value.
	///	- parameter error: The optional error.
	///	- returns: `.success` or `.failure` as expected in the cases where
	///		exactly one of the two `Optional`s is `.some`, a `.success` when
	///		both are `.some` and a `.failure` with an `UnknownError` when both
	///		are `.none`.
	public init(value: Value?, error: Error?) {
		switch (value, error) {
		case (let value?, _): self = .success(value)
		case (nil, let error?): self = .failure(error)
		case (nil, nil): self = .failure(UnknownError())
		}
	}

	/// A convenience property for getting the successful value as an
	/// `Optional`. It returns the value on `.success`, `nil` on `.failure`.
	public var value: Value? {
		switch self {
		case .success(let value): return value
		case .failure: return nil
		}
	}

	/// A convenience property for getting the thrown error as an `Optional`. It
	/// returns the error on `.failure`, `nil` on `.success`.
	public var error: Error? {
		switch self {
		case .success: return nil
		case .failure(let error): return error
		}
	}
}
