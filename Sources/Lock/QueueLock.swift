import Dispatch

final class QueueLock: ConcurrentLock {
	private var _queue: DispatchQueue = .init(
		label: "Lock queue",
		attributes: .concurrent
	)

	func sync<T>(_ perform: () throws -> T) rethrows -> T {
		return try _queue.sync(flags: .barrier, execute: perform)
	}

	func concurrentSync<T>(_ perform: () throws -> T) rethrows -> T {
		return try _queue.sync(execute: perform)
	}
}
