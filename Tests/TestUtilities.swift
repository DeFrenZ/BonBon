import Darwin.POSIX
import Dispatch
import struct Foundation.TimeInterval

func sleep(for timeInterval: TimeInterval) {
	let microSeconds: useconds_t = .init(timeInterval * 1_000_000)
	usleep(microSeconds)
}

extension DispatchGroup {
	func wait(for timeInterval: TimeInterval) -> DispatchTimeoutResult {
		let dispatchTime = DispatchTime.now() + (timeInterval * 1_000_000_000)
		return wait(timeout: dispatchTime)
	}
}

