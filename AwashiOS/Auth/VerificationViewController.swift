//
//  VerificationViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 6/8/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import MessageUI

class VerificationViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var verificationCode: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verificationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //var codeDeliveryDetails:AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    
    //var user: AWSCognitoIdentityUser?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addPaddingAndRadius(to: verificationCode)
        verificationCode.attributedPlaceholder = NSAttributedString(string: "Verification Code", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

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
    
    
    func resetConfirmation(message:String? = "") {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.verificationCode.text = ""
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
            self.present(alert, animated: true, completion:nil)
        }
        
    }
    
    @IBAction func confirm(_ sender: Any) {
        guard let code = verificationCode.text, code != "" else {
             let alert = UIAlertController(title: "Invalid", message: "Please enter valid verification code", preferredStyle: .alert)
             
             alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
             
             self.present(alert, animated: true)
            return
        }
        self.activityIndicator.startAnimating()
        
        let validate = ValidateAccessCodeUseCase()
        validate.delegate = self
        validate.params["accessCode"] = code
        validate.performAction()
        
        /*
        self.user?.confirmSignUp(verificationCode.text!)
            .continueWith(block: { (response) -> Any? in
                if response.error != nil {
                    self.resetConfirmation(message: (response.error! as NSError).userInfo["message"] as? String)
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        // Return to Login View Controller - this should be handled a bit differently, but added in this manner for simplicity
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                return nil
            })
         */
    }
    
    /*
    @IBAction func resendConfirmationCodePressed(_ sender: AnyObject) {
        self.user?.resendConfirmationCode()
            .continueWith(block: { (respone) -> Any? in
                let alert = UIAlertController(title: "Resent", message: "The confirmation code has been resent.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion:nil)
                return nil
            })
    }
 */
    
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
    
    //MARK: Button actions
    @IBAction func emailTapped(_ sender: Any) {
        self.sendEmail()
        
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hello@pondrcbd.com"])
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension VerificationViewController: ValidateAccessCodeUseCaseDelegate {
    
    func validationSuccess() {
        UserDefaultsUtil.storeAccessCode(code: verificationCode.text!)
        self.activityIndicator.stopAnimating()
        let window = UIApplication.shared.windows[0]
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    func validationFailure() {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Invalid", message: "Please enter valid verification code", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        DispatchQueue.main.async  {
            self.present(alert, animated: true)
        }
        
        
    }
}
