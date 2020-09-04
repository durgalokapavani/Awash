//
//  GoalViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/17/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class GoalViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textTitle: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deleteButton: UIButton!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    let placeHolderColor = UIColor(hex: "3476FF").withAlphaComponent(0.6)
    let regularTextColor = UIColor(hex: "002D9C")
    
    var goal:Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.delegate = self
        textView.text = "Set a goal"
        textView.textColor = placeHolderColor
        
        textTitle.text = "You came here for a reason\n\n What is your goal? What do you want out of this app?\n\n You owe yourself your best foot forward and we are here to help.\n\n Write a goal for yourself and you can track progress toward that goal while using the Awash app."
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        self.textView.text = goal?.goal
        
        if goal != nil {
            let originalImage = UIImage(named: "deleteIcon")
            let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
            deleteButton.setImage(tintedImage, for: .normal)
            deleteButton.tintColor = UIColor(hex: "FF0044")
        } else {
            deleteButton.isHidden = true
        }
        
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
    
    private func postGoal(goal: String){
        self.checkForConnectivityAndPerform {
            if self.goal != nil {
                let putGoalUseCase = PutGoalUseCase(goal: goal)
                putGoalUseCase.performAction { (success) in
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.GOAL_UPDATED, additionalInfo: ["goal": goal])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.GoalSet), object: nil, userInfo: [:])
                    self.dismiss(animated: true, completion: nil)
                    
                }
            } else {
                let goalsUseCase = PostGoalUseCase(goal: goal)
                goalsUseCase.performAction { (success) in
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.GOAL_ADDED, additionalInfo: ["goal": goal])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.GoalSet), object: nil, userInfo: [:])
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
            
        }
        
    }
    
    //MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHolderColor {
            textView.text = nil
            textView.textColor = regularTextColor
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            guard let text = textView.text, !text.isEmpty else {
                self.dismiss(animated: true, completion: nil)
                return true
            }
            self.postGoal(goal: text)
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Buttons
    @IBAction func deleteTapped() {
        
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this goal?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.deleteGoal()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }

        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func deleteGoal() {
        checkForConnectivityAndPerform() {
            AwashUser.shared.getUserId { (userID) in
                let deleteGoalUseCase = DeleteGoalUseCase()
                deleteGoalUseCase.performAction()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.GoalDeleted), object: nil, userInfo: [:])
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped() {
        guard let text = textView.text, !text.isEmpty else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.postGoal(goal: text)
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

extension GoalViewController: UIGestureRecognizerDelegate {
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
