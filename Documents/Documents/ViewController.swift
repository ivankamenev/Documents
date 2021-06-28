//
//  ViewController.swift
//  Documents
//
//  Created by  Ivan Kamenev on 28.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Фотографии"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addPhoto))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        setupViews()
    }
    
    @objc private func addPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupViews() {
        let contraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(contraints)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let fileName = UUID().uuidString + ".jpg"
        let fileUrl = documentsDirectory.appendingPathComponent(fileName)
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            if let data = image.jpegData(compressionQuality: 1.0),
               !FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    try data.write(to: fileUrl)
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
                
            }
        }
        tableView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsHiddenFiles])
            count = contents.count
        } catch {
            print("Ошибка получения контента")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        do {
            var contents = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsHiddenFiles])
            switch userDefaults.string(forKey: "sortedOrder") {
            case "alphabet_order":
                contents.sort(by: {$0.absoluteString < $1.absoluteString})
            case "reverce_alphabet_order":
                contents.sort(by: {$0.absoluteString > $1.absoluteString})
            default:
                break
            }
            let image = UIImage(contentsOfFile: contents[indexPath.item].path)
            tableViewCell.photoImage = image
            return tableViewCell
        } catch {
            print("Ошибка получения контента")
            return tableViewCell
        }
    }
    
}
