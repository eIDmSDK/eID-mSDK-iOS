import UIKit
import eID

class EnvironmentsViewController: UIViewController {

    let environments: [eIDEnvironment] = [.plautDev, .plautTest, .minvTest, .minvProd]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension EnvironmentsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return environments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        cell.textLabel?.text = environments[indexPath.row].environmentKey
        cell.accessoryType = environments[indexPath.row] == eIDEnvironment.selected ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eIDEnvironment.selected = environments[indexPath.row]
        tableView.reloadData()
    }
}
