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

	public typealias Validator = (Value) throws -> Void

	public init(value: Value, validator: @escaping Validator) throws {
		self._value = try Validated.validated(value, with: validator)
		self.validator = validator
	}

	public var value: Value {
		return _value
	}

	public mutating func set(to newValue: Value) throws {
		_value = try Validated.validated(newValue, with: validator)
	}
}

// MARK: -

public struct ValidationError<Value>: Error {
	public var invalidValue: Value
	public var validatorError: Error
}
