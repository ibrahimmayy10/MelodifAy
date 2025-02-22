//
//  ShareNewPostViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.10.2024.
//

import UIKit
import AVFoundation
import Lottie

class ShareNewPostViewController: UIViewController {
    
    private let shareLabel = Labels(textLabel: "Şarkını paylaş", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let explanationLabel = Labels(textLabel: "Şarkı sözlerini ekleyebilirsiniz...", fontLabel: .systemFont(ofSize: 17), textColorLabel: .systemGray4)
    private let selectionImageLabel = Labels(textLabel: "Şarkınıza bir kapak fotoğrafı ekleyin", fontLabel: .systemFont(ofSize: 17), textColorLabel: .white)
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Paylaş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let songNameTextField = TextFields(placeHolder: "Şarkı ismi", secureText: false, textType: .name, maxLength: 50)
    
    private let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 17)
        textView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        return textView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    private let seperatorView = SeperatorView(color: .systemGray4)
    
    private let imageView = ImageViews(imageName: "melodifaylogo")
    
    private let selectionImageViewContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 8
        return container
    }()
    
    private let selectionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var newPostURL: URL?
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    
    private let viewModel = ShareNewPostViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        keyboardShowing()
        addTargetButtons()
                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shareButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButton_Clicked), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCoverImage))
        selectionImageViewContainer.addGestureRecognizer(tapGesture)
        selectionImageViewContainer.isUserInteractionEnabled = true
    }
    
    @objc func selectCoverImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareButton_Clicked() {
        guard let newPostURL = newPostURL, let songName = songNameTextField.text, let selectedImage = selectedImage, !songName.isEmpty, !newPostURL.absoluteString.isEmpty else {
            self.showAlert(message: "Lütfen şarkınıza bir isim ve kapak fotoğrafı ekleyiniz")
            return
        }
        activityIndicator.startAnimating()
        shareButton.setTitle("", for: .normal)
        
        viewModel.fetchUserName { [weak self] nameSurname in
            guard let self = self else { return }
            
            self.viewModel.shareNewPost(url: newPostURL, songName: songName, lyrics: self.lyricsTextView.text ?? "", coverPhoto: selectedImage, name: nameSurname) { success in
                self.activityIndicator.stopAnimating()
                self.shareButton.setTitle("Paylaş", for: .normal)
                
                if success {
                    let vc = PreviewViewController()
                    vc.coverImage = selectedImage
                    vc.songName = songName
                    vc.name = nameSurname
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true)
                } else {
                    self.showAlert(message: "Şarkıyı paylaşırken bir sorun oluştu")
                }
            }
        }
    }

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func keyboardShowing() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var activeField: UIView?
            if lyricsTextView.isFirstResponder {
                activeField = lyricsTextView
            } else if songNameTextField.isFirstResponder {
                activeField = songNameTextField
            }
            
            if let activeField = activeField {
                let visibleRect = view.frame.inset(by: contentInsets)
                if !visibleRect.contains(activeField.frame.origin) {
                    scrollView.scrollRectToVisible(activeField.frame, animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            let contentInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }

}

extension ShareNewPostViewController {
    func configureWithExt() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        lyricsTextView.delegate = self
        imageView.contentMode = .scaleAspectFit
        
        view.addViews(scrollView, backButton, shareLabel, imageView)
        scrollView.addSubview(contentView)
        contentView.addViews(lyricsTextView, songNameTextField, explanationLabel, shareButton, seperatorView, activityIndicator, selectionImageLabel, selectionImageViewContainer)
        selectionImageViewContainer.addSubview(selectionImageView)
        
        scrollView.anchor(top: shareLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        shareLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        songNameTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        lyricsTextView.anchor(top: songNameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 16, paddingRight: 20, height: 60)
        explanationLabel.anchor(top: lyricsTextView.topAnchor, left: lyricsTextView.leftAnchor, paddingTop: 8, paddingLeft: 4)
        seperatorView.anchor(top: lyricsTextView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingRight: 20, height: 1)
        selectionImageLabel.anchor(top: seperatorView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 30, paddingLeft: 20)
        selectionImageViewContainer.anchor(top: selectionImageLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 150, height: 150)
        selectionImageView.anchor(centerX: selectionImageViewContainer.centerXAnchor, centerY: selectionImageViewContainer.centerYAnchor, width: 100, height: 100)
        shareButton.anchor(top: selectionImageViewContainer.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingRight: 20, height: 50)
        activityIndicator.anchor(top: shareButton.topAnchor, left: shareButton.leftAnchor, right: shareButton.rightAnchor, bottom: shareButton.bottomAnchor)
        imageView.anchor(bottom: view.bottomAnchor, centerX: view.centerXAnchor, width: 120, height: 120)
    }
}

extension ShareNewPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        explanationLabel.isHidden = !textView.text.isEmpty
    }
}

extension ShareNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            self.selectedImage = selectedImage
            selectionImageView.clipsToBounds = true
            selectionImageView.layer.cornerRadius = 10
            selectionImageView.contentMode = .scaleAspectFill
            self.selectionImageView.image = selectedImage
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
