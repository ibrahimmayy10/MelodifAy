//
//  MusicVideoPlayerService.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 5.12.2024.
//

import Foundation
import AVFoundation
import UIKit

class MusicVideoPlayerService: NSObject {
    static let shared = MusicVideoPlayerService()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    
    var progressHandler: ((TimeInterval, TimeInterval) -> Void)?
    var playbackStateHandler: ((Bool) -> Void)?
    var playbackCompletionHandler: (() -> Void)?
    var loadingStateHandler: ((Bool) -> Void)?
    
    private override init() {}
    
    func playVideoInView(in view: UIView, with url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            loadingStateHandler?(false)
            
            playerLayer?.removeFromSuperlayer()
            
            playerItem = AVPlayerItem(url: url)
            playerItem?.preferredForwardBufferDuration = 1
            player = AVPlayer(playerItem: playerItem)
            
            playerLayer = AVPlayerLayer(player: player)
            view.clipsToBounds = true
            view.layer.cornerRadius = 10
            playerLayer?.frame = view.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            
            if let playerLayer = playerLayer {
                view.layer.addSublayer(playerLayer)
            }
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerDidFinishPlaying),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            
            if timeObserverToken == nil {
                timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 10), queue: .main) { [weak self] time in
                    guard let self = self, let currentItem = self.player?.currentItem else { return }
                    
                    let currentTime = time.seconds
                    let duration = currentItem.duration.seconds
                    
                    self.progressHandler?(currentTime, duration)
                }
            }
            
            DispatchQueue.main.async {
                self.loadingStateHandler?(true)
                self.startPlayback()
            }
            
        } catch {
            print("Audio session configuration error: \(error)")
            loadingStateHandler?(false)
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        playbackCompletionHandler?()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .failed:
                    print("Player item failed")
                    loadingStateHandler?(false)
                case .unknown:
                    print("Player item status unknown")
                case .readyToPlay:
                    print("Player item ready to play")
                @unknown default:
                    break
                }
            }
        }
    }
    
    func startPlayback() {
        player?.play()
        playbackStateHandler?(true)
    }
    
    func pausePlayback() {
        player?.pause()
        playbackStateHandler?(false)
    }
    
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        playbackStateHandler?(false)
    }
    
    func seek(to time: TimeInterval) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 10)
        player?.seek(to: targetTime)
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        
        NotificationCenter.default.removeObserver(self)
        playerItem?.removeObserver(self, forKeyPath: "status")
    }
}
