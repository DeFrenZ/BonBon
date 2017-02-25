import XCTest
@testable import BonBonTests

XCTMain([
     testCase(ObservableTests.allTests),
     testCase(SynchronizedTests.allTests),
     testCase(ResultTests.allTests),
     testCase(BoxTests.allTests),
     testCase(LockTests.allTests),
])
