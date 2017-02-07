// MARK: -

///	- seealso: [Lock](https://en.wikipedia.org/wiki/Lock_(computer_science))
protocol Lock {
	init()
	func sync <T> (_ perform: () throws -> T) rethrows -> T
}

// MARK: -

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

// MARK: -

protocol ConcurrentLock: Lock {
	func concurrentSync <T> (_ perform: () throws -> T) rethrows -> T
}

// MARK: -

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
