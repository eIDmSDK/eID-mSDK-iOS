import UIKit

class MenuButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 5
        backgroundColor = Color.buttonBg
        tintColor = Color.buttonText
        setTitleColor(Color.buttonText, for: .normal)
    }
}
