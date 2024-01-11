import Foundation
import ASN1Decoder

struct Certificate: Codable {
    let slot: String
    let certIndex: Int
    let certData: String
    let isQualified: Bool
    let supportedSchemes: [String]

    lazy var x509Certificate: X509Certificate? = {
        return try? X509Certificate(data: Data(base64Encoded: certData) ?? Data())
    }()
}
