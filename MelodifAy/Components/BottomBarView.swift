//
//  BottomBarView.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Foundation

enum BottomBarTab {
    case home(isSelected: Bool)
    case search(isSelected: Bool)
    case account(isSelected: Bool)
    
    var homeIcon: UIImage? {
        switch self {
        case .home(let isSelected):
            return isSelected ? UIImage(systemName: "house.fill") : UIImage(systemName: "house")
        case .search:
            return UIImage(systemName: "house")
        case .account:
            return UIImage(systemName: "house")
        }
    }
    
    var searchIcon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "magnifyingglass")
        case .search(let isSelected):
            return isSelected ? UIImage(systemName: "magnifyingglass") : UIImage(systemName: "magnifyingglass")
        case .account:
            return UIImage(systemName: "magnifyingglass")
        }
    }
    
    var accountIcon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "person")
        case .search:
            return UIImage(systemName: "person")
        case .account(let isSelected):
            return isSelected ? UIImage(systemName: "person.fill") : UIImage(systemName: "person")
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
    
    var searchIcon: UIImage? {
        return selectedTab.searchIcon
    }
    
    var accountIcon: UIImage? {
        return selectedTab.accountIcon
    }
}

protocol BottomBarViewProtocol: AnyObject {
    func didTapHomeButton()
    func didTapSearchButton()
    func didTapAccountButton()
}

class BottomBarView: UIView {
    
    static let shared = BottomBarView()
    
    private let homeButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)
    private let accountButton = UIButton(type: .system)
    
    weak var delegate: BottomBarViewProtocol?
    
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
        let seperatorView = SeperatorView(color: .lightGray)
        
        let stackView = UIStackView(arrangedSubviews: [homeButton, searchButton, accountButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addViews(stackView, seperatorView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        seperatorView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 1)
        stackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor)
        
        homeButton.tintColor = .white
        searchButton.tintColor = .white
        accountButton.tintColor = .white
        
        homeButton.addTarget(self, action: #selector(didTapHomeButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        accountButton.addTarget(self, action: #selector(didTapAccountButton), for: .touchUpInside)
    }
    
    private func configureView() {
        guard let viewModel = viewModel else { return }
        
        homeButton.setImage(viewModel.homeIcon, for: .normal)
        searchButton.setImage(viewModel.searchIcon, for: .normal)
        accountButton.setImage(viewModel.accountIcon, for: .normal)
    }
    
    @objc private func didTapHomeButton() {
        delegate?.didTapHomeButton()
    }
    
    @objc private func didTapSearchButton() {
        delegate?.didTapSearchButton()
    }
    
    @objc private func didTapAccountButton() {
        delegate?.didTapAccountButton()
    }
}
