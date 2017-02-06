import XCTest

class AsynchronousTestCase: XCTestCase {
	var queue: DispatchQueue!
	var group: DispatchGroup!
	override func setUp() {
		super.setUp()
		queue = DispatchQueue(label: "\(invocation!.selector)", attributes: .concurrent)
		group = DispatchGroup()
	}
}
