//
//  LoginViewController.swift
//  Documents
//
//  Created by  Ivan Kamenev on 28.06.2021.
//

import UIKit
import KeychainAccess

class LoginViewController: UIViewController {
    
    private let keychain = Keychain(service: "demo")
    private var firstEnteredPassword = ""
    private var secondEnteredPassword = ""
    var changePasswordFlag = false
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Введите пароль"
        field.isSecureTextEntry = true
        return field
    }()
    
    private let passwordView: UIView = {
        let someView = UIView()
        someView.translatesAutoresizingMaskIntoConstraints = false
        someView.clipsToBounds = true
        someView.backgroundColor = .none
        someView.layer.borderWidth = 2
        someView.layer.cornerRadius = 8
        someView.layer.borderColor = UIColor.systemGray2.cgColor
        someView.backgroundColor = .white
        return someView
    }()
    
    private let passwordActionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor.systemIndigo
        button.addTarget(self, action: #selector(passwordActionButtonTapped), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBlue
        passwordTextField.delegate = self
        passwordActionButton.isUserInteractionEnabled = false
        passwordActionButton.alpha = 0.5
        setupViews()
    }
    
    @objc private func passwordActionButtonTapped() {
        if let text = passwordTextField.text {
            if text.count != 4 {
                showAlert(type: .passwordLengthIsIncorrect)
            } else {
                if keychain["test"] == nil || changePasswordFlag {
                    if firstEnteredPassword.isEmpty {
                        firstEnteredPassword = text
                        passwordActionButton.setTitle("Повторите пароль", for: .normal)
                        passwordTextField.text = ""
                    } else {
                        if text == firstEnteredPassword {
                            keychain["test"] = text
                            showNextScreen()
                        } else {
                            showAlert(type: .enteredPasswordsNotMatch)
                            firstEnteredPassword = ""
                            passwordActionButton.setTitle("Создать пароль", for: .normal)
                            passwordTextField.text = ""
                        }
                    }
                } else {
                    if text == keychain["test"] {
                        showNextScreen()
                    } else {
                        showAlert(type: .incorrectPassword)
                    }
                }
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(contentView)
        
        contentView.addSubview(passwordView)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(passwordActionButton)
        
        let constraints = [
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordView.topAnchor.constraint(equalTo: contentView.topAnchor),
            passwordView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordView.topAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordView.leadingAnchor, constant: 10),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordView.trailingAnchor, constant: -10),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: -10),
            
            passwordActionButton.topAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: 20),
            passwordActionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordActionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            passwordActionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        if keychain["test"] == nil || changePasswordFlag {
            passwordActionButton.setTitle("Создать пароль", for: .normal)
        } else {
            passwordActionButton.setTitle("Введите пароль", for: .normal)
        }
    }
    
    private func showAlert(type: AlertsTypes) {
        switch type {
        
        case .passwordLengthIsIncorrect:
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Длинна пароля должна быть 4 символа",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        case .enteredPasswordsNotMatch:
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Пароли не совпадают",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        case .incorrectPassword:
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Неверный пароль",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showNextScreen() {
        if changePasswordFlag {
            self.dismiss(animated: true, completion: nil)
        } else {
            let tabBarController = UITabBarController()
            let viewController = ViewController()
            let settingsViewController = SettingsViewController()
            let embedPhotosInNavigation = UINavigationController(rootViewController: viewController)
            viewController.tabBarItem = UITabBarItem(title: "Фото", image: UIImage(systemName: "photo"), tag: 1)
            settingsViewController.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape"), tag: 2)
            settingsViewController.reloadPhotosTableView = viewController.reloadTableView
            tabBarController.setViewControllers([embedPhotosInNavigation, settingsViewController], animated: true)
            self.navigationController?.pushViewController(tabBarController, animated: true)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.text != nil else { return true }
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty {
            passwordActionButton.isUserInteractionEnabled = true
            passwordActionButton.alpha = 1.0
        } else {
            passwordActionButton.isUserInteractionEnabled = false
            passwordActionButton.alpha = 0.5
        }
        return true
    }
}

enum AlertsTypes {
    case passwordLengthIsIncorrect
    case enteredPasswordsNotMatch
    case incorrectPassword
}
