import UIKit
import ASN1Decoder
import eID

class DecryptViewController: eIDViewController {

    // MARK: - Constants

    private struct Constants {
        static let signatureScheme = "1.2.840.113549.1.1.11"
        static let secKeyAlgorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
    }
    
    // MARK: - Properties

    @IBOutlet private weak var textField: UITextField!

    @IBOutlet private weak var certSlotLabel: UILabel!
    @IBOutlet private weak var certIndexLabel: UILabel!
    @IBOutlet private weak var certNameLabel: UILabel!
    @IBOutlet private weak var certSerialNumberLabel: UILabel!
    @IBOutlet private weak var certSchemesLabel: UILabel!
    @IBOutlet private weak var certValidityLabel: UILabel!
    @IBOutlet private weak var certOCSPLabel: UILabel!

    @IBOutlet private weak var encodedDataLabel: UILabel!
    @IBOutlet private weak var decodedDataLabel: UILabel!

    @IBOutlet private weak var certificateHolderView: UIView!
    @IBOutlet private weak var encodedDataHolderView: UIView!
    @IBOutlet private weak var decodeButton: UIButton!
    @IBOutlet private weak var decodedDataHolderView: UIView!

    private var encryptedData: Data?
    private var certificate: Certificate?

    private var handler: eIDHandler?

    // MARK: - VC lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Dešifrovanie dát"

        certificateHolderView.isHidden = true
        encodedDataHolderView.isHidden = true
        decodeButton.isHidden = true
        decodedDataHolderView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - actions

    @IBAction private func encodeTapped() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)

        // read certificates
        handler?.getCertificates(from: self, types: [.Encryption]) { [weak self] res in
            guard let sSelf = self else { return }
            switch res {
            case .success(let certificatesJSONString):
                let jsonData = Data(certificatesJSONString.utf8)
                if let certResponse = try? JSONDecoder().decode(GetCertificatesReponse.self, from: jsonData),
                   let cert = certResponse.certificates.first {
                    self?.certificate = cert
                    DispatchQueue.main.async {
                        self?.encryptedData = self?.signData(self?.textField.text?.data(using: .utf8) ?? Data(), certData: Data(base64Encoded: cert.certData) ?? Data(), algorithm: Constants.secKeyAlgorithm)
                        self?.encodedDataHolderView.isHidden = false
                        self?.encodedDataLabel.text = self?.encryptedData?.hexEncodedString(options: .upperCase, separator: " ")
                        self?.certificateHolderView.isHidden = false
                        self?.decodeButton.isHidden = false
                        self?.certSlotLabel.text = cert.slot
                        self?.certIndexLabel.text = "\(cert.certIndex)"
                        self?.certSchemesLabel.text = cert.supportedSchemes.joined(separator: "\n")
                        self?.certNameLabel.text = self?.certificate?.x509Certificate?.subject(oid: .commonName)?.first
                        self?.certSerialNumberLabel.text = self?.certificate?.x509Certificate?.subject(oid: .serialNumber)?.first
                    }
                }
                else {
                    let msg = "Chyba pri načítaní šifrovacieho certifikátu."
                    eIDErrorHandler.handleError(.certificateReadFailed, message: msg, fromViewController: sSelf, repeatAction: sSelf.encodeTapped)
                }
            case .failure(let error):
                let msg = "Chyba pri načítaní šifrovacieho certifikátu."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.encodeTapped)
            }
        }
    }

    @IBAction private func decodeTapped() {
        handler = eIDHandler()
        handler?.setLogLevel(.info)

        handler?.decryptData(from: self,
                             certIndex: eIDCertificateIndex.Encryption.rawValue,
                             dataToDecrypt: (self.encryptedData ?? Data()).base64EncodedString()) { [weak self] res in
            switch res {
            case .success(let dataBase64):
                let msg = "successfully decrypted data:\n\(Data(base64Encoded: dataBase64)?.hexEncodedString(separator: " ") ?? "")"
                print(msg)
                DispatchQueue.main.async { [weak self] in
                    self?.decodedDataHolderView.isHidden = false
                    self?.decodedDataLabel.text = String(data: Data(base64Encoded: dataBase64) ?? Data(), encoding: .utf8)
                }
            case .failure(let error):
                guard let sSelf = self else { return }
                let msg = "Chyba pri dešifrovaní."
                eIDErrorHandler.handleError(error, message: msg, fromViewController: sSelf, repeatAction: sSelf.decodeTapped)
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

    // MARK: - helpers

    func signData(_ data: Data, certData: Data, algorithm: SecKeyAlgorithm) -> Data? {

        if let secCertificate = SecCertificateCreateWithData(nil, certData as CFData),
           let secKey = SecCertificateCopyKey(secCertificate) {

            let cfData = SecKeyCreateEncryptedData(secKey, algorithm, data as NSData, nil)
            return cfData as? Data
        }
        return nil
    }

}

// MARK: - text field delegate

extension DecryptViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
