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
    
    private let bottomBar = BottomBarView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Şarkı Oluştur"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let themeTextField = CustomTextField(placeholder: "Konu")
    
    private let moodSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Mutlu", "Hüzünlü", "Enerjik", "Sakin", "Romantik"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentedControl
    }()
    
    private let genrePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        pickerView.layer.cornerRadius = 8
        return pickerView
    }()
    
    private let tempoSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Yavaş", "Orta", "Hızlı"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentedControl
    }()
    
    private let instrumentPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        pickerView.layer.cornerRadius = 8
        return pickerView
    }()
    
    private let structureSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Basit (1-2 kıta)", "Standart (2-3 kıta + nakarat)", "Kompleks (Çok kıtalı)"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentedControl
    }()
    
    private let mainMessageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textView.textColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Şarkının ana mesajını buraya yazın..."
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        return textView
    }()
    
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Şarkı Oluştur", for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    private let genreOptions = ["Pop", "Rock", "Hip Hop", "R&B", "Jazz", "Klasik", "Elektronik", "Folk", "Country", "Blues", "Reggae"]
    private let instrumentOptions = ["Piyano", "Gitar", "Davul", "Bas", "Keman", "Flüt", "Saksafon", "Trompet", "Synthesizer", "Akustik Gitar"]
    private var selectedGenre = "Pop"
    private var selectedInstrument = "Piyano"
    
    private let viewModel = CreateSongWithAIViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureBottomBar()
        configureScrollView()
        configureWithExt()
        setupUI()
        setupDelegates()
        addTargetButtons()
        keyboardShowing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.generateButton.applyGradient(colors: [
                UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0),
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
            ])
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.generateButton.applyGradient(colors: [
                UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0),
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
            ])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupDelegates() {
        genrePickerView.delegate = self
        genrePickerView.dataSource = self
        
        instrumentPickerView.delegate = self
        instrumentPickerView.dataSource = self
        
        scrollView.delegate = self
    }
    
    func addTargetButtons() {
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func generateButtonTapped() {
        guard let theme = themeTextField.text, !theme.isEmpty,
              let mainMessage = mainMessageTextView.text, !mainMessage.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        let mood = moodSegmentedControl.titleForSegment(at: moodSegmentedControl.selectedSegmentIndex) ?? "Mutlu"
        let tempo = tempoSegmentedControl.titleForSegment(at: tempoSegmentedControl.selectedSegmentIndex) ?? "Orta"
        let structure = structureSegmentedControl.titleForSegment(at: structureSegmentedControl.selectedSegmentIndex) ?? "Standart (2-3 kıta + nakarat)"
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        generateButton.isEnabled = false
        generateButton.setTitle("", for: .normal)
        
        viewModel.generateSong(theme: theme, mood: mood, genre: selectedGenre, tempo: tempo, instrument: selectedInstrument, songLength: structure, mainMessage: mainMessage) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.generateButton.isEnabled = true
                self?.generateButton.setTitle("Şarkı Oluştur", for: .normal)
                
                let resultVC = SongResultViewController()
                resultVC.songResult = result
                resultVC.songTheme = theme
                resultVC.songMood = mood
                resultVC.songGenre = self?.selectedGenre
                self?.navigationController?.pushViewController(resultVC, animated: true)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
}

extension CreateSongWithAIViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
    }
    
    func configureWithExt() {
        let themeLabel = createSectionLabel(text: "Konu")
        let moodLabel = createSectionLabel(text: "Ruh Hali")
        let genreLabel = createSectionLabel(text: "Müzik Türü")
        let tempoLabel = createSectionLabel(text: "Tempo")
        let instrumentLabel = createSectionLabel(text: "Ana Enstrüman")
        let structureLabel = createSectionLabel(text: "Şarkı Uzunluğu")
        let mainMessageLabel = createSectionLabel(text: "Ana Mesaj")
        
        contentView.addViews(titleLabel, themeLabel, themeTextField, moodLabel, moodSegmentedControl, genreLabel, genrePickerView, tempoLabel, tempoSegmentedControl, instrumentLabel, instrumentPickerView, structureLabel, structureSegmentedControl, mainMessageLabel, mainMessageTextView, generateButton, loadingIndicator)
        
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        themeLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        themeTextField.anchor(top: themeLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 50)
        
        moodLabel.anchor(top: themeTextField.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        moodSegmentedControl.anchor(top: moodLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 40)
        
        genreLabel.anchor(top: moodSegmentedControl.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        genrePickerView.anchor(top: genreLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 120)
        
        tempoLabel.anchor(top: genrePickerView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        tempoSegmentedControl.anchor(top: tempoLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 40)
        
        instrumentLabel.anchor(top: tempoSegmentedControl.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        instrumentPickerView.anchor(top: instrumentLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 120)
        
        structureLabel.anchor(top: instrumentPickerView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        structureSegmentedControl.anchor(top: structureLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 40)
        
        mainMessageLabel.anchor(top: structureSegmentedControl.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        mainMessageTextView.anchor(top: mainMessageLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 100)
        
        generateButton.anchor(top: mainMessageTextView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingRight: 40, height: 50)
        
        loadingIndicator.anchor(centerX: generateButton.centerXAnchor, centerY: generateButton.centerYAnchor)
        
        contentView.bottomAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 40).isActive = true
    }
    
    func setupUI() {
        themeTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        themeTextField.textColor = .white
        themeTextField.layer.cornerRadius = 8
        themeTextField.layer.borderWidth = 1
        themeTextField.layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor
        themeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: themeTextField.frame.height))
        themeTextField.leftViewMode = .always
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(white: 0.9, alpha: 1.0)
        return label
    }
    
    func configureBottomBar() {
        let feedViewModel = BottomBarViewModel(selectedTab: .ai(isSelected: true))
        bottomBar.viewModel = feedViewModel
        bottomBar.delegate = self
        
        view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 55)
    }
}

extension CreateSongWithAIViewController {
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
            if themeTextField.isFirstResponder {
                activeField = themeTextField
            } else if mainMessageTextView.isFirstResponder {
                activeField = mainMessageTextView
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

extension CreateSongWithAIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genrePickerView {
            return genreOptions.count
        } else if pickerView == instrumentPickerView {
            return instrumentOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genrePickerView {
            return genreOptions[row]
        } else if pickerView == instrumentPickerView {
            return instrumentOptions[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        
        if pickerView == genrePickerView {
            label.text = genreOptions[row]
        } else if pickerView == instrumentPickerView {
            label.text = instrumentOptions[row]
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genrePickerView {
            selectedGenre = genreOptions[row]
        } else if pickerView == instrumentPickerView {
            selectedInstrument = instrumentOptions[row]
        }
    }
}

extension CreateSongWithAIViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        navigationController?.pushViewController(HomePageViewController(), animated: false)
    }
    
    func didTapFeedButton() {
        navigationController?.pushViewController(FeedViewController(), animated: false)
    }
    
    func didTapAiButton() {
        
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

extension CreateSongWithAIViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
