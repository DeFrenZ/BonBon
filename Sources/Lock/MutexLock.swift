import Darwin

final class MutexLock: UnbalancedLock {
	private var _mutex: pthread_mutex_t = .init()
	init() {
		pthread_mutex_init(&_mutex, nil)
	}
	deinit {
		pthread_mutex_destroy(&_mutex)
	}

	func lock() {
		pthread_mutex_lock(&_mutex)
	}
	func unlock() {
		pthread_mutex_unlock(&_mutex)
	}
}
