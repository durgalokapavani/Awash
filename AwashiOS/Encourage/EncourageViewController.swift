//
//  EncourageViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/3/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit
import UserNotifications


class EncourageViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var goalTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hoursSegment: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var noGoalView: RoundUIView!
    @IBOutlet weak var rateGoal: RoundUIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageGroupView: UIView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
    let placeHolderColor = UIColor(hex: "3476FF").withAlphaComponent(0.6)
    let regularTextColor = UIColor(hex: "002D9C")
    var currentRating = 3
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Mark: Keyboard related
    @objc func handleKeyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let userInfo = notification.userInfo!
            let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 40, right: 0)
            
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        
        let userInfo = notification.userInfo!
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        self.textView.delegate = self
        goalTextView.text = "Set a goal"
        goalTextView.textColor = placeHolderColor
        self.goalTextView.delegate = self

        self.hoursSegment.layer.cornerRadius = 20
        self.hoursSegment.layer.masksToBounds = true
        self.hoursSegment.layer.borderWidth = 1.0
        self.hoursSegment.layer.borderColor = UIColor(hex: "ff0044").cgColor
        let attr = NSDictionary(object: UIFont(name: "Rubik-Regular", size: 13.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        hoursSegment.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        
        self.noGoalView.isHidden = true
        self.rateGoal.isHidden = false
        self.activityIndicator.stopAnimating()
        
        //Fetch Goal
        if AwashUser.shared.isLoggedIn() {
            self.fetchGoal()
        } else {
            self.noGoalView.isHidden = true
            self.rateGoal.isHidden = true
        }
        
        
        minusButton.setTitle("\u{2212}", for: .normal)
        plusButton.setTitle("\u{002B}", for: .normal)
    }
    
    private func fetchGoal(){
        checkForConnectivityAndPerform {
            let getGoalsUseCase = GetGoalUseCase()
            getGoalsUseCase.performAction { (success, goal) in
                if success && goal == nil{
                    self.noGoalView.isHidden = false
                    self.rateGoal.isHidden = true
                    
                } else if success && goal != nil {
                    self.goalLabel.text = " \"\(goal?.goal?.capitalizingFirstLetter() ?? "")\""
                    self.setSimleyBasedOnRating(rating: self.currentRating)
                    self.rateGoal.isHidden = false
                    
                }
                
            }
        }
    }
    
    private func postGoal(goal: String){
        guard AwashUser.shared.isLoggedIn() else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.checkForConnectivityAndPerform {
            let postGoalsUseCase = PostGoalUseCase(goal: goal)
            postGoalsUseCase.performAction { (success) in
                if success {
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.GOAL_ADDED, additionalInfo: ["goal": goal])
                    self.goalLabel.text = goal
                    self.noGoalView.isHidden = true
                    self.animateView(view: self.rateGoal, hidden: false)
                    
                } else {
                    self.animateView(view: self.noGoalView, hidden: false)
                    self.animateView(view: self.rateGoal, hidden: true)
                    
                }
                
            }
        }
        
    }
    
    private func postRating(){
        guard AwashUser.shared.isLoggedIn() else {
            return
        }
        self.checkForConnectivityAndPerform {
            let postRatingUseCase = PostRatingUseCase(rating: self.currentRating)
            postRatingUseCase.performAction { (success) in
                if success {
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.RATING_POSTED, additionalInfo: ["rating": String(self.currentRating)])
                }
                
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setSimleyBasedOnRating(rating: self.currentRating)
    }
    
    //MARK: Private fucntions
    private func animateView(view: UIView, hidden: Bool) {
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.9,
                       options: UIViewAnimationOptions(),
                       animations: {
                        self.activityIndicator.stopAnimating()
                        view.isHidden = hidden
        },
                       completion: nil)
    }
    
    private func getImageByRating(rating: Int)  -> UIImage? {
        switch rating {
        case 1:
            return #imageLiteral(resourceName: "sadWhite")
        case 2:
            return #imageLiteral(resourceName: "sadNuetralWhite")
        case 3:
            return #imageLiteral(resourceName: "nuetralHappyWhite")
        case 4:
            return #imageLiteral(resourceName: "nuetralWhite")
        case 5:
            return #imageLiteral(resourceName: "happyWhite")
        default:
            return #imageLiteral(resourceName: "nuetralWhite")
        }
    }
    
    private func getTextForRating(rating: Int)  -> String {
        switch rating {
        case 1:
            return "It's okay to be not okay. And today I am not ok."
        case 2:
            return "Today has been tough but tomorrow is a new day."
        case 3:
            return "Rollin' with punches. I will survive."
        case 4:
            return "I am doing well. Things are looking, up!"
        case 5:
            return "Feelin great! Where the party at?"
        default:
            return "Rollin' with punches. I will survive."
        }
    }
    
    private func setSimleyBasedOnRating(rating: Int){
        
        self.imageGroupView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        ratingLabel.text = self.getTextForRating(rating: rating)
        let smiley = UIImageView(image: self.getImageByRating(rating: rating))
        smiley.frame = CGRect(x: 0, y: 0, width: 37, height: 45)
        
        self.imageGroupView.addSubview(smiley)
        let eachSmileyWidth = self.imageGroupView.bounds.width/5
        smiley.center = CGPoint(x: eachSmileyWidth * CGFloat(rating), y: self.imageGroupView.frame.minY - 4)
        
        self.progressView.setProgress(Float(Float(rating)/5), animated: true)
        self.progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        self.view.layoutIfNeeded()
        
        
    }
    
    //MARK: Buttons
    @IBAction func minusTapped() {
        if currentRating == 1 { return }
        
        currentRating -= 1
        setSimleyBasedOnRating(rating: currentRating)
    }
    
    @IBAction func plusTapped() {
        if currentRating == 5 { return }
        
        currentRating += 1
        
        setSimleyBasedOnRating(rating: currentRating)
        
    }
    
    @IBAction func doneTapped() {
        self.postRating()
        guard let text = textView.text, !text.isEmpty else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.center.requestAuthorization(options: self.options) {
                    (granted, error) in
                    if granted {
                        DispatchQueue.main.sync {
                            self.sendLocalNotification()
                            
                        }
                        
                    }
                }
            } else {
                DispatchQueue.main.sync {
                    self.sendLocalNotification()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    //Mark: Send Scheduled notification
    fileprivate func sendLocalNotification() {
        InAppRatingHandler.shared.showRatingForRule(rule: .encourage)
        let content = UNMutableNotificationContent()
        content.title = "Encourage Yourself"
        content.body = self.textView.text!
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "AwashReminderCategory"
        
        //TODO: Read the time interval from Segment control
        var minutes = random(180..<300)
        switch self.hoursSegment.selectedSegmentIndex {
        case 0:
            //1-2 hours
            minutes = random(60..<120)
        case 1:
            //4-5 hours
            minutes = random(240..<300)
        default:
            //Supriese Me: 3-5 hours
            minutes = random(180..<300)
        }
        let date = Date(timeIntervalSinceNow: Double(minutes) * 60)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        let identifier = "AwashLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze 10 mins", options: [])
        
        let category = UNNotificationCategory(identifier: "AwashReminderCategory",
                                              actions: [snoozeAction],
                                              intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
        
        AnalyticsHandler.shared.trackEvent(of: .event, name: "encourage_yourself", additionalInfo: ["shedule":"\(self.hoursSegment.selectedSegmentIndex)" , "minutes":"\(minutes)"])
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: Random number generator
    fileprivate func random(_ range:Range<Int>) -> Int {
        return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
    }

    //MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == goalTextView && textView.textColor == placeHolderColor {
            textView.text = nil
            textView.textColor = regularTextColor
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            guard let text = textView.text, !text.isEmpty else {
                return true
            }
            
            if textView == goalTextView {
                self.noGoalView.isHidden = true
                self.activityIndicator.startAnimating()
                if let goal =  textView.text {
                    self.postGoal(goal: goal)
                }
                
            }
            
            return false
        }
        return true
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
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
}

extension EncourageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: self.view).y
        
        if (scrollView.contentOffset.y == CGFloat(0)) &&
            (self.view.frame.maxY == UIScreen.main.bounds.maxY) &&
            (direction > 0) {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        return false
    }
}
