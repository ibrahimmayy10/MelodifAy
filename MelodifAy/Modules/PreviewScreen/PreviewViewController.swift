//
//  PreviewViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 21.11.2024.
//

import UIKit

class PreviewViewController: UIViewController {
    
    private let previewLabel = Labels(textLabel: "Önizleme", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let nameLabel = Labels(textLabel: "İbrahim AY", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .darkGray)
    private let songNameLabel = Labels(textLabel: "Oh Be", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let explanationLabel = Labels(textLabel: "Şarkı kartınız bu şekilde görünecek", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let songView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let okButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tamam", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 20
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        okButton.addTarget(self, action: #selector(okButton_Clicked), for: .touchUpInside)
    }
    
    @objc func okButton_Clicked() {
        navigationController?.pushViewController(AccountViewController(), animated: true)
    }

}

extension PreviewViewController {
    func configureWithExt() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        view.addViews(previewLabel, songView, explanationLabel, okButton)
        songView.addViews(songNameLabel, nameLabel, imageView)
        
        previewLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        songView.anchor(top: previewLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40, height: 400)
        imageView.anchor(top: songView.topAnchor, left: songView.leftAnchor, right: songView.rightAnchor, height: 300)
        songNameLabel.anchor(top: imageView.bottomAnchor, left: songView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: songView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        explanationLabel.anchor(top: songView.bottomAnchor, left: view.leftAnchor, paddingTop: 30, paddingLeft: 30)
        okButton.anchor(top: explanationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 40)
    }
}