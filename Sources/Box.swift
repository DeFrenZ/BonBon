protocol Box: class {
	associatedtype Wrapped
	init(wrapping: Wrapped)
	var value: Wrapped { get }
}

public final class ImmutableBox<Wrapped>: Box {
	public let value: Wrapped
	public init(wrapping value: Wrapped) {
		self.value = value
	}
}

public final class MutableBox<Wrapped>: Box {
	public var value: Wrapped
	public init(wrapping value: Wrapped) {
		self.value = value
	}
}
