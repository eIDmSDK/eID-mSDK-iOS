import Foundation
import eID

extension eIDEnvironment {

    // MARK: - constants

    private struct Constants {
        static let tutorialKey = "sk.plaut.eid.userdefaults.SelectedEnvironment"
        static let defaultEnvironment = eIDEnvironment.minvTest
    }

    // MARK: - selected environment

    static var selected: eIDEnvironment {
        set {
            UserDefaults.standard.set(newValue.environmentKey, forKey: Constants.tutorialKey)
        }
        get {
            return eIDEnvironment(key: UserDefaults.standard.string(forKey: Constants.tutorialKey) ?? "") ?? Constants.defaultEnvironment
        }
    }

    var environmentKey: String {
        return String(describing: self)
    }

    // MARK: - api keys & secrets

    var clientId: String {
        switch self {
        case .plautDev:
            return ""
        case .plautTest:
            return ""
        case .minvTest:
            return ""
        case .minvProd:
            return ""
        }
    }

    var clientSecret: String {
        switch self {
        case .plautDev:
            return ""
        case .plautTest:
            return ""
        case .minvTest:
            return ""
        case .minvProd:
            return ""
        }
    }

    var apiKeyId: String { return clientId }
    var apiKeyValue: String { return clientSecret }

    // MARK: - init

    init?(key: String) {
        switch key {
        case eIDEnvironment.plautDev.environmentKey:
            self = .plautDev
        case eIDEnvironment.plautTest.environmentKey:
            self = .plautTest
        case eIDEnvironment.minvTest.environmentKey:
            self = .minvTest
        case eIDEnvironment.minvProd.environmentKey:
            self = .minvProd
        default:
            return nil
        }
    }
}
