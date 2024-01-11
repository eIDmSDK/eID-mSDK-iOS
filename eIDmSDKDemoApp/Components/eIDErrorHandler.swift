import UIKit
import eID

struct eIDErrorHandler {

    static func handleError(_ error: eIDError,
                            message: String? = nil,
                            fromViewController viewController: UIViewController,
                            repeatAction: (()->())? = nil) {

        let errorText: String
        if let extraMessage = message {
            errorText = "\(extraMessage)\n\n\(error.localizedMessage)"
        }
        else {
            errorText = error.localizedMessage
        }

        if error.isUnfixableError {
            // show only error - this error type cant be fixed by repeating the action
            showErrorAlert(message: errorText, from: viewController)
        }
        else if error.isPinManagementError {
            // pin management should be suggested
            showErrorAlertWithAction(message: errorText, actionTitle: "Prejsť na PIN manažment") {
                eIDHandler().startPinManagement(from: viewController, completion: { _ in } )
            }
        }
        else if error.isFixableErrorWithNoAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                repeatAction?()
            }
        }
        else if error.isFixableError {
            // repeat should be suggested
            showErrorAlertWithAction(message: errorText, actionTitle: "Skúsiť znova", action: repeatAction ?? {})
        }
    }

    // MARK: - private

    private static func showErrorAlert(message: String, from viewController: UIViewController) {
        print(">> \(message)")

        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Chyba", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            viewController.present(alert, animated: true)
        }
    }

    private static func showErrorAlertWithAction(message: String, actionTitle: String, action: @escaping () -> ()) {
        print(">> \(message)")

        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Chyba", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                // needs to be called with a delay - alertVC takes a little while to dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    action()
                }
            }))
            alert.addAction(UIAlertAction(title: "Zrušiť", style: .cancel))

            UIApplication.topViewController()?.present(alert, animated: true)
        }
    }
}
