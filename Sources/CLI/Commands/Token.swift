import ArgumentParser
import Foundation
import Networking
import StoreAPI

struct Token: ParsableCommand {
    static var configuration: CommandConfiguration {
        return .init(abstract: "Returns the current device token.")
    }

    @Option(name: [.long], help: "The log level.")
    private var logLevel: LogLevel = .info

    lazy var logger = ConsoleLogger(level: logLevel)
}

extension Token {

    mutating func run() throws {
        // Search the iTunes store
        let token = DeviceToken.current()

        logger.log("Current device token is: \(token)", level: .info)
    }
}
