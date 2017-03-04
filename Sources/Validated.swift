public struct Validated<Value> {
	public private(set) var value: Value
	private var validator: Validator<Value>

	public init(value: Value, validator: @escaping Validator<Value>) throws {
		self.value = try validated(value, with: validator)
		self.validator = validator
	}

	public mutating func set(to newValue: Value) throws {
		value = try validated(newValue, with: validator)
	}
}

public typealias Validator<Value> = (Value) throws -> Void

public struct ValidationError<Value>: Error {
	public var invalidValue: Value
	public var validatorError: Error
}

private func validated <Value> (_ value: Value, with validator: Validator<Value>) throws -> Value {
	do {
		try validator(value)
		return value
	} catch {
		throw ValidationError(invalidValue: value, validatorError: error)
	}
}
