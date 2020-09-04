//
//  SubscriptionsViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/24/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class SubscriptionsViewController: BaseViewController {

    @IBOutlet weak var monthly: UIView!
    @IBOutlet weak var yearly: UIView!
    @IBOutlet weak var subscribeMonthly: UIButton!
    @IBOutlet weak var subscribeAnually: UIButton!
    
    @IBOutlet weak var monthlyPrice: UILabel!
    @IBOutlet weak var annualPrice: UILabel!
    @IBOutlet weak var terms: UILabel!
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.present_offer, additionalInfo: ["item_id": "", "item_name" : "subscription", "item_category" : "subscription"])
        
        self.terms.text = "The subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can go to your iTunes Account settings to manage your subscription and turn off auto-renew. Your iTunes account will be charged when the purchase is confirmed. Any unused portion of a free trial period, if offered, will be forfeited on purchase of a subscription to that publication, where applicable"
        self.monthly.layer.cornerRadius = 15
        self.monthly.layer.masksToBounds = true
        self.yearly.layer.cornerRadius = 15
        self.yearly.layer.masksToBounds = true
        self.subscribeMonthly.layer.cornerRadius = 15
        self.subscribeMonthly.layer.masksToBounds = true
        self.subscribeAnually.layer.cornerRadius = 15
        self.subscribeAnually.layer.masksToBounds = true
        
        if IAPHandler.shared.availableProducts[IAPHandler.productIdMonthlySubscription] != nil{
            let product = IAPHandler.shared.availableProducts[IAPHandler.productIdMonthlySubscription]
            Utilities.priceFormatter.locale = product?.priceLocale
            self.monthlyPrice.text = "\(Utilities.priceFormatter.string(from: (product?.price)!) ?? "")\nper Month"
        }
        
        if IAPHandler.shared.availableProducts[IAPHandler.productIdAnnualSubscription] != nil{
            let product = IAPHandler.shared.availableProducts[IAPHandler.productIdAnnualSubscription]
            Utilities.priceFormatter.locale = product?.priceLocale
            self.annualPrice.text = "\(Utilities.priceFormatter.string(from: (product?.price)!) ?? "")\nper Year"
            
//            let annualPriceMonthy = (product?.price.doubleValue)! / 12.0
//            let priceString = annualPriceMonthy.description
//            let index3 = priceString.index(priceString.startIndex, offsetBy: 3)
//            self.annualPrice.text = "$\(priceString[...index3] ) / mo"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func monthlyTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            //self.buyProduct(productId: IAPHandler.productIdMonthlySubscription)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.BuyProductNotification), object: nil, userInfo: ["productId" : IAPHandler.productIdMonthlySubscription])
        }
        
    }
    
    
    @IBAction func anuallyTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.BuyProductNotification), object: nil, userInfo: ["productId" : IAPHandler.productIdAnnualSubscription])
        }
    }
    
    @IBAction func dismiss() {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openTerms() {
        self.open(scheme: "https://www.awashapp.com/terms-of-use/")
    }
    
    @IBAction func openPrivacyPolicy() {
        self.open(scheme: "https://www.awashapp.com/privacy-policy/")
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) { // For ios 10 and greater
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else { // for below ios 10.
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
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
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }

}
