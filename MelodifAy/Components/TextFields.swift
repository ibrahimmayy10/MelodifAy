//
//  TextFields.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit

class TextFields: UITextField, UITextFieldDelegate {

    var maxCaracterLength: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(placeHolder : String, secureText:Bool,textType : UITextContentType,maxLength:Int){
        self.init(frame: .zero)
        maxCaracterLength = maxLength
        setTextField(textPlaceHolder: placeHolder,secureText: secureText,textType: textType,maxLength: maxLength)
        
    }
    
    func configure(){
        translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.anchor()
    }
    
    func setTextField(textPlaceHolder: String, secureText: Bool, textType: UITextContentType,maxLength : Int){
        attributedPlaceholder = NSAttributedString(string: textPlaceHolder, attributes: [.foregroundColor: UIColor.systemGray4])
        textColor = .white
        borderStyle = .none
        isSecureTextEntry = secureText
        textContentType = textType
        self.maxCaracterLength = maxLength
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= self.maxCaracterLength
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: frame.height + 5, width: frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.systemGray4.cgColor
        
        layer.addSublayer(bottomLine)
    }

}

class CustomTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        self.borderStyle = .none
        self.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        self.textColor = .white
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
