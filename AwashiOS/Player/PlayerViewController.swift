//
//  PlayerViewController.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit

class PlayerViewController: BaseViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let imageGradient = CAGradientLayer()
    
    var playPauseButton: PlayPauseButton!
    
    var meditation:Meditation?
    var category:Category?
    var getDownloadUrlUseCase: GetDownloadUrlUseCase?
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playPauseButton = PlayPauseButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.playPauseButton.addTarget(self, action: #selector(self.playPauseButtonTapped), for:.touchUpInside)
        self.view.addSubview(self.playPauseButton)
        self.playPauseButton.showsMenu = true
        
        self.navigationController?.navigationBar.isHidden = true
        
        if (category?.isCourse)! {
            self.backgroundImageView.image = UIImage(named: Utilities.getDayOfWeek())
        } else {
            self.backgroundImageView.image = UIImage(named: category!.type!)
        }
        
        
        if self.meditation != nil && !meditation!.url!.isEmpty {
            AwashPlayer.shared.delegate = self
            AwashPlayer.shared.play(meditation: self.meditation!)
            /*
            getDownloadUrlUseCase = GetDownloadUrlUseCase(meditationName: meditation!.meditationName!)
            getDownloadUrlUseCase?.performAction{ (success, url) in
                if success {
                    self.meditation!.url = url
                    AwashPlayer.shared.delegate = self
                    AwashPlayer.shared.play(meditation: self.meditation!)
                    
                }
            }
             */
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        slider.minimumTrackTintColor = UIColor.white.withAlphaComponent(1.0)
        self.playPauseButton.center = CGPoint(x: self.slider.center.x, y: self.slider.center.y - 50)
        if self.category != nil {
            imageGradient.removeFromSuperlayer()
            backgroundImageView.addGradientLayer(frame: self.backgroundImageView.frame, colors: Utilities.gradientForImage(name: category!.type!), gradient: imageGradient)
        }
        
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let encourageVC = EncourageViewController(nibName: "EncourageViewController", bundle: nil)
                encourageVC.modalPresentationStyle = .overFullScreen
                encourageVC.modalPresentationCapturesStatusBarAppearance = true
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController?.present(encourageVC, animated: true, completion: nil)
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AwashPlayer.shared.stop()
        AwashPlayer.shared.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private
    fileprivate func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        
        return (hours, minutes, seconds)
    }
    
    fileprivate func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    @IBAction func sliderValueDidChange(sender:UISlider!) {
        print("value--\(sender.value)")
        print("double value--\(Double(sender.value))")
        AwashPlayer.shared.seek(value: Double(sender.value))
    }
    
    //MARK: Play/Pause button
    @objc func playPauseButtonTapped() {
        if let playing = AwashPlayer.shared.player?.isPlaying, playing == true{
            AwashPlayer.shared.pause()
            self.playPauseButton.showsMenu = false
        } else {
            AwashPlayer.shared.continuePlaying()
            self.playPauseButton.showsMenu = true
        }
    }
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }

}

extension PlayerViewController: AwashPlayerDelegate {
    func updateTime(currentTime: Double, duration: Double) {
        DispatchQueue.main.async {
            let playingTime = self.formatTimeFor(seconds: currentTime)
            let durationString = self.formatTimeFor(seconds: duration)
            self.timeLabel.text = playingTime + " / " + durationString
            self.slider.value = Float(currentTime / duration)
            //print(self.slider.value)
        }
        
    }
    
    func playing() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.meditation?.meditationName
        }
    }
    
    func paused() {
        self.playPauseButton.showsMenu = false
    }
    
    
}
