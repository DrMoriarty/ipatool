import Foundation
import Networking

public class DeviceToken {

    public static func current() -> String {
        let MAC_ADDRESS_LENGTH = 6
        let bsds: [String] = ["en0", "en1"]
        var bsd: String = bsds[0]

        var length: size_t = 0
        var buffer: [CChar]

        var bsdIndex = Int32(if_nametoindex(bsd))
        if bsdIndex == 0 {
            bsd = bsds[1]
            bsdIndex = Int32(if_nametoindex(bsd))
            guard bsdIndex != 0 else { fatalError("Could not read MAC address") }
        }

        let bsdData = Data(bsd.utf8)
        var managementInfoBase = [CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, bsdIndex]

        guard sysctl(&managementInfoBase, 6, nil, &length, nil, 0) >= 0 else {
            fatalError("Could not read MAC address")
        }

        buffer = [CChar](unsafeUninitializedCapacity: length, initializingWith: {buffer, initializedCount in
            for x in 0..<length { buffer[x] = 0 }
            initializedCount = length
        })

        guard sysctl(&managementInfoBase, 6, &buffer, &length, nil, 0) >= 0 else {
            fatalError("Could not read MAC address")
        }

        let infoData = Data(bytes: buffer, count: length)
        let indexAfterMsghdr = MemoryLayout<if_msghdr>.stride + 1
        let rangeOfToken = infoData[indexAfterMsghdr...].range(of: bsdData)!
        let lower = rangeOfToken.upperBound
        let upper = lower + MAC_ADDRESS_LENGTH
        let macAddressData = infoData[lower..<upper]
        let addressBytes = macAddressData.map { String(format: "%02x", $0) }
        return addressBytes.joined().uppercased()
    }
}
