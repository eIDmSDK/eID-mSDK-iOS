import UIKit

class eIDViewController: UIViewController {

    func showAlert(message: String, isSuccess: Bool) {
        print(">> \(message)")

        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: isSuccess ? "Operácia úspešná" : "Chyba", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self?.present(alert, animated: true)
        }
    }

    func showAlertWithAction(message: String, isSuccess: Bool, actionTitle: String, action: @escaping () -> ()) {
        print(">> \(message)")

        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: isSuccess ? "Operácia úspešná" : "Chyba", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                action()
            }))
            alert.addAction(UIAlertAction(title: "Zrušiť", style: .cancel))

            self?.present(alert, animated: true)
        }
    }
}
