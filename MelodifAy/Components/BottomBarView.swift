//
//  BottomBarView.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Foundation

enum BottomBarTab: Equatable {
    case home(isSelected: Bool)
    case feed(isSelected: Bool)
    case ai(isSelected: Bool)
    case account(isSelected: Bool)

    var homeIcon: UIImage? {
        switch self {
        case .home(let isSelected):
            return isSelected ? UIImage(systemName: "house.fill") : UIImage(systemName: "house")
        default:
            return UIImage(systemName: "house")
        }
    }
    
    var feedIcon: UIImage? {
        switch self {
        case .feed(let isSelected):
            return isSelected ? UIImage(systemName: "play.rectangle.fill") : UIImage(systemName: "play.rectangle")
        default:
            return UIImage(systemName: "play.rectangle")
        }
    }
    
    var searchIcon: UIImage? {
        switch self {
        case .ai(let isSelected):
            return isSelected ? UIImage(systemName: "brain.head.profile.fill") : UIImage(systemName: "brain.head.profile")
        default:
            return UIImage(systemName: "brain.head.profile")
        }
    }
    
    var accountIcon: UIImage? {
        switch self {
        case .account(let isSelected):
            return isSelected ? UIImage(systemName: "person.fill") : UIImage(systemName: "person")
        default:
            return UIImage(systemName: "person")
        }
    }

    var title: String? {
        switch self {
        case .home(let isSelected):
            return isSelected ? "Anasayfa" : nil
        case .feed(let isSeledted):
            return isSeledted ? "Akış" : nil
        case .ai(let isSelected):
            return isSelected ? "Yarat" : nil
        case .account(let isSelected):
            return isSelected ? "Hesap" : nil
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .home(let isSelected),
             .feed(let isSelected),
             .ai(let isSelected),
             .account(let isSelected):
            return isSelected ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .clear
        }
    }

    var cornerRadius: CGFloat {
        return 25
    }

    var expandedWidth: CGFloat {
        return 90
    }
    
    var normalWidth: CGFloat {
        return 45
    }

    static func == (lhs: BottomBarTab, rhs: BottomBarTab) -> Bool {
        switch (lhs, rhs) {
        case (.home(let lSelected), .home(let rSelected)):
            return lSelected == rSelected
        case (.feed(let lSelected), .feed(let rSelected)):
            return lSelected == rSelected
        case (.ai(let lSelected), .ai(let rSelected)):
            return lSelected == rSelected
        case (.account(let lSelected), .account(let rSelected)):
            return lSelected == rSelected
        default:
            return false
        }
    }
}

class BottomBarViewModel {
    var selectedTab: BottomBarTab

    init(selectedTab: BottomBarTab) {
        self.selectedTab = selectedTab
    }

    var homeIcon: UIImage? {
        return selectedTab.homeIcon
    }
    
    var feedIcon: UIImage? {
        return selectedTab.feedIcon
    }

    var aiIcon: UIImage? {
        return selectedTab.searchIcon
    }

    var accountIcon: UIImage? {
        return selectedTab.accountIcon
    }

    var homeTitle: String? {
        return selectedTab == .home(isSelected: true) ? selectedTab.title : nil
    }
    
    var feedTitle: String? {
        return selectedTab == .feed(isSelected: true) ? selectedTab.title : nil
    }

    var aiTitle: String? {
        return selectedTab == .ai(isSelected: true) ? selectedTab.title : nil
    }

    var accountTitle: String? {
        return selectedTab == .account(isSelected: true) ? selectedTab.title : nil
    }

    var homeWidth: CGFloat {
        return selectedTab == .home(isSelected: true) ? selectedTab.expandedWidth : selectedTab.normalWidth
    }
    
    var feedWidth: CGFloat {
        return selectedTab == .feed(isSelected: true) ? selectedTab.expandedWidth : selectedTab.normalWidth
    }

    var aiWidth: CGFloat {
        return selectedTab == .ai(isSelected: true) ? selectedTab.expandedWidth : selectedTab.normalWidth
    }

    var accountWidth: CGFloat {
        return selectedTab == .account(isSelected: true) ? selectedTab.expandedWidth : selectedTab.normalWidth
    }
}

protocol BottomBarViewProtocol: AnyObject {
    func didTapHomeButton()
    func didTapFeedButton()
    func didTapAiButton()
    func didTapAccountButton()
}

class BottomBarView: UIView {
    
    static let shared = BottomBarView()
    
    private let homeButton = UIButton(type: .system)
    private let feedButton = UIButton(type: .system)
    private let aiButton = UIButton(type: .system)
    private let accountButton = UIButton(type: .system)

    private let homeImageView = UIImageView()
    private let feedImageView = UIImageView()
    private let aiImageView = UIImageView()
    private let accountImageView = UIImageView()

    private let homeLabel = UILabel()
    private let feedLabel = UILabel()
    private let aiLabel = UILabel()
    private let accountLabel = UILabel()
    
    private let homeStackView = UIStackView()
    private let feedStackView = UIStackView()
    private let aiStackView = UIStackView()
    private let accountStackView = UIStackView()
    
    weak var delegate: BottomBarViewProtocol?
    
