import XCTest

import XCTAssertCrashTests

var tests = [XCTestCaseEntry]()
tests += XCTAssertCrashTests.__allTests()

XCTMain(tests)
