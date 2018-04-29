//
//  ViewController.swift
//  Marakasu
//
//  Created by 原田 礼朗 on 2018/04/29.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import youtube_ios_player_helper

class ViewController: UIViewController,YTPlayerViewDelegate {
    
    @IBOutlet weak var yotubePlayerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    var audioPlayers = [AVAudioPlayer]()
    var motionManager = CMMotionManager()
    let musicTime = TimeInterval(5)
    var pos = (0,0,0)
    var videoId = ""
    let playerVars = ["playsinline":1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMotionManager()
        youtubePlayerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if videoId != "" {
            LoadingManager.shared.showLoading()
            youtubePlayerView.load(withVideoId: videoId, playerVars: playerVars)
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .unstarted:
            print("停止中")
        case .playing:
            print("再生中")
        case .paused:
            print("一時停止中")
        case .buffering:
            print("バッファリング中")
        case .ended:
            print("再生終了")
        case .queued:
            print("queued")
        case .unknown:
            print("unknown")
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        LoadingManager.shared.hideLoading()
    }
    
    func setAudioPlayer() -> AVAudioPlayer? {
        if let path = Bundle.main.path(forResource: "maracas", ofType: "m4a") {
            if let url = URL(string: path) {
                let audioPlayer = try? AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                return audioPlayer
            }
        }
        return nil
    }
    
    func setMotionManager() {
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            if error == nil {
                self.updateAccelerationData(acceleration: motion?.userAcceleration)            }
        }
    }
    
    func updateAccelerationData(acceleration: CMAcceleration?) {
        guard let acceler = acceleration else {
            return
        }
        let isShake = pos.0 != Int(acceler.x) || pos.1 != Int(acceler.y) || pos.2 != Int(acceler.z)
        if isShake {
            soundMusic()
        }
        pos = (Int(acceler.x), Int(acceler.y), Int(acceler.z))
    }
    
    @IBAction func tapMaracas(_ sender: Any) {
        soundMusic()
    }
    
    func soundMusic() {
        if let audio = setAudioPlayer() {
            audio.play()
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (ti) in
                audio.stop()
            }
        }
    }
    
    enum buttonState {
        case start,stop
    }
    var state = buttonState.start
    @IBAction func tapStartButton(_ sender: UIButton) {
        if videoId == "" {
            return
        }
        var height = CGFloat(0)
        switch state {
        case .start:
            youtubePlayerView.playVideo()
            state = buttonState.stop
            sender.setTitle("ミュージックストップ", for: .normal)
            height = 300
            break
        default:
            youtubePlayerView.stopVideo()
            state = buttonState.start
            sender.setTitle("ミュージックスタート", for: .normal)
        }
        yotubePlayerViewHeight.constant = height
        UIView.animate(withDuration: 0.5) {
            self.youtubePlayerView.layoutIfNeeded()
        }
    }
    
}

