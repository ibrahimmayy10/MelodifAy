//
//  ShareNewPostViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.10.2024.
//

import UIKit
import AVFoundation

class ShareNewPostViewController: UIViewController {
    
    private let shareLabel = Labels(textLabel: "Şarkını paylaş", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let previewLabel = Labels(textLabel: "Önizleme", fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Paylaş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let audioView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 5
        
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let explanationTextField = TextFields(placeHolder: "Şarkı ismi", secureText: false, textType: .name, maxLength: 35)
    
    var newPostURL: URL?
    private let videoPlayer = AVPlayer()
    private var playerLayer = AVPlayerLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        keyboardShowing()
        
        guard let url = newPostURL?.absoluteString else { return }
        if url.contains(".MOV") {
            print("video")
        } else  {
            print("ses")
        }
        
        playVideo()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
            if explanationTextField.isFirstResponder {
                activeField = explanationTextField
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
    
    func playVideo() {
        guard let videoURL = newPostURL else { return }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        playerLayer.removeFromSuperlayer()
        
        let playerItem = AVPlayerItem(url: videoURL)
        videoPlayer.replaceCurrentItem(with: playerItem)
        
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity = .resizeAspect
        
        playerLayer.cornerRadius = 10
        
        let padding: CGFloat = 20
        playerLayer.frame = CGRect(
            x: padding,
            y: padding,
            width: view.bounds.width - (2 * padding),
            height: view.bounds.height - (10 * padding)
        )
        contentView.layer.insertSublayer(playerLayer, at: 0)
        
        videoPlayer.play()
    }

}

extension ShareNewPostViewController {
    func configureWithExt() {
        view.backgroundColor = .white
        
        view.addViews(scrollView, backButton, shareLabel)
        scrollView.addSubview(contentView)
        contentView.addViews(explanationTextField, shareButton)
        
        scrollView.anchor(top: shareLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, width: view.bounds.size.width)
        
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        shareLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        shareButton.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingLeft: 20, paddingRight: 20, paddingBottom: 20, height: 40)
        explanationTextField.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: shareButton.topAnchor, paddingLeft: 20, paddingRight: 20, paddingBottom: 20)
    }
}
