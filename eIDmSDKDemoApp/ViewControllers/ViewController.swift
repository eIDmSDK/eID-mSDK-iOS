import UIKit
import eID
import JWTDecode

class ViewController: eIDViewController {

    // MARK: - Constants

    private struct Constants {
        static let tutorialKey = "sk.plaut.eid.userdefaults.ShowTutorial"
        static let languageKey = "sk.plaut.eid.userdefaults.SelectedLanguage"
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
        eIDHandler().showTutorial(from: self) { [weak self] in
            self?.showAlert(message: "Tutorial bol zatvorený.", isSuccess: true)
        }
    }

    // MARK: - testing eID API

    /// function for testing eID functionality - authentication (and showing tutorial)
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
                                    clientSecret: eIDEnvironment.selected.clientSecret,
                                    apiKeyId: eIDEnvironment.selected.apiKeyId,
                                    apiKeyValue: eIDEnvironment.selected.apiKeyValue,
                                    nonce: UUID().uuidString) { [weak self] res in
                switch res {
                case .success(let code):
                    print(">> success:: id token: \(code)")
                    if let decodedJWTBody = try? decode(jwt: code).body as AnyObject {
                        DispatchQueue.main.async {
                            let name = decodedJWTBody.value(forKey: "given_name") as? String
                            let surname = decodedJWTBody.value(forKey: "family_name") as? String
                            self?.loggedInUser = [name, surname].compactMap { $0 }.joined(separator: " ")
                        }
                        print(String(describing: decodedJWTBody))
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
            eIDHandler().showTutorial(from: self) { [weak self] in
                self?.tutorialDisabled = true
                completion()
            }
        }
    }

    /// function for testing eID functionality - scan and process eID compatible QR code (see mSDK documentation)
    @IBAction func testAuthQR() {
        let qrScanner = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        qrScanner.completion = { code in
            self.dismiss(animated: true) {
                if let scannedCode = code, scannedCode.isEmpty == false {
                    print("scanned code: \(scannedCode)")
                    self.handleScannedQR(scannedCode)
                }
            }
        }
        present(NavigationController(rootViewController: qrScanner), animated: true)
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

    // MARK: - private helpers
    
    private func handleScannedQR(_ payload: String) {
        let handler = eIDHandler()
        handler.setLogLevel(.verbose)
        handler.handleQRCode(from: self,
                             qrCodeData: payload,
                             apiKeyId: eIDEnvironment.selected.apiKeyId,
                             apiKeyValue: eIDEnvironment.selected.apiKeyValue) { res in
            if let err = res {
                print(">> result: \(err)")
                eIDErrorHandler.handleError(err, fromViewController: self, repeatAction: { [weak self] in
                    self?.handleScannedQR(payload)
                })
            }
            else {
                print(">> result: success")
            }
        }
    }
}
