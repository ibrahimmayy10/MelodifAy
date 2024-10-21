//
//  NewPostViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import GoogleGenerativeAI
import Lottie

class CreateSongWithAIViewController: UIViewController {
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let createSongButton: UIButton = {
        let button = UIButton()
        button.setTitle("Şarkı Oluştur", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let newPostLabel = Labels(textLabel: "Yeni Gönderi", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let newSongLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 17), textColorLabel: .white)
    
    private let seperatorView = SeperatorView(color: .darkGray)
    
    private let themeTextField = TextFields(placeHolder: "Şarkının konusu", secureText: false, textType: .name, maxLength: 30)
    private let genreTextField = TextFields(placeHolder: "Şarkı türü", secureText: false, textType: .name, maxLength: 30)
    private let moodTextField = TextFields(placeHolder: "Ruh hali", secureText: false, textType: .name, maxLength: 30)
    private let tempoTextField = TextFields(placeHolder: "Şarkı hızı", secureText: false, textType: .name, maxLength: 30)
    private let instrumentTextField = TextFields(placeHolder: "Enstrüman", secureText: false, textType: .name, maxLength: 30)
    private let songLengthTextField = TextFields(placeHolder: "Şarkının söz sayısı", secureText: false, textType: .name, maxLength: 30)
    private let mainMessageTextField = TextFields(placeHolder: "Şarkının ana düşüncesi", secureText: false, textType: .name, maxLength: 50)
    
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
    
    private let instrumentPicker = UIPickerView()
    
    private let animationView = LottieAnimationView(name: "musicAnimaions")
    
    let instruments = ["Gitar", "Piyano", "Keman", "Bağlama", "Bateri", "Klarnet", "Saksafon", "Trompet"]
    
    private let viewModel = CreateSongWithAIViewModel()
    var song = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopBar()
        configureWithExt()
        configureAnimationView()
        addTargetButtons()
        pickerSettings()
                
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
        createSongButton.addTarget(self, action: #selector(createSongButton_Clicked), for: .touchUpInside)
        
        instrumentTextField.isUserInteractionEnabled = true
        let tapGestureInstrumentTextField = UITapGestureRecognizer(target: self, action: #selector(instrumentTextField_Clicked))
        instrumentTextField.addGestureRecognizer(tapGestureInstrumentTextField)
    }
    
    func toogle(isHidden: Bool) {
        contentView.isHidden = isHidden
    }
    
    @objc func createSongButton_Clicked() {
        toogle(isHidden: true)
        animationView.isHidden = false
        animationView.play()
        let theme = themeTextField.text ?? ""
        let mood = moodTextField.text ?? ""
        let genre = genreTextField.text ?? ""
        let tempo = tempoTextField.text ?? ""
        let instrument = instrumentTextField.text ?? ""
        let songLength = Int(songLengthTextField.text ?? "") ?? 0
        let mainMessage = mainMessageTextField.text ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            viewModel.generateSong(theme: theme, mood: mood, genre: genre, tempo: tempo, instrument: instrument, songLength: songLength, mainMessage: mainMessage) { song in
                DispatchQueue.main.async {
//                    let vc = CreatedSongViewController()
//                    vc.song = song
//                    self.navigationController?.pushViewController(vc, animated: true)
                }
                self.animationView.stop()
                self.animationView.isHidden = true 
                self.toogle(isHidden: song.isEmpty)
            }
        }
    }
    
    @objc func backButton_Clicked() {
        dismiss(animated: true, completion: nil)
    }

}

extension CreateSongWithAIViewController {
    func configureTopBar() {
        view.backgroundColor = .black
        view.addViews(backButton, newPostLabel, seperatorView)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        newPostLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        seperatorView.anchor(top: newPostLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, height: 1)
    }
    
    func configureWithExt() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews(themeTextField, genreTextField, moodTextField, tempoTextField, instrumentTextField, songLengthTextField, mainMessageTextField, createSongButton, newSongLabel)
        
        scrollView.anchor(top: seperatorView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, width: view.bounds.size.width)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        themeTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        genreTextField.anchor(top: themeTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        moodTextField.anchor(top: genreTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        tempoTextField.anchor(top: moodTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        instrumentTextField.anchor(top: tempoTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        songLengthTextField.anchor(top: instrumentTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        mainMessageTextField.anchor(top: songLengthTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        createSongButton.anchor(top: mainMessageTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingRight: 15, height: 50)
        newSongLabel.anchor(top: createSongButton.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5)
    }
    
    func configureAnimationView() {
        view.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 200, height: 200)
    }
}

extension CreateSongWithAIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerSettings() {
        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        instrumentPicker.translatesAutoresizingMaskIntoConstraints = false
        instrumentPicker.isHidden = true
        instrumentPicker.backgroundColor = .white
        instrumentPicker.layer.cornerRadius = 10
    }
    
    @objc func instrumentTextField_Clicked() {
        if instrumentPicker.isHidden {
            contentView.addSubview(instrumentPicker)
            instrumentPicker.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, height: 200)
            
            instrumentPicker.isHidden = false
        } else {
            instrumentPicker.isHidden = true
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return instruments[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instruments.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedInstrument = instruments[row]
        instrumentTextField.text = selectedInstrument
        instrumentPicker.isHidden = true
    }
}
