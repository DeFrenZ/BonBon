/// A wrapper to ensure that a value always passes some given validation, even
/// after mutation. Attempts to change to an invalid value will throw a
/// validation error.
///	- warning: If the wrapped value is a reference type, then its internals
///		might change to another value that doesn't pass validation without any
///		control by this wrapper.
public struct Validated<Value> {
	// MARK: Private implementation
	
	private var _value: Value
	private var validator: Validator

	private static func validated(_ value: Value, with validator: Validator) throws -> Value {
		do {
			try validator(value)
			return value
		} catch {
			throw ValidationError(invalidValue: value, validatorError: error)
		}
	}

	// MARK: Public interface

	/// A function that determines whether a value is valid or not, by throwing
	/// an error in the case it's not.
	///
	///	- parameter value: The value to validate.
	public typealias Validator = (_ value: Value) throws -> Void

	/// Create a validated value wrapping the given one if it passes the given
	/// validation, or throws an error otherwise.
	///
	///	- parameter value: The value to wrap.
	///	- parameter validator: The validation used to check on the given value.
	///		It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init(value: Value, validator: @escaping Validator) throws {
		self._value = try Validated.validated(value, with: validator)
		self.validator = validator
	}

	/// The currently wrapped value, ensured to pass the validation.
	public var value: Value {
		return _value
	}

	/// Change the value currently wrapped by this object. If the given value
	/// doesn't pass the validation, the wrapped value won't change and this
	/// call throws an error.
	///
	///	- parameter newValue: The value to be wrapped by this object.
	///	- throws: `ValidationError` if the given value doesn't pass validation.
	public mutating func set(to newValue: Value) throws {
		_value = try Validated.validated(newValue, with: validator)
	}
}

// MARK: -

/// The error thrown by `Validated` when using values that doesn't pass
/// validation.
///	- seealso: `Validated`.
public struct ValidationError<Value>: Error {
	/// The value that didn't pass the validation.
	public var invalidValue: Value
	/// The error with which the validation failed.
	public var validatorError: Error
}

// MARK: -

/// A convenience error to use when a validation fails, but no information about
/// the failure is available.
public struct ValueIsNotValidError: Error {}
public let valueIsNotValidError: ValueIsNotValidError = .init()
