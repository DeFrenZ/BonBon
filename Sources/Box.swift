public final class Box<Wrapped> {
	public let value: Wrapped
	public init(_ value: Wrapped) {
		self.value = value
	}
}

public final class MutableBox<Wrapped> {
	public var value: Wrapped
	public init(_ value: Wrapped) {
		self.value = value
	}
}
