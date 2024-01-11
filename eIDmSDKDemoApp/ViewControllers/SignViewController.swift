import UIKit
import CryptoKit
import eID

class SignViewController: eIDViewController {

    // MARK: - Constants

    private struct Constants {
        static let signatureScheme = "1.2.840.113549.1.1.11"
    }

    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    @IBOutlet private weak var certSlotLabel: UILabel!
    @IBOutlet private weak var certIndexLabel: UILabel!
    @IBOutlet private weak var certNameLabel: UILabel!
    @IBOutlet private weak var certSerialNumberLabel: UILabel!
    @IBOutlet private weak var certSchemesLabel: UILabel!
    @IBOutlet private weak var certValidityLabel: UILabel!
    @IBOutlet private weak var certOCSPLabel: UILabel!

    @IBOutlet private weak var hashLabel: UILabel!
    @IBOutlet private weak var signedHashLabel: UILabel!

    @IBOutlet private weak var certificateHolderView: UIView!
    @IBOutlet private weak var hashHolderView: UIView!
    @IBOutlet private weak var finishSigningButton: UIButton!
    @IBOutlet private weak var signedHashHolderView: UIView!

    private var sha256Hash: Data?
    private var certificate: Certificate?

    private var handler: eIDHandler?

    // MARK: - VC lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Podpis Formuláru"

        generateSha256Hash()

        certificateHolderView.isHidden = true
        hashHolderView.isHidden = true
        finishSigningButton.isHidden = true
        signedHashHolderView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - actions

    @IBAction private func startSigningTapped() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)

        let type: eIDCertificateIndex = segmentedControl.selectedSegmentIndex == 1 ? .ES : .QES

        // read certificates
        handler?.getCertificates(from: self, types: [type]) { [weak self] res in
            guard let sSelf = self else { return }
            switch res {
            case .success(let certificatesJSONString):
                let jsonData = Data(certificatesJSONString.utf8)
                if let certResponse = try? JSONDecoder().decode(GetCertificatesReponse.self, from: jsonData),
                   let cert = certResponse.certificates.first {
                    sSelf.certificate = cert
                    DispatchQueue.main.async {
                        sSelf.hashHolderView.isHidden = false
                        sSelf.hashLabel.text = self?.sha256Hash?.hexEncodedString(options: .upperCase, separator: " ")
                        sSelf.certificateHolderView.isHidden = false
                        sSelf.finishSigningButton.isHidden = false
                        sSelf.certSlotLabel.text = cert.slot
                        sSelf.certIndexLabel.text = "\(cert.certIndex)"
                        sSelf.certSchemesLabel.text = cert.supportedSchemes.joined(separator: "\n")
                        sSelf.certNameLabel.text = self?.certificate?.x509Certificate?.subject(oid: .commonName)?.first
                        sSelf.certSerialNumberLabel.text = self?.certificate?.x509Certificate?.subject(oid: .serialNumber)?.first
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            self?.scrollView.scrollToBottom(animated: true)
                        }
                    }
                }
                else {
                    let msg = "Chyba pri načítaní podpisového certifikátu."
                    eIDErrorHandler.handleError(.certificateReadFailed, message: msg, fromViewController: sSelf, repeatAction: sSelf.startSigningTapped)
                }
            case .failure(let error):
                let msg = "Chyba pri načítaní podpisového certifikátu."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.startSigningTapped)
            }
        }
    }

    @IBAction private func verifyCertificateTapped() {
        guard let cert = certificate else {
            showAlert(message: "Certifikát nie je načítaný", isSuccess: false)
            return
        }
        handler = eIDHandler()
        handler?.setLogLevel(.info)
        handler?.verifyCertificate(from: self,
                                   environment: eIDEnvironment.selected,
                                   certificateBase64String: cert.certData) { [weak self] res in
            switch res {
            case .success(let certJson):
                let jsonData = Data(certJson.utf8)
                if let certResponse = try? JSONDecoder().decode(VerifyCertResponse.self, from: jsonData) {
                    DispatchQueue.main.async {
                        print("resp: expiration=\(certResponse.result.expiration) verification=\(certResponse.result.verification)")
                        self?.certValidityLabel.text = certResponse.result.expiration
                        self?.certOCSPLabel.text = certResponse.result.verification
                    }
                }
            case .failure(let error):
                guard let sSelf = self else { return }
                let msg = "Chyba pri overovaní certifikátu."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf)
            }
        }
    }

    @IBAction private func finishSigningTapped() {

        guard let cert = self.certificate, let scheme = cert.supportedSchemes.first(where: {$0 == Constants.signatureScheme}) else {
            showAlert(message: "Nie je načítaný certifikát", isSuccess: false)
            return
        }

        handler?.signData(from: self,
                          certIndex: cert.certIndex,
                          signatureScheme: scheme,
                          dataToSign: self.sha256Hash?.base64EncodedString() ?? "") { [weak self] res in
            switch res {
            case .success(let dataBase64):
                DispatchQueue.main.async {
                    self?.signedHashHolderView.isHidden = false
                    self?.signedHashLabel.text = Data(base64Encoded: dataBase64)?.hexEncodedString(options: .upperCase, separator: " ")
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self?.scrollView.scrollToBottom(animated: true)
                    }
                }
            case .failure(let error):
                guard let sSelf = self else { return }
                let msg = "Chyba pri podpisovaní."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.finishSigningTapped)

            }
        }
    }

    // MARK: - helpers

    private func generateSha256Hash() {
        if let string = textField.text {
            sha256Hash = Data(Array(SHA256.hash(data: Data(string.utf8))))
            print("> \(sha256Hash!.hexEncodedString(options: .upperCase, separator: " "))")
        }
    }
}

// MARK: - text field delegate

extension SignViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        generateSha256Hash()
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        generateSha256Hash()
    }
}
