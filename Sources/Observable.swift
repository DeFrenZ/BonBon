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
		addObserver(with: identifier, onUpdate: onUpdate)
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
