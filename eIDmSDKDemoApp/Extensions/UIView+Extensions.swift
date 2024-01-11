import UIKit

extension UIView {

    func dropShadow(_ radius: Float = 10, color: UIColor = Color.shadow, opacity: Float = 0.7) {
        layer.shadowRadius = CGFloat(radius)
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
    }

    func roundCorners(_ radius: Float? = nil) {
        if let radius = radius {
            layer.cornerRadius = CGFloat(radius)
        }
        else {
            layer.cornerRadius = frame.height/2.0
        }
    }
}

extension UIView {
    class func loadFromNib<T>(_ name: String = String(describing: T.self), owner: AnyObject? = nil, options: [AnyHashable: Any]? = nil, bundle: Bundle? = nil) -> T {
        return UINib(nibName: name, bundle: bundle).instantiate(withOwner: owner, options: options as? [UINib.OptionsKey : Any]).first as! T
    }

    class func loadFromNib<T>(_ name: String = String(describing: T.self), index: Int) -> T {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[index] as! T
    }
}
