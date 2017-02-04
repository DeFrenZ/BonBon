public final class Observable<Observed> {
    private var observers: [UpdateAction] = []

    private func notifyObservers(from oldValue: Observed, to newValue: Observed) {
        observers.forEach { $0(oldValue, newValue) }
    }

    public typealias UpdateAction = (Observed, Observed) -> Void

    public var value: Observed {
        didSet { notifyObservers(from: oldValue, to: value) }
    }

    public init(_ value: Observed) {
        self.value = value
    }

    public func subscribe(onUpdate: @escaping UpdateAction) {
        observers.append(onUpdate)
    }
}
