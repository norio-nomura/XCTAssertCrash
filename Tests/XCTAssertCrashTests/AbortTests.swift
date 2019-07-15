import XCTest
import XCTAssertCrash

class AbortTests: XCTestCase {
    func test_abort() {
        guard enableAbortTest() else { return }

        XCTAssertCrash(abort(), signalHandler: {
            print($0)
        }, stdoutHandler: {
            print($0)
        }, stderrHandler: {
            print($0)
        })
    }

    func test_forceCast() {
        guard enableAbortTest() else { return }

        let object: Any = 1

        XCTAssertCrash(object as! String, signalHandler: { // swiftlint:disable:this force_cast
            XCTAssertEqual($0, SIGABRT)
        }, stdoutHandler: {
            XCTAssertTrue($0.isEmpty)
        }, stderrHandler: {
            XCTAssertTrue($0.contains("Could not cast value of type 'Swift.Int'"), $0)
        })
    }
}

// MARK: - private

private let environmentVariableKey = "XCTAssertCrash.ENABLE_ABORT_TEST"
private let enabledByEnvironmentVariable = ProcessInfo.processInfo.environment[environmentVariableKey] != nil

private func enableAbortTest(_ testFullName: String = #function) -> Bool {
    guard !enabledByEnvironmentVariable else {
        print("\(testFullName) is enabled by \(environmentVariableKey)")
        return true
    }
    let testName = testFullName.replacingOccurrences(of: "()", with: "")
    let result = CommandLine.arguments.contains(where: { $0.hasSuffix("/\(testName)") })
    if result {
        print("\(testFullName) is executed because assuming parallel testing enabled")
    } else {
        print("Skipping \(testFullName)")
    }

    return result
}
