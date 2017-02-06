import Darwin.POSIX
import Dispatch
import struct Foundation.TimeInterval

func sleep(for timeInterval: TimeInterval) {
	let microSeconds: useconds_t = .init(timeInterval * 1_000_000)
	usleep(microSeconds)
}
