import Foundation

typealias Byte = UInt8
typealias Bytes = [Byte]

extension Data {
    var bytes: Bytes {
        var byteArray = [Byte](repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = [], separator: String = "") -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined(separator: separator)
    }

    init?(hexString: String?) {
        guard let hexString = hexString else {
            return nil
        }

        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            }
            else {
                return nil
            }
            i = j
        }
        self = data
    }
}
