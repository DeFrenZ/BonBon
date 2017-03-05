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

// MARK: - Convenience validators

extension Validated {
	/// Create a validated value wrapping the given one if it satisfies the
	/// given predicate, or throws an error otherwise.
	///	- seealso: `Validated.init(value:validator:)`.
	///
	///	- parameter value: The value to wrap.
	///	- parameter predicate: The condition used to check on the given value.
	///		It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init(value: Value, predicate: @escaping (Value) -> Bool) throws {
		let validator: Validator = { value in
			guard predicate(value) else {
				throw ValueIsNotValid(value)
			}
		}
		try self.init(value: value, validator: validator)
	}

	/// Create a validated value wrapping the given one if it's contained in the
	/// given set of values, or throws an error otherwise.
	///	- seealso: `Validated.init(value:validator:)`.
	///
	///	- parameter value: The value to wrap.
	///	- parameter predicate: The set used to check for containment on the
	///		given value. It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init <S: SetAlgebra> (value: Value, validValues: S) throws where S.Element == Value {
		let validator: Validator = { value in
			guard validValues.contains(value) else {
				throw ValueIsNotContainedInSet(value: value, set: validValues)
			}
		}
		try self.init(value: value, validator: validator)
	}
}

extension Validated where Value: Equatable {
	/// Create a validated value wrapping the given one if it's contained in the
	/// given sequence of values, or throws an error otherwise.
	///	- seealso: `Validated.init(value:validator:)`.
	///
	///	- parameter value: The value to wrap.
	///	- parameter predicate: The sequence used to check for containment on the
	///		given value. It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init <S: Sequence> (value: Value, validValues: S) throws where S.Iterator.Element == Value {
		let validator: Validator = { value in
			guard validValues.contains(value) else {
				throw ValueIsNotContainedInSequence(value: value, sequence: validValues)
			}
		}
		try self.init(value: value, validator: validator)
	}
}

extension Validated where Value: Comparable {
	/// Create a validated value wrapping the given one if it's contained in the
	/// given range of values, or throws an error otherwise.
	///	- seealso: `Validated.init(value:validator:)`.
	///
	///	- parameter value: The value to wrap.
	///	- parameter predicate: The range used to check for containment on the
	///		given value. It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init(value: Value, validRange: Range<Value>) throws {
		let validator: Validator = { value in
			guard validRange.contains(value) else {
				throw ValueIsNotContainedInRange.halfOpenRange(value: value, range: validRange)
			}
		}
		try self.init(value: value, validator: validator)
	}

	/// Create a validated value wrapping the given one if it's contained in the
	/// given range of values, or throws an error otherwise.
	///	- seealso: `Validated.init(value:validator:)`.
	///
	///	- parameter value: The value to wrap.
	///	- parameter predicate: The range used to check for containment on the
	///		given value. It will be used to check on further changes as well.
	///	- throws: `ValidationError` if the validation fails.
	///	- returns: A `Validated` object if the validation succeeds, or throws an
	///		error otherwise.
	public init(value: Value, validRange: ClosedRange<Value>) throws {
		let validator: Validator = { value in
			guard validRange.contains(value) else {
				throw ValueIsNotContainedInRange.closedRange(value: value, range: validRange)
			}
		}
		try self.init(value: value, validator: validator)
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

// MARK: - Convenience errors

/// A convenience error to use when a validation fails, but no information about
/// the failure is available.
public struct ValueIsNotValid<Value>: Error {
	/// The value that didn't pass the validation.
	public var value: Value

	/// Create a validation error with the given value.
	///
	///	- parameter value: The value that didn't pass the validation.
	///	- returns: A validation error with the given value.
	public init(_ value: Value) {
		self.value = value
	}
}

/// A convenience error to use when the containment check for a value in a set
/// fails.
public struct ValueIsNotContainedInSet<S: SetAlgebra>: Error {
	/// The type of the value that didn't pass the validation.
	public typealias Value = S.Element

	/// The value that didn't pass the validation.
	public var value: Value
	/// The set in which the value was not contained.
	public var set: S

	/// Create a containment validation error with the given value and set.
	///
	///	- parameter value: The value that didn't pass the validation.
	///	- parameter set: The set used for the validation.
	///	- returns: A validation error with the given value and set.
	public init(value: Value, set: S) {
		self.value = value
		self.set = set
	}
}

/// A convenience error to use when the containment check for a value in a
/// sequence fails.
public struct ValueIsNotContainedInSequence<S: Sequence>: Error {
	/// The type of the value that didn't pass the validation.
	public typealias Value = S.Iterator.Element

	/// The value that didn't pass the validation.
	public var value: Value
	/// The sequence in which the value was not contained.
	public var sequence: S

	/// Create a containment validation error with the given value and sequence.
	///
	///	- parameter value: The value that didn't pass the validation.
	///	- parameter set: The sequence used for the validation.
	///	- returns: A validation error with the given value and sequence.
	public init(value: Value, sequence: S) {
		self.value = value
		self.sequence = sequence
	}
}

/// A convenience error to use when the containment check for a value in a range
/// fails.
public enum ValueIsNotContainedInRange<Value: Comparable>: Error {
	/// An error where a value was not contained in an half open range.
	///
	///	- value: The value that didn't pass the validation.
	///	- range: The range used for the validation.
	case halfOpenRange(value: Value, range: Range<Value>)

	/// An error where a value was not contained in an closed range.
	///
	///	- value: The value that didn't pass the validation.
	///	- range: The range used for the validation.
	case closedRange(value: Value, range: ClosedRange<Value>)
}
