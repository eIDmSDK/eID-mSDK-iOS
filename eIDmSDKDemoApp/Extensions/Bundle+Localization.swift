import Foundation

var _bundle: UInt8 = 0

class BundleEx: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &_bundle) as? Bundle

        if let temp = bundle {
            return temp.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

public extension Bundle {
    func setLanguage(_ language: String?) {
        let oneToken: String = "sk.plaut.eid.msdk"

        DispatchQueue.once(token: oneToken) {
            object_setClass(self, BundleEx.self)
        }

        if let lang = language {
            objc_setAssociatedObject(self, &_bundle, Bundle(path: path(forResource: lang, ofType: "lproj")!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            objc_setAssociatedObject(self, &_bundle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
