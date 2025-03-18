//
//  SignInViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit

protocol SignInViewControllerProtocol: AnyObject {
    func setSignInInfo() -> (String, String)?
    func navigateHomePage()
    func showAlert(title: String, message: String)
}

class SignInViewController: UIViewController {
    
    private let imageView = ImageViews(imageName: "melodifaylogo")
    
    private let emailTextField = TextFields(placeHolder: "Email", secureText: false, textType: .emailAddress, maxLength: 1000)
    private let passwordTextField = TextFields(placeHolder: "Şifre", secureText: true, textType: .password, maxLength: 8)
    
    private let registerButton: UIButton =  {
        let button = UIButton(type: .system)
        button.setTitle("Hesabın yok mu?", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        return button
    }()
    
    lazy var signInButton : UIButton =  {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.setTitle("Giriş Yap", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
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
    
    private let viewModel = SignInViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        keyboardShowing()
        addTargetOnButton()
        setDelegate()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        scrollView.delegate = self
    }
    
    func addTargetOnButton() {
        registerButton.addTarget(self, action: #selector(registerButton_Clicked), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButton_Clicked), for: .touchUpInside)
    }
    
    @objc func registerButton_Clicked() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @objc func signInButton_Clicked() {
        guard let signInInfo = setSignInInfo() else {
            showAlert(title: "", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        let (email, password) = signInInfo
        
        activityIndicator.startAnimating()
        signInButton.setTitle("", for: .normal)
        viewModel.signIn(email: email, password: password) { [weak self] success in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.signInButton.setTitle("Giriş Yap", for: .normal)
            
            if success {
                self.navigateHomePage()
            } else {
                self.showAlert(title: "", message: "Giriş yapılırken bir hata oluştu")
            }
            
        }
    }

}

extension SignInViewController {
    func configureWithExt() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        view.addViews(scrollView, registerButton)
        scrollView.addSubview(contentView)
        contentView.addViews(imageView, emailTextField, passwordTextField, signInButton, activityIndicator)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: registerButton.topAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.anchor(top: contentView.topAnchor, centerX: contentView.centerXAnchor, paddingTop: 20, width: 250, height: 250)
        emailTextField.anchor(top: imageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 40)
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 40)
        signInButton.anchor(top: passwordTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 40)
        activityIndicator.anchor(centerX: signInButton.centerXAnchor, centerY: signInButton.centerYAnchor)
        registerButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, centerX: view.centerXAnchor)
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

extension SignInViewController: SignInViewControllerProtocol {
    func setSignInInfo() -> (String, String)? {
        guard let email = emailTextField.text, !email.isEmpty else { return nil }
        guard let password = passwordTextField.text, !password.isEmpty else { return nil }
        
        return (email, password)
    }
    
    func navigateHomePage() {
        navigationController?.pushViewController(HomePageViewController(), animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignInViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
