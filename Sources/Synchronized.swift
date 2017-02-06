public final class Synchronized<Wrapped> {
	private var _lock: Lock
	private var _value: Wrapped

	public init(_ value: Wrapped) {
		self._value = value
	}

	public var value: Wrapped {
		get { return _lock.sync { _value } }
		set { _lock.sync { _value = newValue } }
	}

	public func atomicallyUpdate(_ update: (inout Wrapped) throws -> Void) rethrows {
		try _lock.sync({ try update(&_value) })
	}
}
