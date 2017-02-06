import Darwin.POSIX.pthread

public final class Synchronized<Wrapped> {
	private var _lock: MutexLock = .init()
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

fileprivate final class MutexLock {
	private var _lock: pthread_mutex_t = .init()
	init() {
		pthread_mutex_init(&_lock, nil)
	}
	deinit {
		pthread_mutex_destroy(&_lock)
	}

	func sync <T> (_ perform: () throws -> T) rethrows -> T {
		pthread_mutex_lock(&_lock)
		defer { pthread_mutex_unlock(&_lock) }
		return try perform()
	}
}
