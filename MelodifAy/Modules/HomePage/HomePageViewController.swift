//
//  HomePageViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit
import Firebase
import Lottie

protocol HomePageViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

class HomePageViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let newPostButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: HomePageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = HomePageViewModel(view: self)
        
        setup()
        configureBottomBar()
        configureWithExt()
        configureAnimationView()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        newPostButton.addTarget(self, action: #selector(newPostButton_Clicked), for: .touchUpInside)
    }
    
    @objc func newPostButton_Clicked() {
        navigationController?.pushViewController(NewSongViewController(), animated: true)
    }

}

extension HomePageViewController {
    func setup() {
        viewModel?.getDataMusics()
    }
    
    func configureBottomBar() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        
        let homeViewModel = BottomBarViewModel(selectedTab: .home(isSelected: true))
        bottomBar.viewModel = homeViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        bottomBar.layer.cornerRadius = 30
        bottomBar.layer.shadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        bottomBar.layer.shadowRadius = 4
        bottomBar.layer.shadowOpacity = 0.3
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 60)
    }
    
    func configureWithExt() {
        view.addViews(newPostButton)
        
        newPostButton.anchor(right: view.rightAnchor, bottom: bottomBar.topAnchor, paddingRight: 10, paddingBottom: 10, width: 50, height: 50)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension HomePageViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        
    }
    
    func didTapSearchButton() {
        navigationController?.pushViewController(SearchViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

extension HomePageViewController: HomePageViewControllerProtocol {
    func reloadDataTableView() {
        
    }
}
