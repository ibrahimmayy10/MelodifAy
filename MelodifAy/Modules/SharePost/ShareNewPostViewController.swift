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
    
    private let shareLabel = Labels(textLabel: "Şarkını paylaş", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let explanationLabel = Labels(textLabel: "Şarkı sözlerini ekleyebilirsiniz...", fontLabel: .systemFont(ofSize: 17), textColorLabel: .systemGray4)
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Paylaş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 20
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
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 17)
        
        return textView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    private let seperatorView = SeperatorView(color: .systemGray4)
    
    private let imageView = ImageViews(imageName: "logo")
    
    var newPostURL: URL?
    
    private let viewModel = ShareNewPostViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        keyboardShowing()
        addTargetButtons()
        
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
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareButton_Clicked() {
        activityIndicator.startAnimating()
        shareButton.setTitle("", for: .normal)
        
        guard let url = newPostURL?.absoluteString, let songName = songNameTextField.text, let lyrics = lyricsTextView.text else { return }
        viewModel.shareNewPost(url: url, songName: songName, lyrics: lyrics) { [weak self] success in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.shareButton.setTitle("Paylaş", for: .normal)
            
            if success {
                self.navigationController?.pushViewController(AccountViewController(), animated: true)
            } else {
                self.showAlert(message: "Şarkıyı paylaşırken bir sorun oluştu")
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
        view.backgroundColor = .white
        
        lyricsTextView.delegate = self
        imageView.contentMode = .scaleToFill
        
        view.addViews(scrollView, backButton, shareLabel, imageView)
        scrollView.addSubview(contentView)
        contentView.addViews(lyricsTextView, songNameTextField, explanationLabel, shareButton, seperatorView, activityIndicator)
        
        scrollView.anchor(top: shareLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        shareLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        songNameTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        lyricsTextView.anchor(top: songNameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 16, paddingRight: 20, height: 60)
        explanationLabel.anchor(top: lyricsTextView.topAnchor, left: lyricsTextView.leftAnchor, paddingTop: 8, paddingLeft: 4)
        seperatorView.anchor(top: lyricsTextView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingRight: 20, height: 1)
        shareButton.anchor(top: seperatorView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 40)
        activityIndicator.anchor(top: shareButton.topAnchor, left: shareButton.leftAnchor, right: shareButton.rightAnchor, bottom: shareButton.bottomAnchor)
        imageView.anchor(bottom: view.bottomAnchor, centerX: view.centerXAnchor, width: 150, height: 150)
    }
}

extension ShareNewPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        explanationLabel.isHidden = !textView.text.isEmpty
    }
}
