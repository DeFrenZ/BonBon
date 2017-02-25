protocol Box: class {
	associatedtype Wrapped
	init(wrapping: Wrapped)
	var value: Wrapped { get }
}

extension Box {
	public func copy() -> ImmutableBox<Wrapped> {
		return .init(wrapping: value)
	}
	public func mutableCopy() -> MutableBox<Wrapped> {
		return .init(wrapping: value)
	}
}

extension Box {
	public func map <T> (_ transform: (Wrapped) throws -> T) rethrows -> ImmutableBox<T> {
		return try .init(wrapping: transform(value))
	}
	public func flatMap <NewBox: Box> (_ transform: (Wrapped) throws -> NewBox) rethrows -> ImmutableBox<NewBox.Wrapped> {
		return try map({ try transform($0).value })
	}
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
