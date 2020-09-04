//
//  SettingsViewController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import Crashlytics


class SettingsViewController: BaseViewController {

    //@IBOutlet weak var expirationDateLabel: UILabel!
    
    @IBOutlet weak var loginLogoutButton: UIButton!
    //@IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        //self.updateLabels()
    }
    
    /*
    fileprivate func updateLabels() {
        DispatchQueue.main.async {
            if AwashUser.shared.isLoggedIn() {
                self.loginLogoutButton.setTitle("Logout", for: .normal)
                AwashUser.shared.getUserEmail(completion: { email in
                    DispatchQueue.main.async {
                        self.emailLabel.text = email
                    }
                    
                })
            } else {
                DispatchQueue.main.async {
                    self.loginLogoutButton.setTitle("Login", for: .normal)
                    self.emailLabel.text = "Please login to subscribe"
                }
                
            }
            // set expiration date
            AwashUser.shared.isSubscribed { subscribed in
                if subscribed {
                    let expiryDate = Utilities.utcToLocal(date: IAPHandler.shared.subscriptionExpirationDate())
                    self.expirationDateLabel.text = "Subscription renews on \(expiryDate)"
                } else {
                    self.expirationDateLabel.text = "No active subscription"
                }
            }
        }
        
    }
 
 */

    @IBAction func urlTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.pondrcbd.com/") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        /*
        let aboutVC = AboutViewController(nibName: "AboutViewController", bundle: nil)
        aboutVC.modalPresentationStyle = .overFullScreen
        aboutVC.modalPresentationCapturesStatusBarAppearance = true
        self.present(aboutVC, animated: true, completion: nil)
 */
    }
    
    /*
    @IBAction func contactUsTapped(_ sender: UIButton) {
        let email = "awashapp@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
 */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func logout(_ sender: Any) {
        if AwashUser.shared.isLoggedIn() {
            AwashUser.shared.logout(completion: { success in
                self.updateLabels()
            })
            
        } else {
            self.goToLogin {
                self.fetchUserPurchases(completion: { success in
                    self.updateLabels()
                })
                
            }
        }
    }
    
    @IBAction func restore(_ sender: Any) {
        if AwashUser.shared.isLoggedIn() {
            IAPHandler.shared.restorePurchases()
        } else {
            self.goToLogin {
                IAPHandler.shared.restorePurchases()
            }
        }
        
    }
 */
    

}
