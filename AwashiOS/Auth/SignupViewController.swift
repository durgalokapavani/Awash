//
//  SignupViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 6/8/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var user: AWSCognitoIdentityUser?
    var codeDeliveryDetails:AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        setNeedsStatusBarAppearanceUpdate()
        
        self.addPaddingAndRadius(to: email)
        self.addPaddingAndRadius(to: password)
        
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7)])

        let myMutableTitle = NSMutableAttributedString(string: "Have an account already?", attributes: [NSAttributedStringKey.font:UIFont(name: "Rubik-Regular", size: 15)!])
        
      let mutDj = NSMutableAttributedString(string: " Log In", attributes: [NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 15)!, NSAttributedStringKey.foregroundColor: UIColor.white])
      myMutableTitle.append(mutDj)

       loginLabel.attributedText = myMutableTitle
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.goToLogin))
        loginLabel.addGestureRecognizer(tap)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    func goToLogin(sender:UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    @IBAction func signup(_ sender: Any) {
        guard let emailText = email.text, emailText != "" else {
            let alert = UIAlertController(title: "Email", message: "Please enter valid email", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        if !isValidEmail(email: emailText) {
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter valid email", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        guard let passwordText = password.text, (!passwordText.isEmpty && passwordText.count > 5) else {
            let alert = UIAlertController(title: "Password", message: "Please enter valid password, at least 6 chars", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        self.activityIndicator.startAnimating()
        
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [emailAttribute]
        
        let userPool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        
        userPool.signUp(emailText, password: passwordText, userAttributes: attributes, validationData: nil)
            .continueWith { (response) -> Any? in
                if response.error != nil {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        // Error in the Signup Process
                        let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    AnalyticsHandler.shared.trackEvent(of: .event, name: "signup", additionalInfo: ["sign_up_method" : userPool.identityProviderName, "user" : emailText])
                    
                    self.user = response.result!.user
                    // Does user need confirmation?
                    if (response.result?.userConfirmed?.intValue != AWSCognitoIdentityUserStatus.confirmed.rawValue) {
                        // User needs confirmation, so we need to proceed to the verify view controller
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.codeDeliveryDetails = response.result?.codeDeliveryDetails
                            
                            /*
                            let verifyVC = VerificationViewController(nibName: "VerificationViewController", bundle: nil)
                            verifyVC.user = self.user
                            verifyVC.codeDeliveryDetails = self.codeDeliveryDetails
                            self.navigationController?.pushViewController(verifyVC, animated: true)
 */
                        }
                    } else {
                        // User signed up but does not need confirmation.  This should rarely happen (if ever).
                        DispatchQueue.main.async {
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return nil
        }
    }
}
