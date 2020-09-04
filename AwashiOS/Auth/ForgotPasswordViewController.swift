//
//  ForgotPasswordViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 6/9/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var verificationCode: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var emailAddress:String = ""
    var user:AWSCognitoIdentityUser?
    
    func addPaddingAndRadius(to textfield: UITextField) {
        textfield.layer.masksToBounds = true
        textfield.layer.cornerRadius = 25
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 2.0))
        textfield.leftView = leftView
        textfield.leftViewMode = .always
        
        textfield.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userPool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        
        if !emailAddress.isEmpty {
            // Get a reference to the user using the email address
            user = userPool.getUser(emailAddress)
            // Initiate the forgot password process which will send a verification code to the user
            user?.forgotPassword()
                .continueWith(block: { (response) -> Any? in
                    if response.error != nil {
                        // Cannot request password reset due to error (for example, the attempt limit exceeded)
                        let alert = UIAlertController(title: "Cannot Reset Password", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return nil
                    }
                    // Password reset was requested and message sent.  Let the user know where to look for code.
                    let result = response.result
                    let isEmail = (result?.codeDeliveryDetails?.deliveryMedium == AWSCognitoIdentityProviderDeliveryMediumType.email)
                    let destination:String = result!.codeDeliveryDetails!.destination!
                    let medium = isEmail ? "an email" : "a text message"
                    let alert = UIAlertController(title: "Verification Sent", message: "You should receive \(medium) with a verification code at \(destination).  Enter that code here along with a new password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return nil
                })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addPaddingAndRadius(to: verificationCode)
        self.addPaddingAndRadius(to: newPassword)
        self.addPaddingAndRadius(to: confirmPassword)
        verificationCode.attributedPlaceholder = NSAttributedString(string: "Verification Code", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        newPassword.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        confirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    
    @IBAction func resetPasswordPressed(_ sender: AnyObject) {
        user?.confirmForgotPassword(self.verificationCode.text!, password: self.newPassword.text!)
            .continueWith { (response) -> Any? in
                if response.error != nil {
                    // The password could not be reset - let the user know
                    let alert = UIAlertController(title: "Cannot Reset Password", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Resend Code", style: .default, handler: { (action) in
                        self.user?.forgotPassword()
                            .continueWith(block: { (result) -> Any? in
                                print("Code Sent")
                                return nil
                            })
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    // Password reset.  Send the user back to the login and let them know they can login with new password.
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Password Reset", message: "Password reset.  Please log into the account with your email and new password.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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

}
