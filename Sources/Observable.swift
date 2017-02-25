///	A reference wrapper around a mutable value. An object can subscribe for
///	updates to this value with a function, which will have both the states of
///	the transition as arguments. It's not mandatory to unsubscribe to the
///	updates as no strong reference is kept and if a subscribed object gets
///	deallocated it automatically gets unsubsribed.
///
///	- warning: The observer doesn't listen to the wrapped value changes, so if
///		`Observed` has reference semantics notifications of its update will be
///		given only when the reference gets updated, and not when the referenced
///		value does.
///	- seealso: [Observer Pattern]
///		(https://en.wikipedia.org/wiki/Observer_pattern)
public final class Observable<Observed> {
	// MARK: Private implementation
	
	private var actionsPerObject: [ObjectIdentifier: UpdateAction] = [:]

	private var actions: AnySequence<UpdateAction> {
		return .init(actionsPerObject.values)
	}

	private func addObserver(with identifier: ObjectIdentifier, onUpdate: @escaping UpdateAction) {
		actionsPerObject[identifier] = onUpdate
	}

	private func removeObserver(with identifier: ObjectIdentifier) {
		actionsPerObject[identifier] = nil
	}

    private func notifyObservers(from oldValue: Observed, to newValue: Observed) {
        actions.forEach { $0(oldValue, newValue) }
    }

	// MARK: Public interface

	///	The type of the function that gets called back on updates.
	///	- note: `from` and `to` are not necessarily different. Use
	///		`subscribe(_:onChange:)` if you want to ensure that.
	///
	///	- parameter from: The wrapped value before the update.
	///	- parameter to: The wrapped value after the update.
	public typealias UpdateAction = (_ from: Observed, _ to: Observed) -> Void

	///	The wrapped value of which updates are tracked by the `Observable`
	///	object and notified to its observers. Can be read and changed by
	///	anyone.
    public var value: Observed {
        didSet { notifyObservers(from: oldValue, to: value) }
    }

	///	Create a new `Observable` wrapping the given `value`.
	///
	///	- parameter value: The initial value from which changes will be
	///		observed.
    public init(_ value: Observed) {
        self.value = value
    }

	///	Subscribe to updates on the wrapped value by calling the passed function
	///	every time that happens. The subscription is referenced to through the
	///	given object, which is not strongly referenced, so that needs to stay
	///	alive for the subscription to continue and must be used to unsubscribe.
	///	- note: `onUpdate` will be called whenever the wrapped value gets set,
	///		even if the value didn't change. It doesn't get called when you
	///		subscribe to it.
	///	- warning: Only one subscription per object per `Observable` is allowed.
	///		Subscribing again with the same object for updates will
	///		automatically remove the previous subscription. If you want to
	///		subscribe with separate callbacks from the same context, use two
	///		different objects for them.
	///	- seealso: `subscribe(_:onChange:)`
	///
	///	- parameter observer: The object that owns the subscription. It can be
	///		hold only one subscription per `Observable`. If this gets
	///		deallocated then it is automatically unsubscribed.
	///	- parameter onUpdate: The function that will get called on every update
	///		of the wrapped value.
	public func subscribe(_ observer: AnyObject, onUpdate: @escaping UpdateAction) {
		let identifier = ObjectIdentifier(observer)
		let autoreleasingOnUpdate: UpdateAction = { [weak self, weak observer] oldValue, newValue in
			guard let _self = self else { return }
			guard observer != nil else {
				_self.removeObserver(with: identifier)
				return
			}
			onUpdate(oldValue, newValue)
		}
		addObserver(with: identifier, onUpdate: autoreleasingOnUpdate)
    }

	/// Unsubscribe the given object from further updates to the wrapped value.
	///
	///	- parameter observer: The object that was used to subscribe to updates
	///		in the first place.
	public func unsubscribe(_ observer: AnyObject) {
		let identifier = ObjectIdentifier(observer)
		removeObserver(with: identifier)
	}
}

// MARK: - Type-constrained extensions

extension Observable where Observed: Equatable {
	/// Subscribe to changes on the wrapped value with the passed function, but
	///	only when it gets set to a different value. That's the only difference
	///	from a classic subscription.
	///	- seealso: `subscribe(_:onUpdate:)`
	///
	///	- parameter observer: The object that owns the subscription.
	///	- parameter onChange: The function that will get called on every update
	///		of the wrapped value to a different value.
	public func subscribe(_ observer: AnyObject, onChange: @escaping UpdateAction) {
		subscribe(observer, onUpdate: { oldValue, newValue in
			guard newValue != oldValue else { return }
			onChange(oldValue, newValue)
		})
	}
}

// MARK: - Functional extensions

extension Observable {
	///	Create a new `Observable` object that always keeps the same value as
	///	this one, transformed through the given function. The updates are given
	///	referring to the transformed value, and changes are determined in terms
	///	of the result of the transformation.
	///
	///	- parameter transform: The transform between the value on this object
	///		and the resulting one.
	///	- parameter value: The `value` of this that gets transformed.
	///	- returns: Another `Observable`, which notifies its subscribers of
	///		updates on its transformed value.
	public func map <T> (_ transform: @escaping (_ value: Observed) -> T) -> Observable<T> {
		let mappedObservable: Observable<T> = .init(transform(value))
		subscribe(mappedObservable, onUpdate: { [weak mappedObservable] oldValue, newValue in
			mappedObservable?.value = transform(newValue)
		})
		return mappedObservable
	}

	/// Create a new `Observable` object that alwyas keeps the value of the one
	/// resulting from applying the given `transform` on this one. The updates
	///	are given referring to the transformed value, and changes are determined
	///	in terms of the result of the transformation.
	///	- seealso: `map`
	///
	/// - parameter transform: The transform between the value on this object
	///		and a new `Observable`.
	///	- parameter value: The `value` of this that gets transformed.
	///	- returns: Another `Observable`, which is created from applying
	///		`transform` on the current `value`, but which keeps track of future
	///		changes of it.
	public func flatMap <T> (_ transform: @escaping (_ value: Observed) -> Observable<T>) -> Observable<T> {
		return map({ transform($0).value })
	}
}

// MARK: -

/// An empty reference. It's only purpose is to be used to subscribe to an
/// `Observable` when there's no more fitting object to use as the observer.
public final class SubscriptionOwner {
	public init() {}
}
