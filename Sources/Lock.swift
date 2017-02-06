import Darwin.POSIX.pthread

///	- seealso: [Lock](https://en.wikipedia.org/wiki/Lock_(computer_science))
protocol Lock {
	init()
	func sync <T> (_ perform: () throws -> T) rethrows -> T
}

protocol ConcurrentLock: Lock {
	func concurrentSync <T> (_ perform: () throws -> T) rethrows -> T
}

final class MutexLock: Lock {
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

final class ReadWriteLock: ConcurrentLock {
	private var _lock: pthread_rwlock_t = .init()
	init() {
		pthread_rwlock_init(&_lock, nil)
	}
	deinit {
		pthread_rwlock_destroy(&_lock)
	}

	func concurrentSync <T> (_ perform: () throws -> T) rethrows -> T {
		pthread_rwlock_rdlock(&_lock)
		defer { pthread_rwlock_unlock(&_lock) }
		return try perform()
	}

	func sync <T> (_ perform: () throws -> T) rethrows -> T {
		pthread_rwlock_wrlock(&_lock)
		defer { pthread_rwlock_unlock(&_lock) }
		return try perform()
	}
}
