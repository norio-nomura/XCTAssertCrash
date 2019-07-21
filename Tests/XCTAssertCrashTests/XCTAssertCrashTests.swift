import XCTest
import XCTAssertCrash

#if arch(arm64)
let signalGeneratedByAssert = SIGTRAP
#else
let signalGeneratedByAssert = SIGILL
#endif

final class XCTAssertCrashTests: XCTestCase {
    func test_assert() {
        XCTAssertCrash(assert(false), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Assertion failed"), $0)
        })
    }

    func test_assertionFailure() {
        XCTAssertCrash(assertionFailure(), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Fatal error"), $0)
        })
    }

    func test_precondition() {
        XCTAssertCrash(precondition(false), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
        #if DEBUG
            XCTAssertTrue($0.contains("Precondition failed"), $0)
        #else
            XCTAssertTrue($0.isEmpty)
        #endif
        })
    }

    func test_preconditionFailure() {
        XCTAssertCrash(preconditionFailure(), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
        #if DEBUG
            XCTAssertTrue($0.contains("Fatal error"), $0)
        #else
            XCTAssertTrue($0.isEmpty)
        #endif
        })
    }

    func test_fatalError() {
        XCTAssertCrash(fatalError(), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Fatal error"), $0)
        })
    }

    func test_forceTry() {
        struct Error: Swift.Error {} // swiftlint:disable:this nesting
        func throwsError() throws {
            throw Error()
        }

        XCTAssertCrash(try! throwsError(), signalHandler: { // swiftlint:disable:this force_try
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Fatal error: 'try!' expression unexpectedly raised an error"), $0)
        })
    }

    func test_forceUnwrap() {
        let optionalInt: Int? = nil

        XCTAssertCrash(optionalInt!, signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
        #if DEBUG
            XCTAssertTrue($0.contains("Fatal error: Unexpectedly found nil while unwrapping an Optional value"), $0)
        #else
            XCTAssertTrue($0.isEmpty)
        #endif
        })
    }

    func test_forceUnwrapAtKeyPathPostfix() {
        let interestingNumbers = ["prime": [2, 3, 5, 7, 11, 13, 17],
                                  "triangular": [1, 3, 6, 10, 15, 21, 28],
                                  "hexagonal": [1, 6, 15, 28, 45, 66, 91]]

        XCTAssertCrash(interestingNumbers[keyPath: \[String: [Int]].["hoge"]![0]], signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Fatal error: Unexpectedly found nil while unwrapping an Optional value"), $0)
        })
    }

    func test_overflow() {
        func sum(_ lhs: Int, _ rhs: Int) -> Int {
            return lhs + rhs
        }

        XCTAssertCrash(sum(.max, .max), signalHandler: {
            XCTAssertEqual($0, signalGeneratedByAssert)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.isEmpty)
        })
    }

    func test_badAccess() {
        func badAccess() {
            let string: StaticString = "test_string"
            string.withUTF8Buffer {
                unsafeBitCast($0.baseAddress, to: UnsafeMutablePointer<Bool>.self).pointee = true
            }
        }
        XCTAssertCrash(badAccess(), signalHandler: {
        #if canImport(Darwin)
            XCTAssertEqual($0, SIGBUS)
        #elseif os(Linux)
            XCTAssertEqual($0, SIGSEGV)
        #else
            #error("Unsupported Platform")
        #endif
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.isEmpty)
        })
    }

    func test_segv() {
        func badAccess() {
        #if canImport(Darwin)
            let unsafePointer = UnsafePointer<Int>(bitPattern: UInt(MACH_VM_MAX_ADDRESS))
        #elseif os(Linux)
            var rlimAddressSpace = rlimit()
            let result = getrlimit(numericCast(RLIMIT_AS.rawValue), &rlimAddressSpace)
            assert(result == 0)
            let unsafePointer = UnsafePointer<Int>(bitPattern: rlimAddressSpace.rlim_cur)
        #else
            #error("Unsupported Platform")
        #endif
            for index in 0..<1000_000_000 {
                _ = unsafePointer?[index]
            }
        }
        XCTAssertCrash(badAccess(), signalHandler: {
            XCTAssertEqual($0, SIGSEGV)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.isEmpty)
        })
    }
}