    var homeButtonWidthConstraint: NSLayoutConstraint!
    var feedButtonWidthConstraint: NSLayoutConstraint!
    var aiButtonWidthConstraint: NSLayoutConstraint!
    var accountButtonWidthConstraint: NSLayoutConstraint!
    
    var viewModel: BottomBarViewModel? {
        didSet {
            configureView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 0.97)
        layer.cornerRadius = 27.5
        
        setupButton(homeButton, imageView: homeImageView, label: homeLabel, stackView: homeStackView, axis: .horizontal)
        setupButton(feedButton, imageView: feedImageView, label: feedLabel, stackView: feedStackView, axis: .vertical)
        setupButton(aiButton, imageView: aiImageView, label: aiLabel, stackView: aiStackView, axis: .vertical)
        setupButton(accountButton, imageView: accountImageView, label: accountLabel, stackView: accountStackView, axis: .horizontal, isReversed: true)

        addViews(homeButton, feedButton, aiButton, accountButton)

        [homeButton, feedButton, aiButton, accountButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        homeButtonWidthConstraint = homeButton.widthAnchor.constraint(equalToConstant: 45)
        feedButtonWidthConstraint = feedButton.widthAnchor.constraint(equalToConstant: 45)
        aiButtonWidthConstraint = aiButton.widthAnchor.constraint(equalToConstant: 45)
        accountButtonWidthConstraint = accountButton.widthAnchor.constraint(equalToConstant: 45)

        NSLayoutConstraint.activate([
            homeButtonWidthConstraint,
            feedButtonWidthConstraint,
            aiButtonWidthConstraint,
            accountButtonWidthConstraint,

            homeButton.heightAnchor.constraint(equalToConstant: 55),
            feedButton.heightAnchor.constraint(equalToConstant: 55),
            aiButton.heightAnchor.constraint(equalToConstant: 55),
            accountButton.heightAnchor.constraint(equalToConstant: 55),
            
            homeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            feedButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 30),
            feedButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            aiButton.leadingAnchor.constraint(equalTo: feedButton.trailingAnchor, constant: 30),
            aiButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            accountButton.leadingAnchor.constraint(equalTo: aiButton.trailingAnchor, constant: 30),
            accountButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        homeButton.addTarget(self, action: #selector(didTapHomeButton), for: .touchUpInside)
        feedButton.addTarget(self, action: #selector(didTapFeedButton), for: .touchUpInside)
        aiButton.addTarget(self, action: #selector(didTapAiButton), for: .touchUpInside)
        accountButton.addTarget(self, action: #selector(didTapAccountButton), for: .touchUpInside)
    }
    
    private func setupButton(_ button: UIButton, imageView: UIImageView, label: UILabel, stackView: UIStackView, axis: NSLayoutConstraint.Axis, isReversed: Bool = false) {
        button.layer.cornerRadius = 27.5
        button.tintColor = .white
        button.backgroundColor = .clear

        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true

        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false

        if isReversed {
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(imageView)
        } else {
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
        }

        button.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])

        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        bringSubviewToFront(button)
    }
    
    private func configureView() {
        guard let viewModel = viewModel else { return }

        homeImageView.image = viewModel.homeIcon
        feedImageView.image = viewModel.feedIcon
        aiImageView.image = viewModel.aiIcon
        accountImageView.image = viewModel.accountIcon

        homeLabel.text = "Anasayfa"
        feedLabel.text = "Akış"
        aiLabel.text = "Yarat"
        accountLabel.text = "Profil"

        let selectedTab = viewModel.selectedTab

        homeButton.backgroundColor = selectedTab == .home(isSelected: true) ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .clear
        feedButton.backgroundColor = selectedTab == .feed(isSelected: true) ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .clear
        aiButton.backgroundColor = selectedTab == .ai(isSelected: true) ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .clear
        accountButton.backgroundColor = selectedTab == .account(isSelected: true) ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .clear

        homeButtonWidthConstraint.constant = selectedTab == .home(isSelected: true) ? 120 : 50
        feedButtonWidthConstraint.constant = selectedTab == .feed(isSelected: true) ? 120 : 50
        aiButtonWidthConstraint.constant = selectedTab == .ai(isSelected: true) ? 120 : 50
        accountButtonWidthConstraint.constant = selectedTab == .account(isSelected: true) ? 120 : 50

        homeLabel.isHidden = selectedTab != .home(isSelected: true)
        feedLabel.isHidden = selectedTab != .feed(isSelected: true)
        aiLabel.isHidden = selectedTab != .ai(isSelected: true)
        accountLabel.isHidden = selectedTab != .account(isSelected: true)

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func didTapHomeButton() {
        viewModel = BottomBarViewModel(selectedTab: .home(isSelected: true))
        delegate?.didTapHomeButton()
    }
    
    @objc private func didTapFeedButton() {
        viewModel = BottomBarViewModel(selectedTab: .feed(isSelected: true))
        delegate?.didTapFeedButton()
    }

    @objc private func didTapAiButton() {
        viewModel = BottomBarViewModel(selectedTab: .ai(isSelected: true))
        delegate?.didTapAiButton()
    }

    @objc private func didTapAccountButton() {
        viewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        delegate?.didTapAccountButton()
    }
}
