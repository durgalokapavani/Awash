//
//  AwashPlayer.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

@objc protocol AwashPlayerDelegate {
    
    @objc func updateTime(currentTime: Double, duration: Double)
    @objc func playing()
    @objc func paused()
}

class AwashPlayer {
    static let shared = AwashPlayer()
    
    var player: AVPlayer?
    var playerItem:CachingPlayerItem?
    var postActivityUseCase: PostActivityUseCase?
    var meditationToPlay:Meditation?
    var playerTimer:Timer?
    
    weak var delegate: AwashPlayerDelegate?
    
    private init() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the pause command
            self.pause()
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the play command
            self.continuePlaying()
            return .success
        }
        
    }
    
    func play(meditation: Meditation) {
        self.player?.pause()
        guard let url = URL(string: meditation.url!),
            let name = meditation.meditationName else{
            return
        }
        self.meditationToPlay = meditation
        //TODO: Generate the URL for paid meditations
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyAlbumTitle:"Awash", MPMediaItemPropertyTitle: name]
        
        //Fetch object in cache
        do {
            let cacheObject = try AwashCache.shared.storage?.object(forKey: url.absoluteStringByTrimmingQuery()!)
            self.playerItem = CachingPlayerItem(data: cacheObject!, mimeType: "audio/mpeg", fileExtension: ".mp3")
        } catch {
            print(error) //unable find the object in cache
            self.playerItem = CachingPlayerItem(url: url)
        }
        
        self.playerItem?.delegate = self
        self.player = AVPlayer(playerItem: self.playerItem)
        self.player?.automaticallyWaitsToMinimizeStalling = false
        self.continuePlaying()
        
        AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.MEDITATION_PLAYED, additionalInfo: ["meditatioName": name])
    }
    
    func continuePlaying()  {
        playerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayerTime), userInfo: nil, repeats: true)
        
        self.player?.play()
        self.delegate?.playing()
    }
    
    func pause(){
        self.player?.pause()
        self.delegate?.paused()
        playerTimer?.invalidate()
       
    }
    
    func stop(){
        self.player?.pause()
        self.delegate?.paused()
        playerTimer?.invalidate()
        guard let url = self.meditationToPlay?.url,
            let _ = URL(string: (url)),
            let _ = self.meditationToPlay?.meditationName else{
                return
        }
        
        guard let t1 = self.player?.currentTime().value,
            let t2 = self.player?.currentTime().timescale else{
                return
        }
        
        let currentSeconds = Int(round(Float(t1)/Float(t2)))
        if currentSeconds >= 1 {
            postActivity(seconds: currentSeconds)
        }
        
    }
    
    func seek(value: Double) {
        if let currentItem = player?.currentItem {
            let durationInSecs:Double = currentItem.duration.seconds
            
            if durationInSecs > 0 {
                self.player?.seek(to: CMTimeMakeWithSeconds(durationInSecs * value, 1000))
            }
            
        }
    }
    
    //MARK: Private methods
    @objc func updatePlayerTime(){
        if let avplayer = player, avplayer.isPlaying {
            let currentTimeInSecs:Double = player!.currentItem!.currentTime().seconds
            let durationInSecs:Double = player!.currentItem!.duration.seconds

            if durationInSecs > 0 {
                self.delegate?.updateTime(currentTime: currentTimeInSecs, duration: durationInSecs)
            } else {
                playerTimer?.invalidate()
            }
            
        }
        
    }
    
    
    
    fileprivate func postActivity(seconds: Int) {
        if let meditation = meditationToPlay {
            AwashUser.shared.getUserId() { userId in
                AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.POST_ACTIVITY, additionalInfo: ["playTime": String(seconds), "category": meditation.category!, "title": meditation.meditationName!])
                let currentActivity = PostActivity(category: meditation.category!, title: meditation.title!, userId: userId, meditationName: meditation.meditationName!, playTime: seconds)
                self.postActivityUseCase = PostActivityUseCase(activity: currentActivity)
                self.postActivityUseCase?.performAction()
            }
            
        }
    }
}

extension AwashPlayer: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("File is downloaded and ready for storing")
        try? AwashCache.shared.storage?.setObject(data, forKey: playerItem.url.absoluteStringByTrimmingQuery()!)
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        print("we are ready to play")
    }
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
    }
    
}

extension URL {
    
    func absoluteStringByTrimmingQuery() -> String? {
        if var urlcomponents = URLComponents(url: self as URL, resolvingAgainstBaseURL: false) {
            urlcomponents.query = nil
            return urlcomponents.string
        }
        return nil
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

