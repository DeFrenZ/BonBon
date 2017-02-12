/// A wrapper around the result of an operation. It either holds a successful
/// result of the declared type, or an error that occurred in executing it.
/// This implementation opted for non-strongly typed errors as it works better
/// together with the existing Swift error handling.
///	- seealso: [Result Type](https://en.wikipedia.org/wiki/Result_type)
public enum Result<Value> {
	/// The value returned from a successful execution.
	case success(Value)
	/// A thrown error from a failed execution.
	case failure(Error)
}
