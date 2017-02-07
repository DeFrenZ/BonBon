// MARK: - Lock

///	- seealso: [Lock](https://en.wikipedia.org/wiki/Lock_(computer_science))
protocol Lock {
	init()
	func sync <T> (_ perform: () throws -> T) rethrows -> T
}

// MARK: - UnbalancedLock

protocol UnbalancedLock: Lock {
	func lock()
	func unlock()
}

extension UnbalancedLock {
	func sync <T> (_ perform: () throws -> T) rethrows -> T {
		lock()
		defer { unlock() }
		return try perform()
	}
}

// MARK: - ConcurrentLock

protocol ConcurrentLock: Lock {
	func concurrentSync <T> (_ perform: () throws -> T) rethrows -> T
}

// MARK: - ConcurrentUnbalancedLock

protocol ConcurrentUnbalancedLock: ConcurrentLock, UnbalancedLock {
	func concurrentLock()
}

extension ConcurrentUnbalancedLock {
	func concurrentSync <T> (_ perform: () throws -> T) rethrows -> T {
		concurrentLock()
		defer { unlock() }
		return try perform()
	}
}
