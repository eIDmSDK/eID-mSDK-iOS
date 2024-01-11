import Foundation
import eID

extension eIDError {

    var localizedMessage: String {
        switch self {
        case .unknownTag:
            return "Tento NFC tag nie je podporovaný."
        case .unsupportedCardType:
            return "Tento type karty nie je podporovaný."
        case .nfcNotSupported:
            return "Toto zariadenie nepodporuje NFC. Pre využívanie služieb eID budete potrebovať zariadenie s NFC."
        case .jailbreakDetected:
            return "Na tomto zariadení bol detegovaný Jaibreak alebo po ňom zostali stopy. Pre využívanie eID služieb použite zariadenie bez Jailbreak."
        case .certificatesNotIssued:
            return "Na Vašom OP nie sú vydané certifikáty. Certifikáty si môžete vydať cez desktopovú verziu eID klienta alebo na polícii."
        case .qrNotSupported:
            return "Tento formát QR kódu nie je podporovaný v eID."
        case .deeplinkNotSupported:
            return "Tento formát deeplink (URL) nie je podporovaný v eID."
        case .invalidClientIdOrSecret:
            return "Nesprávne zadané credentials. Prosím kontaktujte support vydavateľa tejto aplikácie."
        case .unsupportedSignatureScheme:
            return "Nepodaporovaná podpisová schéma. Prosím kontaktujte support vydavateľa tejto aplikácie."
        case .unsupportedSigningCertificate:
            return "Nepodporovaný podpisový certifikát. Prosím kontaktujte support vydavateľa tejto aplikácie."
        case .invalidCertificateIndex:
            return "Nesprávne zadaný index certifikátu. Prosím kontaktujte support vydavateľa tejto aplikácie."
        case .unsupportedDecryptionCertificate:
            return "Nesprávne zadaný index certifikátu. Prosím kontaktujte support vydavateľa tejto aplikácie."
        case .tagConnectionLost:
            return "Nastala strata NFC spojenia medzi mobilným zariadením a kartou. Prosím skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .cancelledByUser:
            return "Operácia bola zrušená používateľom."
        case .sessionTimeout:
            return "Vypršal čas na priloženie vášho Občianskeho preukazu k mobilnému zariadeniu. Ak ste nanašli správnu polohu na priloženie, pozrite si prosím znova tutoriál s názornými ukážkami spôsobu priloženia OP."
        case .certificateReadFailed:
            return "Nastala chyba pri načítavaní certifikátov. Prosím skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .signingFailed:
            return "Nastala chyba pri podpisovaní. Prosím skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .decryptionFailed:
            return "Dáta neboli podpísané verejným kľúčom tejto eID karty."
        case .authInitFailed:
            return "Nastala chyba pri inicializácii prihlasovania. Prosím skontrolujte si pripojenie na internet a skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .authCompletionFailed:
            return "Nastala chyba pri prihlasovaní. Prosím skontrolujte si pripojenie na internet a skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .unableToReadCodeStates:
            return "Nastala chyba pri zisťovaní stavov vašich kódov. Prosím skúste vykonať poslednú operáciu znova a držte Vaše mobilné zariadenie aj telefón stabilne."
        case .networkError(let msg):
            return "Nastala chyba pri komunikácii so serverom. Skontrolujte si prosím internetové pripojenie, prípadne kontaktuje support vydavateľa tejto aplikácie. (\(msg)"
        case .bokInvalid:
            return "Zadali ste nesprávny BOK. Zopakujte poslednú operáciu znova."
        case .bokSuspended:
            return "Váš BOK je suspendovaný. Odsuspendovať ho môžete v sekcii PIN manažment."
        case .bokBlocked:
            return "Váš BOK je blokovaný. Odblokovať ho môžete v sekcii PIN manažment."
        case .bokNotActivated:
            return "Váš BOK nie je aktivovaný. Aktivovať ho môžete na pracovisku polície."
        case .canInvalid:
            return "Zadali ste nesprávny CAN. Zopakujte poslednú operáciu znova."
        case .kepPinInvalid:
            return "Zadali ste nesprávny KEP PIN (podpisový PIN kód). Zopakujte poslednú operáciu znova."
        case .kepPinSuspended:
            return "Váš KEP PIN (podpisový PIN) je suspendovaný. Odsuspendovať ho môžete v sekcii PIN manažment."
        case .kepPinBlocked:
            return "Váš KEP PIN (podpisový PIN) je blokovaný. Odblokovať ho môžete v sekcii PIN manažment."
        case .kepPinNotActivated:
            return "Váš KEP PIN (podpisový PIN) nie je aktivovaný. Aktivovať ho môžete pri vydávaní certifikátov na desktopovom eID kliente alebo na pracovisku polície."
        case .usedTCTokenQRCode:
            return "QR kód už bol použitý. Prosím, vygenerujte si nový QR kód vo webovom priehliadači na vašom počítači kliknutím na prihlásenie na hlavnej srtránke."
        case .unsupportedSDKVersion:
            return "Táto verzia aplikácie nie je už podporovaná. Aktualizujte si prosím verziu aplikácie."
        case .mrzInvalid:
            return "Naskenovaý MRZ z vášho dokladu je neplatný. Skúste prosím znova."
        case .userDataReadFailed:
        return "Nepodarilo sa načítať údaje z dokladu. Skúste prosím znova."
        @unknown default:
            return "Operácia neprebehla úspešne (neznáma chyba). Skúste prosím znova alebo kontaktujte support vydavateľa tejto aplikácie."
        }
    }

    var isUnfixableError: Bool {
        [eIDError.unknownTag,
         .unsupportedCardType,
         .usedTCTokenQRCode,
         .nfcNotSupported,
         .jailbreakDetected,
         .unsupportedSDKVersion,
         .certificatesNotIssued,
         .qrNotSupported,
         .deeplinkNotSupported,
         .invalidClientIdOrSecret,
         .unsupportedSignatureScheme,
         .unsupportedSigningCertificate,
         .invalidCertificateIndex,
         .unsupportedDecryptionCertificate,
         .cancelledByUser,
         .decryptionFailed,
         .bokNotActivated,
         .kepPinNotActivated,
         .mrzInvalid].contains(self)
    }

    var isPinManagementError: Bool {
        [eIDError.bokSuspended,
         .bokBlocked,
         .kepPinSuspended,
         .kepPinBlocked].contains(self)
    }

    var isFixableError: Bool {
        if case .networkError = self {
            return true
        }
        else if [eIDError.tagConnectionLost,
                 .sessionTimeout,
                 .usedTCTokenQRCode,
                 .certificateReadFailed,
                 .signingFailed,
                 .authInitFailed,
                 .authCompletionFailed,
                 .userDataReadFailed,
                 .unableToReadCodeStates].contains(self) {
            return true
        }
        else {
            return false
        }
    }

    var isFixableErrorWithNoAlert: Bool {
        [eIDError.canInvalid,
         .bokInvalid,
         .kepPinInvalid].contains(self)
    }
}
