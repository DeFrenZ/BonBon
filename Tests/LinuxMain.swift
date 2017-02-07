import XCTest
@testable import BonBonTests

XCTMain([
     testCase(ObservableTests.allTests),
     testCase(SynchronizedTests.allTests),
     testCase(LockTests.allTests),
])
