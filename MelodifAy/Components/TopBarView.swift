//
//  TopBarView.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.03.2025.
//

import UIKit

protocol TopBarViewDelegate: AnyObject {
    func didTapNotificationButton()
    func didTapMessageBoxButton()
}

class TopBarView: UIView {
    
    weak var delegate: TopBarViewDelegate?
    
    private let melodifayLogoImageView = ImageViews(imageName: "topBarIcon")
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .medium)
        let largeImage = UIImage(systemName: "bell.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageBoxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .medium)
        let largeImage = UIImage(systemName: "envelope.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(messageBoxButtonTapped), for: .touchUpInside)
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1.0)
        
        addViews(melodifayLogoImageView, notificationButton, messageBoxButton)
    }
    
    private func configureConstraints() {
        melodifayLogoImageView.anchor(bottom: bottomAnchor, centerX: centerXAnchor, width: 70, height: 70)
        
        messageBoxButton.anchor(right: rightAnchor, bottom: bottomAnchor, paddingRight: 20, paddingBottom: 15)
        notificationButton.anchor(right: messageBoxButton.leftAnchor, bottom: bottomAnchor, paddingRight: 20, paddingBottom: 15)
    }
        
    @objc private func notificationButtonTapped() {
        delegate?.didTapNotificationButton()
    }
    
    @objc private func messageBoxButtonTapped() {
        delegate?.didTapMessageBoxButton()
    }
    
    func showNotificationButton(_ show: Bool) {
        notificationButton.isHidden = !show
    }
    
    func showMessageButton(_ show: Bool) {
        messageBoxButton.isHidden = !show
    }
}
