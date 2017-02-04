public final class Observable<Observed> {
	// MARK: - Private implementation
	
	private var actionsPerObject: [ObjectIdentifier: UpdateAction] = [:]

	private var actions: AnySequence<UpdateAction> {
		return AnySequence(actionsPerObject.values)
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

	// MARK: - Public interface

    public typealias UpdateAction = (Observed, Observed) -> Void

    public var value: Observed {
        didSet { notifyObservers(from: oldValue, to: value) }
    }

    public init(_ value: Observed) {
        self.value = value
    }

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

	public func unsubscribe(_ observer: AnyObject) {
		let identifier = ObjectIdentifier(observer)
		removeObserver(with: identifier)
	}
}

extension Observable where Observed: Equatable {
	public func subscribe(_ observer: AnyObject, onChange: @escaping UpdateAction) {
		subscribe(observer, onUpdate: { oldValue, newValue in
			guard newValue != oldValue else { return }
			onChange(oldValue, newValue)
		})
	}
}

extension Observable {
	public func map <T> (_ transform: @escaping (Observed) -> T) -> Observable<T> {
		let mappedObservable = Observable<T>(transform(value))
		subscribe(mappedObservable, onUpdate: { [weak mappedObservable] oldValue, newValue in
			mappedObservable?.value = transform(newValue)
		})
		return mappedObservable
	}
}
