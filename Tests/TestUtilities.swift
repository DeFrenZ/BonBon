import Darwin
import Dispatch
import struct Foundation.TimeInterval
import class XCTest.XCTestCase

func sleep(for timeInterval: TimeInterval) {
	let microSeconds: useconds_t = .init(timeInterval * Double(USEC_PER_SEC))
	usleep(microSeconds)
}

extension DispatchGroup {
	func wait(for timeInterval: TimeInterval) -> DispatchTimeoutResult {
		let dispatchTime = DispatchTime.now() + (timeInterval * Double(NSEC_PER_SEC))
		return wait(timeout: dispatchTime)
	}
}

let shortWait: TimeInterval = 0.001
let shortWaitLimit: TimeInterval = shortWait * 2

extension XCTestCase {
	func measure(times: Int, _ block: @escaping () -> Void) {
		measure {
			for _ in 0 ..< times {
				block()
			}
		}
	}
}
