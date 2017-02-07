import Darwin

final class ReadWriteLock: ConcurrentUnbalancedLock {
	private var _lock: pthread_rwlock_t = .init()
	init() {
		pthread_rwlock_init(&_lock, nil)
	}
	deinit {
		pthread_rwlock_destroy(&_lock)
	}

	func lock() {
		pthread_rwlock_wrlock(&_lock)
	}
	func concurrentLock() {
		pthread_rwlock_rdlock(&_lock)
	}
	func unlock() {
		pthread_rwlock_unlock(&_lock)
	}
}
