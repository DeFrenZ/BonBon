import Darwin

@available(OSX 10.12, *)
final class UnfairLock: UnbalancedLock {
	private var _lock: os_unfair_lock = .init()

	func lock() {
		os_unfair_lock_lock(&_lock)
	}
	func unlock() {
		os_unfair_lock_unlock(&_lock)
	}
}
