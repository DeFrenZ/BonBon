public final class Synchronized<Wrapped> {
	private var _lock: Lock
	private var _value: Wrapped

	public init(_ value: Wrapped, allowConcurrentReads: Bool = true) {
		self._value = value
		self._lock = allowConcurrentReads ? ReadWriteLock() : MutexLock()
	}

	private func readSync <T> (_ perform: () throws -> T) rethrows -> T {
		guard let concurrentLock = _lock as? ConcurrentLock else {
			return try _lock.sync(perform)
		}
		return try concurrentLock.concurrentSync(perform)
	}

	public var value: Wrapped {
		get { return readSync { _value } }
		set { _lock.sync { _value = newValue } }
	}

	public func atomicallyUpdate(_ update: (inout Wrapped) throws -> Void) rethrows {
		try _lock.sync({ try update(&_value) })
	}
}
