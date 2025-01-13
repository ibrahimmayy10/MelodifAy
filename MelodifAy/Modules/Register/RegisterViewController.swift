//
//  RegisterViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit
import Firebase

protocol RegisterViewControllerProtocol: AnyObject {
    func setRegisterInfo() -> (String, String, String, UIImage, String, String)?
    func navigateSignIn()
    func showAlert(title: String, message: String)
}

class RegisterViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private let emailTextField = TextFields(placeHolder: "Email", secureText: false, textType: .emailAddress, maxLength: 1000)
    private let nameTextField = TextFields(placeHolder: "Ad", secureText: false, textType: .name, maxLength: 1000)
    private let surnameTextField = TextFields(placeHolder: "Soyad", secureText: false, textType: .name, maxLength: 1000)
    private let usernameTextField = TextFields(placeHolder: "Kullanıcı Adı", secureText: false, textType: .name, maxLength: 1000)
    private let passwordTextField = TextFields(placeHolder: "Şifre", secureText: true, textType: .password, maxLength: 8)
    
    private let signInButton: UIButton =  {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Zaten hesabın var mı?", for: .normal)
        button.setTitleColor(UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255), for: .normal)
        return button
    }()
    
    private let registerButton : UIButton =  {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        button.layer.cornerRadius = 10
        button.setTitle("Kayıt Ol", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var selectedImage: UIImage?
    var selectedImageURL: URL?
    
    private let viewModel = RegisterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        keyboardShowing()
        addTargetOnButton()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTargetOnButton() {
        signInButton.addTarget(self, action: #selector(signInButton_Clicked), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButton_Clicked), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCoverImage))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func selectCoverImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func signInButton_Clicked() {
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    @objc func registerButton_Clicked() {
        guard let registerInfo = setRegisterInfo() else {
            showAlert(title: "", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        let (name, surname, username, image, email, password) = registerInfo
        
        activityIndicator.startAnimating()
        registerButton.setTitle("", for: .normal)
        viewModel.registerUser(name: name, surname: surname, username: username, image: image, email: email, password: password) { [weak self] success in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.registerButton.setTitle("Kayıt Ol", for: .normal)
            
            if success {
                self.navigateSignIn()
            } else {
                self.showAlert(title: "", message: "Kayıt yapılırken bir hata oluştu")
            }
            
        }
    }

}

extension RegisterViewController {
    func configureWithExt() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        view.addViews(scrollView, signInButton)
        scrollView.addSubview(contentView)
        contentView.addViews(imageView, nameTextField, emailTextField, surnameTextField, usernameTextField, passwordTextField, registerButton, activityIndicator)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: signInButton.topAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        imageView.anchor(top: contentView.topAnchor, centerX: contentView.centerXAnchor, paddingTop: 20, width: 100, height: 100)
        nameTextField.anchor(top: imageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, height: 40)
        surnameTextField.anchor(top: nameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, height: 40)
        usernameTextField.anchor(top: surnameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, height: 40)
        emailTextField.anchor(top: usernameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, height: 40)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, height: 40)
        registerButton.anchor(top: passwordTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 40)
        activityIndicator.anchor(centerX: registerButton.centerXAnchor, centerY: registerButton.centerYAnchor)
        signInButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, centerX: view.centerXAnchor)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
            if nameTextField.isFirstResponder {
                activeField = nameTextField
            } else if surnameTextField.isFirstResponder {
                activeField = surnameTextField
            } else if usernameTextField.isFirstResponder {
                activeField = usernameTextField
            } else if emailTextField.isFirstResponder {
                activeField = emailTextField
            } else if passwordTextField.isFirstResponder {
                activeField = passwordTextField
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

extension RegisterViewController: RegisterViewControllerProtocol {
    func setRegisterInfo() -> (String, String, String, UIImage, String, String)? {
        guard let name = nameTextField.text, !name.isEmpty else { return nil }
        guard let surname = surnameTextField.text, !surname.isEmpty else { return nil }
        guard let username = usernameTextField.text, !username.isEmpty else { return nil }
        guard let image = selectedImage else { return nil }
        guard let email = emailTextField.text, !email.isEmpty else { return nil }
        guard let password = passwordTextField.text, !password.isEmpty else { return nil }
        
        return (name, surname, username, image, email, password)
    }
    
    func navigateSignIn() {
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
