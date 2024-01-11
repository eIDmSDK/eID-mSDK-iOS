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

- pre účely deeplinkovania nastaviť schému `eid` v xCode rozhraní alebo manuálne v `Info.plist`
  ```
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>eid</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>eid</string>
      </array>
    </dict>
  </array>
  ```
- pre účely zabránenia MITM útokom nastaviť "CA Pinning" pridaním snippetu do súboru `Info.plist`
  ```
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSPinnedDomains</key>
    <dict>
      <key>eid.plaut.sk</key>
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
      <key>apigw.eid.plaut.sk</key>
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
      <key>login.eid.plaut.sk </key>
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
      <key>identity.eid.plaut.sk </key>
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
- eID.framework vyžaduje 3 dependencies, ktoré môžu byť integrované cez Swift Package Manager, CocoaPods, Carthage alebo ako zbuildovaný framework:
    * [OpenSSL](https://github.com/krzyzanowskim/OpenSSL)
    * [Lottie](https://github.com/airbnb/lottie-ios.git)
    * [JWTDecode](https://github.com/auth0/JWTDecode.swift)

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
                       environment: .plautDev,
                       clientID: "aclientid",
                       clientSecret: "aclientsecret",
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

- `SceneDelegate.swift` - handling QR kódov a deeplinking
- `ViewController.swift` - autentifikácia, autentifikácia cez QR, certifikáty, manažment znalostných kódov, tutoriál
- `SignViewController.swift` - načítanie certifikátu, overenie certifikátu, podpis
- `DecryptViewController.swift` - overenie certifikátu, dešifrovanie
