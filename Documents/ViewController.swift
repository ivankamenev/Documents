//
//  ViewController.swift
//  Documents
//
//  Created by Ivan Kamenev on 17.06.2021.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let userDefaults = UserDefaults.standard
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let imagePicker = UIImagePickerController()
    private var images = [URL]()
    
    override func viewDidAppear(_ animated: Bool) {
        getFiles()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        setupViews()
        setupTableView()
    }
    
    @IBAction func addButtonPresse(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
                
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    private func setupViews() {
        view.addSubview(tableView)
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.register(
            TableViewCell.self,
            forCellReuseIdentifier: String(describing: TableViewCell.self)
        )
    }
    
// MARK: - UIImagePickerControllerDelegate Methods
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageURL = info[.imageURL] as! URL
        print(imageURL)
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,   appropriateFor: nil, create: false)
        let newimage = documentsUrl.appendingPathComponent(imageURL.lastPathComponent)
        if !FileManager.default.fileExists(atPath: newimage.path) {
            try? FileManager.default.copyItem(at: imageURL, to: newimage)
        }
        getFiles()
        tableView.reloadData()

        dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func getFiles() {
        images.removeAll()
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,   appropriateFor: nil, create: false)
        
        let contents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        for file in contents {
            images.append(file)
        }
        
        if userDefaults.bool(forKey: "abc") {
            images.sort {
                $0.lastPathComponent > $1.lastPathComponent
            }
        } else {
            images.sort {
                $0.lastPathComponent < $1.lastPathComponent
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        cell.file = images[indexPath.row]
        return cell
    }
    
}

extension UIViewController {

    var isModal: Bool {

        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

