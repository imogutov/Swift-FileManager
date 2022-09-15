//
//  TableViewController.swift
//  FileManager
//
//  Created by Иван Могутов on 15.09.2022.
//

import UIKit

class TableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var url: URL
    
    var files: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil))!
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let addFolderButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(createNewFolder))
        let addFileButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createNewFile))
        self.navigationItem.rightBarButtonItems = [addFileButton, addFolderButton]
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "\(url.lastPathComponent)"
    }
    
    @objc private func createNewFolder(_ sender: Any) {
        let alertController = UIAlertController(title: "Creating New Folder", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter foler name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { action in
            if let folderName = alertController.textFields?[0].text,
               folderName != "" {
                let newURL = self.url.appendingPathComponent(folderName)
                do {
                    try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
                } catch {
                    print(error)
                }
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc private func createNewFile(_ sender: Any) {
        let alert = UIAlertController(title: "What type of file you want to create?", message: "Choose one:", preferredStyle: .actionSheet)
        let textFileAction = UIAlertAction(title: "New Text File", style: .default) { action in
            let alertController = UIAlertController(title: "Creating text file", message: nil, preferredStyle: .alert)
            alertController.addTextField { textfield in
                textfield.placeholder = "Enter file name"
            }
            alertController.addTextField { textfield in
                textfield.placeholder = "Enter the text of the new file"
            }
            let createAction = UIAlertAction(title: "Create", style: .default) { action in
                if let fileName = alertController.textFields?[0].text,
                   fileName != "",
                   let contentsOfFile = alertController.textFields?[1].text,
                   let data = contentsOfFile.data(using: .utf8) {
                    
                    let newURL = self.url.appendingPathComponent(fileName)
                    FileManager.default.createFile(atPath: newURL.path, contents: data, attributes: [:])
                    self.tableView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(createAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
        
        let photoAction = UIAlertAction(title: "New Image", style: .default) { action in
            self.showImagePicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(textFileAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let alertController = UIAlertController(title: "Save Image", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter image name"
        }
        
        let saveImageAction = UIAlertAction(title: "Save", style: .default) { action in
            if let imageName = alertController.textFields?[0].text,
               imageName != "",
               let data = image.pngData() {
                let imagePath = self.url.appendingPathComponent(imageName)
                FileManager.default.createFile(atPath: imagePath.path, contents: data, attributes: nil)
                self.tableView.reloadData()
            }
        }
        
        dismiss(animated: true)
        alertController.addAction(saveImageAction)
        present(alertController, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let item = files[indexPath.row]
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue == true {
            cell.detailTextLabel?.text = "Folder"
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.detailTextLabel?.text = "File"
        }
        cell.textLabel?.text = item.lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = files[indexPath.row]
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue {
            let tvc = TableViewController(url: item)
            navigationController?.pushViewController(tvc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = files[indexPath.row]
            do {
                try FileManager.default.removeItem(at: item)
            } catch {
                print(error)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
