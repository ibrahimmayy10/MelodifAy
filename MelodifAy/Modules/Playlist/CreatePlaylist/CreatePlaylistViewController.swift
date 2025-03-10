//
//  CreatePlaylistViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 7.03.2025.
//

import UIKit

class CreatePlaylistViewController: UIViewController {
    
    private let playlistLabel = Labels(textLabel: "Çalma listeni oluştur", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.placeholder = "Çalma listenin ismini yaz"
        return textField
    }()
    
    private let createPlaylistButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.setTitle("Oluştur", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let changeImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Görseli değiştir", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        return button
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    var music: MusicModel?
    
    var selectedImage: UIImage?
    
    private let viewModel = CreatePlaylistViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureWithExt()
        addTargetButtons()
        setDelegate()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: nameTextField.frame.height + 5, width: nameTextField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.systemGray4.cgColor
        
        nameTextField.layer.addSublayer(bottomLine)
        
        createPlaylistButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    func setDelegate() {
        nameTextField.delegate = self
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(changeImageButton_Clicked), for: .touchUpInside)
        createPlaylistButton.addTarget(self, action: #selector(createPlaylistButton_Clicked), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func createPlaylistButton_Clicked() {
        guard let music = music, let playlistName = nameTextField.text, !playlistName.isEmpty else {
            showAlert(title: "Hata", message: "Çalma listesi adı boş olamaz.")
            return
        }
        
        var musicIDs = [String]()
        musicIDs.append(music.musicID)
        
        activityIndicator.startAnimating()
        createPlaylistButton.setTitle("", for: .normal)
        
        viewModel.createPlaylist(name: playlistName, musicIDs: musicIDs, image: selectedImage ?? UIImage()) { success, errorMessage in
            self.activityIndicator.stopAnimating()
            self.createPlaylistButton.setTitle("Oluştur", for: .normal)
            
            if success {
                DispatchQueue.main.async {
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            } else if let errorMessage = errorMessage {
                self.showAlert(title: "Hata", message: errorMessage)
            }
        }
    }
    
    @objc func changeImageButton_Clicked() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }

}

extension CreatePlaylistViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        setMusicInfo()
    }
    
    func setMusicInfo() {
        guard let music = music else { return }
        
        imageView.sd_setImage(with: URL(string: music.coverPhotoURL)) { [weak self] image, _, _, _ in
            self?.selectedImage = image
        }
    }
    
    func configureWithExt() {
        view.addViews(playlistLabel, nameTextField, createPlaylistButton, dismissButton, changeImageButton, imageView, activityIndicator)
        
        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
        playlistLabel.anchor(top: dismissButton.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        imageView.anchor(top: playlistLabel.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 30, width: 100, height: 100)
        changeImageButton.anchor(top: imageView.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 30)
        nameTextField.anchor(top: changeImageButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
        createPlaylistButton.anchor(top: nameTextField.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 40, width: 100, height: 50)
        activityIndicator.anchor(centerX: createPlaylistButton.centerXAnchor, centerY: createPlaylistButton.centerYAnchor)
    }
}

extension CreatePlaylistViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreatePlaylistViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage ?? info[.originalImage] as? UIImage {
            self.selectedImage = selectedImage
            imageView.contentMode = .scaleAspectFill
            self.imageView.image = selectedImage
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension CreatePlaylistViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
