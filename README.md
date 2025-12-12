# eID-mSDK-iOS

eID mSDK knižnica pre iOS a Demo aplikácia demonštrujúca použitie eID mSDK.

<br/>

# eID mSDK

Knižnica je vybuildovaná ako `eID.framework` v adresári `eIDmSDKDemoApp/Frameworks`

<br/>

## Inštalácia / integrácia

- Drag’n‘Drop `eID.framework` súbor do xCode projektu
- pridať framework do `Target Dependencies` a nastaviť `Embed & Sign`
- v `Signing & Capabilities` pridať `Near Field Communication Tag Reading` (bude vygenerovaný `.entitlements` súbor
- v `Info.plist` pridať `NFCReaderUsageDescription` s textom popisujúcim účel použitia NFC
- do `Info.plist` súboru doplniť zoznam podporovaných AIDs na kartách
  ```
  <key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
  <array>
    <string>A0000000770108700A1000FE00000400</string>
    <string>E80704007F00070302</string>
  </array>
  ```
- pre účely zabránenia MITM útokom nastaviť "CA Pinning" pridaním snippetu do súboru `Info.plist`
  ```
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSPinnedDomains</key>
    <dict>
      <key>eidas.minv.sk</key>
      <dict>
        <key>NSIncludesSubdomains</key>
        <true/>
        <key>NSPinnedCAIdentities</key>
        <array>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>cCEWzNi/I+FkZvDg26DtaiOanBzWqPWmazmvNZUCA4U=</string>
          </dict>
        </array>
      </dict>
      <key>teidas.minv.sk</key>
      <dict>
        <key>NSIncludesSubdomains</key>
        <true/>
        <key>NSPinnedCAIdentities</key>
        <array>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=</string>
          </dict>
          <dict>
            <key>SPKI-SHA256-BASE64</key>
            <string>cCEWzNi/I+FkZvDg26DtaiOanBzWqPWmazmvNZUCA4U=</string>
          </dict>
        </array>
      </dict>
    </dict>
  </dict>
  ```
- eID.framework používa 2 fonty, ktoré je potrebné nakopírovať do xCode projektu a zadefinovať v `Info.plist` (fonty sa nachádzajú v adresári `eIDmSDKDemoApp/Resources/fonts`)
  ```
  <key>UIAppFonts</key>     
  <array>
    <string>SourceSansPro-Regular.ttf</string>
    <string>SourceSansPro-Bold.ttf</string>
  </array>
  ```
- eID.framework vyžaduje 2 dependencies, ktoré môžu byť integrované cez Swift Package Manager, CocoaPods, Carthage alebo ako zbuildovaný framework:
    * [OpenSSL](https://github.com/krzyzanowskim/OpenSSL)
    * [Lottie](https://github.com/airbnb/lottie-ios.git)

<br/>

## Použitie eID mSDK

**eID mSDK** poskytuje nasledujúce hlavné okruhy **funkcionalít**:
1.	**Autentifikácia** osoby na **najvyššej úrovni** zabezpečenia (Vysoká) podľa eIDAS
2.	**Zobrazenie certifikátov** z občianskeho preukazu
3.	Vyhotovenie **kvalifikovaného elektronického podpisu**
4.	**Manažment znalostných faktorov** (BOK, KEP PIN, PUK)

Kompletná API a integračnú dokumentácia je dostupná na https://github.com/eIDmSDK/eID-mSDK-Dokumentacia

### Autentifikácia
```swift
eIDHandler().startAuth(from: self,
                       environment: .minvTest,
                       clientID: "aclientid",
                       apiKeyId: "apiKeyId",
                       apiKeyValue: "apiKeyValue",
                       nonce: UUID().uuidString,
                       completion: { res in
    print(">> result: \(res)")
}
```

### Zobrazenie certifikátov
```swift
eIDHandler().getCertificates(from: self,
                             types: [.ES, .QES],
                             completion: { res in
    print(">> result: \(res)")
}
```

### Vyhotovenie kvalifikovaného elektronického podpisu
```swift
eIDHandler().signData(from: self,
                      certIndex: 1,
                      signatureScheme: "1.2.840.113549.1.1.11",
                      dataToSign: "base64hashedData",
                      completion: { res in
    print(">> result: \(res)")
}
```

### Manažment znalostných faktorov (BOK, KEP PIN, PUK
```swift
eIDHandler().startPinManagement(from: self,
                                completion: { res in
    print(">> result: \(res)")
}
```

<br/>

## Knižnice tretích strán

eID mSDK v rámci svojej funkčnosti používa nasledujúce knižnice s otvoreným zdrojovým kódom:

* OpenSSL (Apache License 2.0) - https://github.com/krzyzanowskim/OpenSSL/blob/main/LICENSE.txt
* Lottie (Apache License 2.0) - https://github.com/airbnb/lottie-ios/blob/master/LICENSE
* JWTDecode (MIT license) - https://github.com/auth0/JWTDecode.swift/blob/master/LICENSE

<br/>

# eID mSDK Demo App

iOS aplikácia, ktorá integruje eID mSDK API a demonštruje funkcionalitu tejto knižnice.

<br/>

## Konfigurácia

- aplikáciu je možné spustiť len na iOS zariadení, nie v simulátore
- v xCode je potrebné si nastaviť `bundleId` a nakonfigurovať `Signing`
- v prípade potreby zvoliť reset packages (cez SPM sú nalinkované 3 dependencies)
- v súbore `Environments.swift` zadať `clientId` a `clientSecret` pre jednotlivé prostredia (viac v integračnej dokumentácii na https://github.com/eIDmSDK/eID-mSDK-Dokumentacia)

<br/>

## Navigácia v aplikácii

- `ViewController.swift` - autentifikácia, certifikáty, manažment znalostných kódov, tutoriál
- `SignViewController.swift` - načítanie certifikátu, overenie certifikátu, podpis
- `DecryptViewController.swift` - overenie certifikátu, dešifrovanie
