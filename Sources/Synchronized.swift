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
	
	private var _lock: _Lock
	private var _value: Wrapped

	private func readSync <T> (_ perform: () throws -> T) rethrows -> T {
		switch _lock {
		case .synchronous(let lock): return try lock.sync(perform)
		case .concurrent(let lock): return try lock.concurrentSync(perform)
		}
	}

	fileprivate var _allowConcurrentReads: Bool {
		return _lock is ConcurrentLock
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
		self._lock = _Lock(isConcurrent: allowConcurrentReads)
		self._value = value
	}

	/// The wrapped value. Access is thread-safe.
	///
	/// - warning: While access is thread-safe, seemingly innocuous usage of it
	///		might not be. Check the documentation of the type for examples.
	public var value: Wrapped {
		get { return readSync { _value } }
		set { _lock.lock.sync { _value = newValue } }
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
		try _lock.lock.sync({ try update(&_value) })
	}
}

// MARK: - Extensions

extension Synchronized {
	/// Create a new `Synchronized` object that holds the result of a
	/// `transform` on the current one. The new object will have the same
	/// concurrency settings as the old one.
	///	- note: The transformation is applied in a thread-safe manner, but the
	///		synchronization of the new object is completely independent from the
	///		one of this one.
	///
	///	- parameter transform: The transform applied on the current `value`
	///		wrapped by this object.
	///	- parameter value: The wrapped value on which the `transform` is applied
	///		to.
	///	- returns: Another `Synchronized`, wrapping the transformed value of
	///		this one.
	public func map <T> (_ transform: @escaping (_ value: Wrapped) -> T) -> Synchronized<T> {
		return .init(transform(value), allowConcurrentReads: _allowConcurrentReads)
	}

	/// Create a new `Synchronized` object that holds the same value of the
	///	result of a `transform` on the current one. The new object will have the
	///	same concurrency settings as the old one.
	///	- seealso: `map`
	///
	///	- parameter transform: The transform applied on the current `value`
	///		wrapped by this object.
	///	- parameter value: The wrapped value on which the `transform` is applied
	///		to.
	///	- returns: Another `Synchronized`, wrapping the same value of the
	///		transform on this one's.
	public func flatMap <T> (_ transform: @escaping (_ value: Wrapped) -> Synchronized<T>) -> Synchronized<T> {
		return map({ transform($0).value })
	}
}

// MARK: -

private enum _Lock {
	static let defaultSynchronous: _Lock = .synchronous(MutexLock())
	static let defaultConcurrent: _Lock = .concurrent(ReadWriteLock())
	init(isConcurrent: Bool) {
		self = isConcurrent ? .defaultConcurrent : .defaultSynchronous
	}

	case synchronous(Lock)
	case concurrent(ConcurrentLock)

	var lock: Lock {
		switch self {
		case .synchronous(let lock): return lock
		case .concurrent(let lock): return lock
		}
	}
}
