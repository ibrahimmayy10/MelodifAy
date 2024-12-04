//
//  MusicPlayerService.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.12.2024.
//

import Foundation
import AVFoundation

class MusicPlayerService: NSObject {
    static let shared = MusicPlayerService()
    
    private var player: AVAudioPlayer?
    private var audioTimer: Timer?
    
    var progressHandler: ((TimeInterval, TimeInterval) -> Void)?
    var playbackStateHandler: ((Bool) -> Void)?
    var playbackCompletionHandler: (() -> Void)?
    var loadingStateHandler: ((Bool) -> Void)?
    
    private override init() {}
    
    func playMusic(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            loadingStateHandler?(true)
            downloadAndPlayMusic(from: url)
        } catch {
            print("Audio session configuration error: \(error)")
            loadingStateHandler?(false)
        }
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
    }
    
    func pausePlayback() {
        player?.pause()
        playbackStateHandler?(false)
        stopProgressTimer()
    }
    
    func stopPlayback() {
        player?.stop()
        player?.currentTime = 0
        playbackStateHandler?(false)
        stopProgressTimer()
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

extension MusicPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.playbackCompletionHandler?()
        }
    }
}
