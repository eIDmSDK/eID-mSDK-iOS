import Foundation

extension String {
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))) // RFC 3986
    }
}
