import UIKit

enum Mode {
    case createPassword
    case confirmPassword
    case signIn
}

class LoginViewController: UIViewController {
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalCentering
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(passwordTextField)
        stack.addArrangedSubview(button)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 1
        textField.textAlignment = .center
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonIsTapped), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let password = PasswordManager()
    
    private var mode: Mode = .createPassword {
        didSet {
            titleLabel.text = screenName
            button.setTitle(buttonTitle, for: .normal)
            passwordTextField.placeholder = textFieldPlaceHolder
        }
    }
    
    private var firstRunMode: Mode = .createPassword
    
    private var screenName: String {
        switch mode {
        case .createPassword,
                .confirmPassword:
            return "Sing Up"
        case .signIn:
            return "Sign In"
        }
    }
    
    private var buttonTitle: String {
        switch mode {
        case .createPassword:
            return "Create password"
        case .confirmPassword:
            return "Confirm password"
        case .signIn:
            return "Login"
        }
    }
    
    private var textFieldPlaceHolder: String {
        switch mode {
        case .createPassword:
            return "Enter password"
        case .confirmPassword:
            return "Re-enter password"
        case .signIn:
            return "Enter password"
        }
    }
    
    private var passwordInput: String = ""
    private var initialPasswordInput: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setLoginMode()
    }
    
    private func setLoginMode() {
        if password.isSet {
            mode = .signIn
        } else {
            mode = .createPassword
        }
    }
    
    private func layout () {
        view.addSubview(stackView)
        view.backgroundColor = .white
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
    }
    
    @objc private func buttonIsTapped(_ sender: Any) {
        let entry = passwordTextField.text ?? ""
        
        guard entry != "" else {
            errorAlert(text: "Required password")
            return
        }
        
        guard entry.count > 3 else {
            passwordTextField.text = ""
            errorAlert(text: "Password is too short")
            return
        }
        
        switch mode {
        case .createPassword:
            initialPasswordInput = entry
            passwordTextField.text = ""
            mode = .confirmPassword
            
        case .confirmPassword:
            passwordInput = entry
            if passwordInput == initialPasswordInput {
                password.save(passwordInput) { (success, error) in
                    guard success,
                          error == nil else {
                        if let error = error {
                            self.errorAlert(text: "\(error.localizedDescription)")
                        }
                        return
                    }
                    self.successLogIn()
                }
            } else {
                errorAlert(text: "Passwords don't match")
                passwordInput = ""
                initialPasswordInput = ""
                passwordTextField.text = ""
                mode = .createPassword
                return
            }
        case .signIn:
            passwordInput = entry
            guard password.isValid(passwordInput) else {
                errorAlert(text: "Password is wrong, try again")
                passwordTextField.text = ""
                return
            }
            successLogIn()
        }
    }
    
    private func successLogIn() {
        navigationController?.pushViewController(createTabBarController(), animated: true)
    }
    
    private func createNavigationBar(for screenType: ScreenType) -> UINavigationController {
        let navController: UINavigationController
        switch screenType {
        case .documents:
            let documentsVC = TableViewController(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
            documentsVC.tabBarItem = UITabBarItem(title: "Documents", image: UIImage(systemName: "folder"), tag: 0)
            navController = UINavigationController(rootViewController: documentsVC)
        case .settings:
            let settingsVC = SettingsTableViewController()
            settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
            navController = UINavigationController(rootViewController: settingsVC)
        }
        return navController
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            createNavigationBar(for: .documents),
            createNavigationBar(for: .settings)]
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.isHidden = true
        return tabBarController
    }
    
    private func errorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
