//
//  RegisterViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit

protocol RegisterViewControllerProtocol: AnyObject {
    func setRegisterInfo() -> (String, String, String)?
    func navigateSignIn()
    func showAlert(title: String, message: String)
}

class RegisterViewController: UIViewController {
    
    private let imageView = ImageViews(imageName: "logo")
    
    private let emailTextField = TextFields(placeHolder: "Email", secureText: false, textType: .emailAddress, maxLength: 1000)
    private let nameTextField = TextFields(placeHolder: "Kullanıcı Adı", secureText: false, textType: .name, maxLength: 1000)
    private let passwordTextField = TextFields(placeHolder: "Şifre", secureText: true, textType: .password, maxLength: 8)
    
    private let signInButton: UIButton =  {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Zaten hesabın var mı?", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        return button
    }()
    
    private let registerButton : UIButton =  {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
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
    }
    
    @objc func signInButton_Clicked() {
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    @objc func registerButton_Clicked() {
        guard let registerInfo = setRegisterInfo() else {
            showAlert(title: "", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        let (name, email, password) = registerInfo
        
        activityIndicator.startAnimating()
        registerButton.setTitle("", for: .normal)
        viewModel.register(name: name, email: email, password: password) { [weak self] success in
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
        view.backgroundColor = .white
        
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        view.addViews(scrollView, signInButton)
        scrollView.addSubview(contentView)
        contentView.addViews(imageView, nameTextField, emailTextField, passwordTextField, registerButton, activityIndicator)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: signInButton.topAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        imageView.anchor(top: contentView.topAnchor, centerX: contentView.centerXAnchor, paddingTop: 20, width: 300, height: 300)
        nameTextField.anchor(top: imageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 40)
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 40)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 40)
        registerButton.anchor(top: passwordTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 40)
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
            if emailTextField.isFirstResponder {
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
    func setRegisterInfo() -> (String, String, String)? {
        guard let name = nameTextField.text, !name.isEmpty else { return nil }
        guard let email = emailTextField.text, !email.isEmpty else { return nil }
        guard let password = passwordTextField.text, !password.isEmpty else { return nil }
        
        return (name, email, password)
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
