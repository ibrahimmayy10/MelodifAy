//
//  MusicPlayerService.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.12.2024.
//

import Foundation
import AVFoundation

class MusicAudioPlayerService: NSObject {
    static let shared = MusicAudioPlayerService()
    
    private var player: AVAudioPlayer?
    private var audioTimer: Timer?
    var isPlaying = false
    
    var music: MusicModel?
    
    var progressHandler: ((TimeInterval, TimeInterval) -> Void)?
    var playbackStateHandler: ((Bool) -> Void)?
    var playbackCompletionHandler: (() -> Void)?
    var loadingStateHandler: ((Bool) -> Void)?
    var musicStatusChangedHandler: ((MusicModel?, Bool) -> Void)?
    
    private override init() {}
    
    func playMusic(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        loadingStateHandler?(true)
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self, let data = data, error == nil else {
                print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self?.loadingStateHandler?(false)
                }
                return
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.player = try AVAudioPlayer(data: data)
                self.player?.delegate = self
                self.player?.prepareToPlay()
                
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                    self.startPlayback()
                    self.musicStatusChangedHandler?(self.music, true)
                    self.isPlaying = true
                }
            } catch {
                print("Audio player initialization error: \(error)")
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                }
            }
        }.resume()
    }
    
    private func downloadAndPlayMusic(from url: URL) {
        URLSession.shared.downloadTask(with: url) { [weak self] (tempLocalUrl, response, error) in
            guard let self = self, let tempLocalUrl = tempLocalUrl else {
                print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self?.loadingStateHandler?(false)
                }
                return
            }
            
            do {
                self.player = try AVAudioPlayer(contentsOf: tempLocalUrl)
                self.player?.delegate = self
                self.player?.prepareToPlay()
                
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                    self.startPlayback()
                }
            } catch {
                print("Audio player initialization error: \(error)")
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                }
            }
        }.resume()
    }
    
    func startPlayback() {
        player?.play()
        playbackStateHandler?(true)
        startProgressTimer()
        self.isPlaying = true
        musicStatusChangedHandler?(music, true)
    }
    
    func pausePlayback() {
        player?.pause()
        playbackStateHandler?(false)
        stopProgressTimer()
        self.isPlaying = false
        musicStatusChangedHandler?(music, false)
    }
    
    func stopPlayback() {
        player?.stop()
        player?.currentTime = 0
        playbackStateHandler?(false)
        stopProgressTimer()
        self.isPlaying = false
        musicStatusChangedHandler?(music, false)
    }
    
    private func startProgressTimer() {
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            let currentTime = player.currentTime
            let duration = player.duration
            
            self.progressHandler?(currentTime, duration)
            
            if currentTime >= duration {
                self.stopPlayback()
                self.playbackCompletionHandler?()
            }
        }
    }
    
    private func stopProgressTimer() {
        audioTimer?.invalidate()
        audioTimer = nil
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }
}

extension MusicAudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.playbackCompletionHandler?()
            self.isPlaying = false
            self.musicStatusChangedHandler?(self.music, false)
        }
    }
}
