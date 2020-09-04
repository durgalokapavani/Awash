//
//  BaseViewController.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSAuthUI
import Alamofire

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func goToLogin(completion: @escaping (() -> Void)) {
        print("Handling optional sign-in.")
        
        let signInVc = SignInViewController(nibName: "SignInViewController", bundle: nil)
        signInVc.modalPresentationStyle = .overFullScreen
        signInVc.modalPresentationCapturesStatusBarAppearance = true
        
        signInVc.signInCompletionHandler =  { success in
            AnalyticsHandler.shared.trackEvent(of: .event, name: "login", additionalInfo: ["sign_up_method" : "email"])
            AnalyticsHandler.shared.setUserId()
            completion()
        }
        let navController = UINavigationController(rootViewController: signInVc)
        
        self.present(navController, animated: true, completion: nil)
        
        /*
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = true
            //config.addSignInButtonView(class: AWSFacebookSignInButton.self)
            config.canCancel = true
            config.logoImage = UIImage(named: "logoWhite")
            config.backgroundColor = UIColor(hex: "3476ff")
            
            AWSAuthUIViewController.presentViewController(with: self.navigationController!,
                                                          configuration: config,
                                                          completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                                            if error != nil {
                                                                print("Error occurred: \(String(describing: error))")
                                                            } else {
                                                                AnalyticsHandler.shared.trackEvent(of: .event, name: "login", additionalInfo: ["sign_up_method" : provider.identityProviderName])
                                                                AnalyticsHandler.shared.setUserId()
                                                                completion()
                                                            }
            })
        }
 */
    }
    
    func checkForConnectivityAndPerform(completion: @escaping (() -> Void)){
        let reachabilityManager = NetworkReachabilityManager.init()
        
        if (reachabilityManager?.isReachable)!{
            completion()
        }
        else{
            let alertActionRetry = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (action) -> Void in
                self.checkForConnectivityAndPerform(completion: completion)
            }
            Utilities.showAlertMessage("NetworkError", message: "Please check your internet connection and try again.", actions: [alertActionRetry])
        }
    }
    
    func presentPlayer(meditation: Meditation, category: Category) {
        let playerVC = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        playerVC.hidesBottomBarWhenPushed = true
        playerVC.meditation = meditation
        playerVC.category = category
        playerVC.modalPresentationStyle = .overFullScreen
        
        self.present(playerVC, animated: true, completion: nil)
    }

    func showSubscriptions() {
        let subscriptionVC = SubscriptionsViewController(nibName: "SubscriptionsViewController", bundle: nil)
        subscriptionVC.hidesBottomBarWhenPushed = true
        subscriptionVC.modalPresentationStyle = .overFullScreen
        
        self.present(subscriptionVC, animated: true, completion: nil)
    }
    
    func playMeditionIfAllowed(_ meditation: Meditation, category: Category) {
        //TODO: Show activity indicator, if needed
        // Check if purchased
        AwashUser.shared.isUserAllowedAccess(meditation: meditation) { allowed in
            if allowed {
                self.presentPlayer(meditation: meditation, category: category)
            } else {
                self.showSubscriptions()
                //TODO: Show buy and when user taps on buy, show login
                
                
            }
        }
    }
    
    func buyProduct(productId: String) {
        if (!AwashUser.shared.isLoggedIn()) {
            self.goToLogin() {
                let store:IAPHandler = IAPHandler.shared
                store.requestProducts(productIdentifiers: [productId]) {success, products in
                    if (success && products != nil && (products!.count > 0)){
                        store.buyProduct(products![0])
                    }
                }
            }
            
        } else {
            let store:IAPHandler = IAPHandler.shared
            store.requestProducts(productIdentifiers: [productId]) {success, products in
                if (success && products != nil && (products!.count > 0)){
                    store.buyProduct(products![0])
                }
            }
        }
    }
    
    func fetchUserPurchases(completion: @escaping (Bool) -> Void){
        checkForConnectivityAndPerform() {
            let getPurchasesUseCase = GetPurchasesUseCase()
            getPurchasesUseCase.performAction(completion: { (success, purchasesCollection) in
                if success {
                    AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_PURCHASES_SUCCESS", additionalInfo: ["purchases": String( describing: purchasesCollection!.count)])
                    
                    let store:IAPHandler = IAPHandler.shared
                    store.updatePurchasedProducts(products: (purchasesCollection?.purchases)!)
                    completion(true)
                } else {
                    AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_PURCHASES_FAILED", additionalInfo: [:])
                    completion(false)
                }
            })
        }
    }
    
    @IBAction func shareTapped(_ sender: UIView) {
        
        let textToShare = """
Stay Mindful. Stay Positive. And Stay Progressive. Awash Mindfulness: A Different Kind of Mindfulness
        Check out the app
"""
        if let appStoreURL = RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.appStoreURL).stringValue, let myAppURL = URL(string: appStoreURL) {
            let objectsToShare = [textToShare, myAppURL] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            activityVC.completionWithItemsHandler = { activity, success, items, error in
                
                if !success{
                    print("cancelled")
                    return
                }
                
                AnalyticsHandler.shared.trackEvent(of: .event, name: "share", additionalInfo: ["content_type": (activity?.rawValue ?? ""), "item_id": appStoreURL])
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
