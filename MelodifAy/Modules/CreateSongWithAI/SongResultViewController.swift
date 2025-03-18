//
//  SongResultViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 18.03.2025.
//

import UIKit

class SongResultViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    var songResult: String?
    var songTheme: String?
    var songMood: String?
    var songGenre: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Şarkınız Oluşturuldu"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Şarkı Başlığı"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let infoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let themeLabel = SongInfoLabel(title: "Konu", info: "")
    private let moodLabel = SongInfoLabel(title: "Ruh Hali", info: "")
    private let genreLabel = SongInfoLabel(title: "Tür", info: "")
    
    private let lyricsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let lyricsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Şarkı Sözleri"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return label
    }()
    
    private let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isSelectable = true
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    private let createMusicButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Müzik Oluştur", for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kaydet", for: .normal)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0).cgColor
        return button
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let tryAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yeniden Dene", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureBottomBar()
        configureScrollView()
        configureWithExt()
        setupLyricsView()
        addTargetButtons()
        showAlert()
        
        if let songResult = songResult {
            parseSongResult(songResult)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.createMusicButton.applyGradient(colors: [
                UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0),
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
            ])
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Önemli", message: "Müzik oluşturmak için notaları kopyalamayı unutmayın", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func parseSongResult(_ result: String) {
        if let titleRange = result.range(of: "(?<=Başlık:|Title:)[^\\n]+", options: .regularExpression) {
            let title = result[titleRange].trimmingCharacters(in: .whitespacesAndNewlines)
            songTitleLabel.text = title
        } else {
            songTitleLabel.text = "Yeni Şarkı"
        }
        
        lyricsTextView.text = result
        
        if let theme = songTheme {
            themeLabel.infoText = theme
        }
        
        if let mood = songMood {
            moodLabel.infoText = mood
        }
        
        if let genre = songGenre {
            genreLabel.infoText = genre
        }
    }
    
    private func addTargetButtons() {
        createMusicButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        tryAgainButton.addTarget(self, action: #selector(tryAgainButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButton_Clicked), for: .touchUpInside)
    }
    
    @objc private func copyButton_Clicked() {
        guard let lyrics = lyricsTextView.text, !lyrics.isEmpty else { return }
        
        UIPasteboard.general.string = lyrics
        
        copyButton.setTitle("Kopyalandı", for: .normal)
        copyButton.setImage(nil, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.copyButton.setTitle("", for: .normal)
            self.copyButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        }
    }
    
    @objc private func shareButtonTapped() {
        guard let lyrics = lyricsTextView.text else { return }
        
        let activityVC = UIActivityViewController(activityItems: [lyrics], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        UIView.animate(withDuration: 0.3) {
            self.saveButton.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
            self.saveButton.setTitle("Kaydedildi", for: .normal)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                self.saveButton.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
                self.saveButton.setTitle("Kaydet", for: .normal)
            }
        }
    }
    
    @objc private func tryAgainButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension SongResultViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width)
    }
    
    func configureWithExt() {
        contentView.addViews(titleLabel, songTitleLabel, infoContainer, lyricsContainer, createMusicButton, saveButton, tryAgainButton)
        
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        songTitleLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        infoContainer.anchor(top: songTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 80)
        
        lyricsContainer.anchor(top: infoContainer.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        let buttonStackView = UIStackView(arrangedSubviews: [createMusicButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 15
        
        contentView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonStackView.anchor(top: lyricsContainer.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 50)
        
        tryAgainButton.anchor(top: buttonStackView.bottomAnchor, centerX: contentView.centerXAnchor, paddingTop: 20, height: 30)
        
        contentView.bottomAnchor.constraint(equalTo: tryAgainButton.bottomAnchor, constant: 30).isActive = true
        
        setupInfoContainer()
    }
    
    func setupInfoContainer() {
        infoContainer.addViews(themeLabel, moodLabel, genreLabel)
        
        let stackView = UIStackView(arrangedSubviews: [themeLabel, moodLabel, genreLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        infoContainer.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.anchor(top: infoContainer.topAnchor, left: infoContainer.leftAnchor, right: infoContainer.rightAnchor, bottom: infoContainer.bottomAnchor, paddingTop: 15, paddingLeft: 15, paddingRight: 15, paddingBottom: 15)
    }
    
    func setupLyricsView() {
        lyricsContainer.addViews(lyricsHeaderLabel, lyricsTextView, copyButton)
        
        lyricsHeaderLabel.anchor(top: lyricsContainer.topAnchor, left: lyricsContainer.leftAnchor, paddingTop: 15, paddingLeft: 15)
        
        copyButton.anchor(top: lyricsContainer.topAnchor, right: lyricsContainer.rightAnchor, paddingTop: 15, paddingRight: 15)
        
        lyricsTextView.anchor(top: lyricsHeaderLabel.bottomAnchor, left: lyricsContainer.leftAnchor, right: lyricsContainer.rightAnchor, bottom: lyricsContainer.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, paddingBottom: 15)
        
        lyricsContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
    }
    
    func configureBottomBar() {
        let aiViewModel = BottomBarViewModel(selectedTab: .ai(isSelected: true))
        bottomBar.viewModel = aiViewModel
        bottomBar.delegate = self
        
        view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 55)
    }
}

extension SongResultViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        navigationController?.pushViewController(HomePageViewController(), animated: false)
    }
    
    func didTapFeedButton() {
        navigationController?.pushViewController(FeedViewController(), animated: false)
    }
    
    func didTapAiButton() {
        navigationController?.pushViewController(CreateSongWithAIViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

class SongInfoLabel: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    var infoText: String {
        get { return infoLabel.text ?? "" }
        set { infoLabel.text = newValue }
    }
    
    init(title: String, info: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        infoLabel.text = info
        
        addSubview(titleLabel)
        addSubview(infoLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
