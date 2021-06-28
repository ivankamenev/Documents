//
//  SettingsViewController.swift
//  Documents
//
//  Created by  Ivan Kamenev on 28.06.2021.
//

import UIKit
import KeychainAccess

class SettingsViewController: UIViewController {

    public var reloadPhotosTableView: (() -> Void)?
    
    private let userDefaults = UserDefaults.standard
    
    private let keychain = Keychain(service: "demo")
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сортировать:"
        return label
    }()
    
    private let sortSegmentedControl: UISegmentedControl = {
        let items = ["A → Z", "Z → A"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(sortedMethodDidChanged(_:)), for: .valueChanged)
        
        return segmentedControl
    }()
    
    private let changePasswortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сменить пароль", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        return button
    }()
    
    private let contentView: UIView = {
        let someView = UIView()
        someView.translatesAutoresizingMaskIntoConstraints = false
        return someView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSortSegmentedControl()
        setupViews()
    }
    
    private func setupSortSegmentedControl() {
        if userDefaults.string(forKey: "sortedOrder") == nil {
            sortSegmentedControl.selectedSegmentIndex = 0
            userDefaults.setValue("alphabet_order", forKey: "sortedOrder")
            if reloadPhotosTableView != nil {
                reloadPhotosTableView!()
            }
        }
        switch userDefaults.string(forKey: "sortedOrder") {
        case "alphabet_order":
            sortSegmentedControl.selectedSegmentIndex = 0
        case "reverce_alphabet_order":
            sortSegmentedControl.selectedSegmentIndex = 1
        default:
            break
        }
    }
    
    @objc private func changePassword() {
        let loginViewController = LoginViewController()
        loginViewController.changePasswordFlag = true
        present(loginViewController, animated: true, completion: nil)
    }
    
    @objc private func sortedMethodDidChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            userDefaults.setValue("alphabet_order", forKey: "sortedOrder")
            if reloadPhotosTableView != nil {
                reloadPhotosTableView!()
            }
        case 1:
            userDefaults.setValue("reverce_alphabet_order", forKey: "sortedOrder")
            if reloadPhotosTableView != nil {
                reloadPhotosTableView!()
            }
        default:
            return
        }
    }
    
    private func setupViews() {
        view.addSubview(contentView)
        contentView.addSubview(sortLabel)
        contentView.addSubview(changePasswortButton)
        contentView.addSubview(sortSegmentedControl)
        
        let constraints = [
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            sortLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            sortLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            sortSegmentedControl.centerYAnchor.constraint(equalTo: sortLabel.centerYAnchor),
            sortSegmentedControl.leadingAnchor.constraint(equalTo: sortLabel.trailingAnchor, constant: 10),
            
            changePasswortButton.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 20),
            changePasswortButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            changePasswortButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
