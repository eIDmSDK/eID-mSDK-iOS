import Foundation

struct GetCertificatesReponse: Codable {
    let cardType: String
    let QSCD: Bool
    let certificates: [Certificate]
}
