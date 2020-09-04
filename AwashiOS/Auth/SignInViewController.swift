//
//  SignInViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 6/8/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSUserPoolsSignIn

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var signInCompletionHandler: ((_ success: Bool) -> ())?
    
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
        
        let myMutableTitle = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedStringKey.font:UIFont(name: "Rubik-Regular", size: 15)!])
        
        let mutDj = NSMutableAttributedString(string: " Sign Up", attributes: [NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 15)!, NSAttributedStringKey.foregroundColor: UIColor.white])
        myMutableTitle.append(mutDj)
        
        signupLabel.attributedText = myMutableTitle
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.goToSignup))
        signupLabel.addGestureRecognizer(tap)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    func goToSignup(sender:UITapGestureRecognizer) {
        let signupVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
        
        self.navigationController?.pushViewController(signupVC, animated: true)
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
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    @IBAction func signIn(_ sender: Any) {
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
        let userPool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        let user = userPool.getUser(emailText)
        user.getSession(emailText, password: passwordText, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: {
            (task:AWSTask!) -> AnyObject? in
            self.activityIndicator.stopAnimating()
            
            if task.error == nil {
                self.dismiss(animated: true, completion: {
                    self.signInCompletionHandler?(true)
                })
            } else {
                // error
                let alertController = UIAlertController(title: "Cannot Login",
                                                        message: (task.error! as NSError).userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            }
            
            return nil
        })
        
        
    }
    
    @IBAction func forgotPasswordPressed(_ sender: AnyObject) {
        if (self.email?.text == nil || self.email!.text!.isEmpty) {
            let alertController = UIAlertController(title: "Enter email",
                                                    message: "Please enter your email and then select Forgot Password if you want to reset your password.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(retryAction)
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        let forgotPasswordVC = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        forgotPasswordVC.emailAddress = (self.email?.text)!
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
}


