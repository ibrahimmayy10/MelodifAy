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
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    var isPlaying = false
    
    var music: MusicModel?
    
    var progressHandler: ((TimeInterval, TimeInterval) -> Void)?
    var miniProgressHandler: ((TimeInterval, TimeInterval) -> Void)?
    var playbackStateHandler: ((Bool) -> Void)?
    var playbackCompletionHandler: (() -> Void)?
    var loadingStateHandler: ((Bool) -> Void)?
    var musicStatusChangedHandler: ((MusicModel?, Bool) -> Void)?
    
    private override init() {}
    
    func playMusic(from urlString: String) {
        stopAndCleanupPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        loadingStateHandler?(true)
        
        player = AVPlayer(url: url)
        
        player?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        DispatchQueue.main.async {
            self.startPlayback()
            self.musicStatusChangedHandler?(self.music, true)
            self.isPlaying = true
        }
    }
    
    private func stopAndCleanupPlayer() {
        stopPlayback()
        
        if let player = player {
            player.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
        
        stopProgressTimer()
        
        player = nil
    }
    
    @objc private func playbackDidFinish() {
        stopPlayback()
        playbackCompletionHandler?()
    }
    
    func startPlayback() {
        player?.play()
        playbackStateHandler?(true)
        startProgressTimer()
        isPlaying = true
        musicStatusChangedHandler?(music, true)
    }
    
    func pausePlayback() {
        player?.pause()
        playbackStateHandler?(false)
        stopProgressTimer()
        isPlaying = false
        musicStatusChangedHandler?(music, false)
    }
    
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        playbackStateHandler?(false)
        stopProgressTimer()
        isPlaying = false
        musicStatusChangedHandler?(music, false)
    }
    
    private func startProgressTimer() {
        guard let player = player else { return }
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self, let currentItem = player.currentItem else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(currentItem.duration)
            
            self.progressHandler?(currentTime, duration)
            self.miniProgressHandler?(currentTime, duration)
            
            if currentTime >= duration {
                self.stopPlayback()
                self.playbackCompletionHandler?()
            }
        }
    }
    
    private func stopProgressTimer() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.status == .readyToPlay {
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                    self.startPlayback()
                    self.isPlaying = true
                    self.musicStatusChangedHandler?(self.music, true)
                }
            } else if player?.status == .failed {
                DispatchQueue.main.async {
                    self.loadingStateHandler?(false)
                    print("Player failed to load")
                }
            }
        }
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
}
