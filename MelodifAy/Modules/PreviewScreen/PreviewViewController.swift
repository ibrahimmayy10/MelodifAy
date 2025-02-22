//
//  PreviewViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 21.11.2024.
//

import UIKit

class PreviewViewController: UIViewController {
    
    private let previewLabel = Labels(textLabel: "Önizleme", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .lightGray)
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let explanationLabel = Labels(textLabel: "Şarkı kartınız bu şekilde görünecek", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "melodifaylogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let songView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let okButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tamam", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    var coverImage = UIImage()
    var songName = String()
    var name = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
        configureWithExt()
        addTargetButtons()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        okButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    func addTargetButtons() {
        okButton.addTarget(self, action: #selector(okButton_Clicked), for: .touchUpInside)
    }
    
    @objc func okButton_Clicked() {
        navigationController?.pushViewController(AccountViewController(), animated: true)
    }

}

extension PreviewViewController {
    func setup() {
        nameLabel.text = name
        songNameLabel.text = songName
        imageView.image = coverImage
        
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureWithExt() {
        view.addViews(previewLabel, songView, explanationLabel, okButton)
        songView.addViews(songNameLabel, nameLabel, imageView)
        
        previewLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        songView.anchor(top: previewLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40, height: 400)
        imageView.anchor(top: songView.topAnchor, left: songView.leftAnchor, right: songView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 300)
        songNameLabel.anchor(top: imageView.bottomAnchor, left: songView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: songView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        explanationLabel.anchor(top: songView.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 30)
        okButton.anchor(top: explanationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 40)
    }
}
