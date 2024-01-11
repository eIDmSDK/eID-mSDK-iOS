import Foundation

struct VerifyCertResponse: Codable {

    struct Result: Codable {
        let expiration: String
        let verification: String
    }

    let result: Result
    let timestamp: String
}
