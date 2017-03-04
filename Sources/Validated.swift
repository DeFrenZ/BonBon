public struct Validated<Value> {
	public typealias Validator = (Value) throws -> Void

	public private(set) var value: Value
	private var validator: Validator

	private static func validated(_ value: Value, with validator: Validator) throws -> Value {
		do {
			try validator(value)
			return value
		} catch {
			throw ValidationError(invalidValue: value, validatorError: error)
		}
	}

	public init(value: Value, validator: @escaping Validator) throws {
		self.value = try Validated.validated(value, with: validator)
		self.validator = validator
	}

	public mutating func set(to newValue: Value) throws {
		value = try Validated.validated(newValue, with: validator)
	}
}

public struct ValidationError<Value>: Error {
	public var invalidValue: Value
	public var validatorError: Error
}
