import UIKit
import eID
import JWTDecode

class ViewController: eIDViewController {

    // MARK: - Constants

    private struct Constants {
        static let tutorialKey = "sk.minv.eid.userdefaults.ShowTutorial"
        static let languageKey = "sk.minv.eid.userdefaults.SelectedLanguage"
    }

    // MARK: - Properties

    private var handler: eIDHandler?

    private var loggedInUser: String? = nil {
        didSet {
            userNameLabel.superview?.isHidden = loggedInUser == nil
            userNameLabel.text = loggedInUser
            loginButton.setTitle(loggedInUser == nil ? "PRIHLÁSIŤ SA" : "ODHLÁSIŤ SA", for: .normal)
            loginButton.backgroundColor = loggedInUser == nil ? Color.buttonBg : Color.eidBlue
        }
    }

    private var tutorialDisabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.tutorialKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.tutorialKey)
        }
    }

    private var selectedLanguage: Language {
        get {
            return Language(rawValue: UserDefaults.standard.string(forKey: Constants.languageKey) ?? "sk") ?? .sk
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.languageKey)
        }
    }

    @IBOutlet private weak var environmentLabel: UILabel!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var loginButton: MenuButton!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var langSKButton: UIButton!
    @IBOutlet private weak var langENButton: UIButton!


    // MARK: - VC lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // version
        let versionStringApp = "App verzia: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))"
        let versionStringSDK = "eID mSDK: \(Bundle(for: eIDHandler.self).appVersionLong) (\(Bundle(for: eIDHandler.self).appBuild))"
        versionLabel.text = [versionStringApp, versionStringSDK].joined(separator: "\n")

        // reset user
        loggedInUser = nil

        // set lang
        setLanguage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        environmentLabel.text = "env:\n\(eIDEnvironment.selected.environmentKey)"
    }

    // MARK: - language

    @IBAction private func switchToSK() {
        selectedLanguage = .sk
        setLanguage()
    }

    @IBAction private func switchToEN() {
        selectedLanguage = .en
        setLanguage()
    }

    private func setLanguage() {
        let lang = selectedLanguage

        // force selected languguage
        // ⚠️ forcing language is not recommended by apple
        UserDefaults.standard.set(lang.rawValue, forKey: "AppleLanguage")
        Bundle(for: eIDHandler.self).setLanguage(lang.rawValue)

        langSKButton.isSelected = lang == .sk
        langENButton.isSelected = lang == .en
    }

    // MARK: - tutorial

    @IBAction func resetTutorial() {
        tutorialDisabled = false
        showAlert(message: "Tutorial bol resetovaný a bude zobrazený po kliknutí na \"Prihlásiť sa\"", isSuccess: true)
    }

    @IBAction func showTutorial() {
        eIDHandler().showTutorial(from: self, environment: .selected) { [weak self] in
            self?.showAlert(message: "Tutorial bol zatvorený.", isSuccess: true)
        }
    }

    // MARK: - testing eID API

    /// function for testing eID functionality - authentication (oauth implicit flow)
    @IBAction func testAuth() {
        
        // logout if already logged in
        guard loggedInUser == nil else {
            loggedInUser = nil
            return
        }

        // continue with tutotial + login
        showTutorialIfNotDisabled {
            self.handler = eIDHandler()
            self.handler?.setLogLevel(.verbose)
            self.handler?.startAuth(from: self,
                                    environment: eIDEnvironment.selected,
                                    clientID: eIDEnvironment.selected.clientId,
                                    apiKeyId: eIDEnvironment.selected.apiKeyId,
                                    apiKeyValue: eIDEnvironment.selected.apiKeyValue,
                                    nonce: UUID().uuidString) { [weak self] res in
                switch res {
                case .success(let code):
                    print(">> success:: code: \(code)")
                    print(">> ‼️ this code should be passed to the server to obtain id_token and safely sign in the user")
                    print(">> ‼️ for testing purposes - server side logic is simulated in the app")
                    Server.getIdToken(environment: eIDEnvironment.selected, code: code) { serverResult in
                        switch serverResult {
                        case .success(let idToken):
                            if let decodedJWTBody = try? decode(jwt: idToken).body as AnyObject {
                                DispatchQueue.main.async {
                                    let name = decodedJWTBody.value(forKey: "given_name") as? String
                                    let surname = decodedJWTBody.value(forKey: "family_name") as? String
                                    self?.loggedInUser = [name, surname].compactMap { $0 }.joined(separator: " ")
                                }
                                print(String(describing: decodedJWTBody))
                            }
                        case .failure(let serverError):
                            guard let sSelf = self else { return }
                            let msg = "Prihlásenie bolo neúspešné."
                            eIDErrorHandler.handleError(serverError, message: msg, fromViewController: sSelf, repeatAction: sSelf.testAuth)
                        }
                    }

                case .failure(let error):
                    guard let sSelf = self else { return }
                    let msg = "Prihlásenie bolo neúspešné."
                    eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.testAuth)
                }
            }
        }
    }

    private func showTutorialIfNotDisabled(_ completion: @escaping () -> ()) {
        if tutorialDisabled {
            completion()
        }
        else {
            eIDHandler().showTutorial(from: self, environment: .selected) { [weak self] in
                self?.tutorialDisabled = true
                completion()
            }
        }
    }

    /// function for testing eID functionality - reading certificates stored on the eID card
    @IBAction func testReadCertificates() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)
        handler?.getCertificates(from: self, types: eIDCertificateIndex.allCases) { [weak self] res in
            switch res {
            case .success(let certificatesJSONString):
                print("certicates successfully read:\n\(certificatesJSONString)")
            case .failure(let error):
                guard let sSelf = self else { return }
                let msg = "Chyba pri načítaní certifikátov."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.testReadCertificates)
            }
        }
    }

    /// function for testing eID functionality - shows certificates stored on eID card
    @IBAction func testShowCertificates() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)
        handler?.startCertificates(from: self, environment: eIDEnvironment.selected) { [weak self] err in
            guard let sSelf = self else { return }
            if let error = err {
                let msg = "Chyba pri načítaní certifikátov."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.testShowCertificates)
            }
            else {
                print(">> certificates successfully shown")
            }
        }
    }

    /// function for testing eID functionality - signing the hash with qualified electronic signature (QES)
    @IBAction func testSignDataQES() {
        if let signVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: SignViewController.self)) as? SignViewController {
            navigationController?.pushViewController(signVC, animated: true)
            return
        }
    }

    /// function for testing eID functionality - test decrypting the data using encryption certificate in the eID card
    @IBAction func testDecrypt() {
        if let decryptVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: DecryptViewController.self)) as? DecryptViewController {
            navigationController?.pushViewController(decryptVC, animated: true)
            return
        }
    }

    /// function for testing eID functionality - start PIN management process
    @IBAction func testPinManagement() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)
        handler?.startPinManagement(from: self, completion: { [weak self] err in
            guard let sSelf = self else { return }
            if let error = err {
                let msg = "Chyba pri PIN manažmente"
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.testPinManagement)
            }
            else {
                print(">> pin management successfully shown")
            }
        })
    }
}

// MARK: server simulation

struct Server {

    static func getIdToken(environment: eIDEnvironment, code: String, completion: @escaping (Result<String, eIDError>)->()) {

        var request : URLRequest = URLRequest(url: environment.idTokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");

        let params: [String : Any] = ["grant_type": "authorization_code",
                                      "client_id": environment.clientId,
                                      "client_secret": environment.clientSecret,
                                      "code": code,
                                      "scope": "openid",
                                      "redirect_uri": "\(environment.scheme)://authResult?success=true"]

        request.httpBody = params.map { "\($0)=\(($1 as? String)?.urlEncoded ?? "")" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                completion(.failure(.networkError(error?.localizedDescription ?? "")))
                return
            }
            if let jsonData = data,
               let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String : Any],
               let idToken = jsonObj["id_token"] as? String,
               idToken.isEmpty == false {
                completion(.success(idToken))
            }
            else {
                completion(.failure(.authCompletionFailed))
            }
        }).resume()
    }
}
