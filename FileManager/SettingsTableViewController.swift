
import UIKit

class SettingsTableViewController: UITableViewController {
    
    private var data = ["Sort", "Show file size", "Change password"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        if indexPath.row == 0 {
            let sw = UISwitch()
            sw.isOn = UserDefaults.standard.string(forKey: "sort") == "1"
            sw.addTarget(self, action: #selector(stateSortChanged), for: .valueChanged)
            cell.accessoryView = sw
        }
        if indexPath.row == 1 {
            let sw = UISwitch()
            sw.isOn = UserDefaults.standard.string(forKey: "size") == "1"
            sw.addTarget(self, action: #selector(stateSizeChanged), for: .valueChanged)
            cell.accessoryView = sw
        }
        return cell
    }
    
    @objc func stateSortChanged() {
        if UserDefaults.standard.string(forKey: "sort") == "1" {
            UserDefaults.standard.set("0", forKey: "sort")
        } else {
            UserDefaults.standard.set("1", forKey: "sort")
        }
        NotificationCenter.default.post(name: NSNotification.Name.needToReloadTableView, object: nil)
    }
    
    @objc func stateSizeChanged() {
        if UserDefaults.standard.string(forKey: "size") == "1" {
            UserDefaults.standard.set("0", forKey: "size")
        } else {
            UserDefaults.standard.set("1", forKey: "size")
        }
        NotificationCenter.default.post(name: NSNotification.Name.needToReloadTableView, object: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let loginVC = LoginViewController()
            let pass = PasswordManager()
            pass.remove()
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}
