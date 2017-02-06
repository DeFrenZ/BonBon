///	A reference wrapper around a mutable value. The public interface to access
///	the underlying value is made thread-safe by internally using low level lock
///	APIs.
/// - warning: The public interface is thread-safe, but anything that is not
///		purely one of these APIs is not. E.g.
///		````
///		let number = Synchronized(0)
///		number.value += 1
///		````
///		is not thread-safe. To understand why we have to look at what is really
///		happening: the `+=` operator internally is probably something like
///		````
///		let oldValue = number.value // Thread-safe
///		let newValue = oldValue + 1 // !!!: Non thread-safe
///		number.value = newValue // Thread-safe
///		````
///		We can see that the `get` and the `set` are both thread-safe but if used
///		sequentially the gap between them is not. In these cases perform these
///		multiple actions inside an `atomicallyUpdate` call. E.g.
///		`number.atomicallyUpdate { $0 += 1 }`.
///	- warning: There is no way to enforce this, but if the wrapped type has
///		reference semantics then it's possible for the consumer to retrieve the
///		value in a thread-safe manner, but then edit it in a non-thread-safe way
///		after the reference is outside the wrapper. As such, it's highly
///		suggested to only wrap types with value semantics.
///	- seealso: [Synchronization]
///		(https://en.wikipedia.org/wiki/Synchronization_(computer_science))
public final class Synchronized<Wrapped> {
	// MARK: Private implementation
	
	private var _lock: Lock
	private var _value: Wrapped

	private func readSync <T> (_ perform: () throws -> T) rethrows -> T {
		guard let concurrentLock = _lock as? ConcurrentLock else {
			return try _lock.sync(perform)
		}
		return try concurrentLock.concurrentSync(perform)
	}

	// MARK: Public interface

	///	Create a new `Synchronized` wrapping the given `value`.
	///
	///	- parameter value: The value that will be accessed only in a thread-safe
	///		way.
	///	- parameter allowConcurrentReads: Specify whether the read-only accesses
	///		to the wrapped value can happen concurrently or not. Defaults to
	///		`true`.
	public init(_ value: Wrapped, allowConcurrentReads: Bool = true) {
		self._value = value
		self._lock = allowConcurrentReads ? ReadWriteLock() : MutexLock()
	}

	/// The wrapped value. Access is thread-safe.
	///
	/// - warning: While access is thread-safe, seemingly innocuous usage of it
	///		might not be. Check the documentation of the type for examples.
	public var value: Wrapped {
		get { return readSync { _value } }
		set { _lock.sync { _value = newValue } }
	}

	/// Execute the given function within a thread-safe context that has
	///	read-write access to the wrapped value.
	/// - note: This is the only way to set a new value to the wrapped variable
	///		that depends on its previous one in a thead-safe manner.
	///
	///	- parameter update: The function that is executed with exclusive access
	///		to the wrapped value.
	/// - parameter value: The current wrapped value. Can be updated directly.
	public func atomicallyUpdate(_ update: (_ value: inout Wrapped) throws -> Void) rethrows {
		try _lock.sync({ try update(&_value) })
	}
}
