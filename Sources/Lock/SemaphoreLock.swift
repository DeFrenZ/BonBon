import Dispatch

final class SemaphoreLock: UnbalancedLock {
	private var _semaphore: DispatchSemaphore = .init(value: 1)

	func lock() {
		_semaphore.wait()
	}
	func unlock() {
		_semaphore.signal()
	}
}
