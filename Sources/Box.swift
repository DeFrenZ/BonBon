/// A protocol representing the common interface of reference wrappers around
/// values. This protocol is only used to share implementation between the
/// available box types.
public protocol Box: class {
	/// The type of the wrapped value.
	///	- warning: Using a reference type defeats the purpose of this wrapper.
	associatedtype Wrapped

	/// Initialize a box wrapping the given value.
	///
	///	- parameter value: The value to wrap.
	///	- returns: A reference wrapper holding the given value.
	init(wrapping value: Wrapped)

	/// Retrieve the wrapped value by "unboxing" it.
	var value: Wrapped { get }
}

// MARK: - Copy extensions

extension Box {
	/// Create a new box wrapping the same value. Suggested when handling a
	/// `MutableBox` that shouldn't mutate anymore.
	///
	///	- returns: A new `ImmutableBox` wrapping the same value as `self`.
	public func copy() -> ImmutableBox<Wrapped> {
		return .init(wrapping: value)
	}

	/// Create a new mutable box wrapping the same value. Suggested when
	/// handling an `ImmutableBox` which you want to mutate.
	///
	///	- returns: A new `MutableBox` wrapping the same value as `self`.
	public func mutableCopy() -> MutableBox<Wrapped> {
		return .init(wrapping: value)
	}
}

// MARK: - Functional extensions

extension Box {
	/// Create a new box wrapping the value resulting from applying the given
	/// transform to the wrapped one.
	///
	///	- parameter transform: The transform to apply on the wrapped value.
	///	- parameter value: The value to transform.
	///	- returns: A new `ImmutableBox` wrapping the transformed value.
	public func map <T> (_ transform: (_ value: Wrapped) throws -> T) rethrows -> ImmutableBox<T> {
		return try .init(wrapping: transform(value))
	}

	/// Create a new box wrapping the same value as in the box resulting from
	/// applying the given transform to the wrapped one.
	///
	///	- parameter transform: The transform to apply on the wrapped value.
	///	- parameter value: The value to transform.
	///	- returns: A new `ImmutableBox` wrapping the value wrapped by the
	///		transform result.
	public func flatMap <NewBox: Box> (_ transform: (_ value: Wrapped) throws -> NewBox) rethrows -> ImmutableBox<NewBox.Wrapped> {
		return try map({ try transform($0).value })
	}
}

// MARK: - ==

/// Returns a `Bool` value indicating whether two `Box`es objects wrap the same
/// value.
///	- note: This check doesn't consider the type of the objects. If you want to
///		check whether two variables refer to the same object, use `===` instead.
///
///	- parameter lhs: The object on the left hand side of the operator.
///	- parameter rhs: The object on the right hand side of the operator.
///	- returns: `true` if the two objects wrap the same value, `false` otherwise.
public func == <LeftBox: Box, RightBox: Box> (_ lhs: LeftBox, _ rhs: RightBox) -> Bool
	where LeftBox.Wrapped: Equatable, LeftBox.Wrapped == RightBox.Wrapped
{
	return lhs.value == rhs.value
}

/// Returns a `Bool` value indicating whether two `Box`es objects don't wrap the
/// same value.
///	- seealso: `==` with the same argument list.
///
///	- parameter lhs: The object on the left hand side of the operator.
///	- parameter rhs: The object on the right hand side of the operator.
///	- returns: `false` if the two objects wrap the same value, `true` otherwise.
public func != <LeftBox: Box, RightBox: Box> (_ lhs: LeftBox, _ rhs: RightBox) -> Bool
	where LeftBox.Wrapped: Equatable, LeftBox.Wrapped == RightBox.Wrapped
{
	return !(lhs == rhs)
}

// MARK: -

/// A `Box` that doesn't change the value it wraps after instantiation.
public final class ImmutableBox<Wrapped>: Box {
	/// The wrapped value.
	public let value: Wrapped

	/// Create a new box wrapping the given value.
	///
	///	- parameter value: The value to wrap.
	///	- returns: A box wrapping the value.
	public init(wrapping value: Wrapped) {
		self.value = value
	}
}

// MARK: -

/// A `Box` that can change the value it wraps after instantiation.
public final class MutableBox<Wrapped>: Box {
	/// The currently wrapped value.
	public var value: Wrapped

	/// Create a new mutable box wrapping the given value.
	///
	///	- parameter value: The value to initially wrap.
	///	- returns: A mutable box wrapping the value.
	public init(wrapping value: Wrapped) {
		self.value = value
	}
}
