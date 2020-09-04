//
//  CategoryHeaderCollectionView.swift
//  AwashiOS
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import StoreKit

class CategoryHeaderCollectionView: UICollectionReusableView {

    @IBOutlet weak var title: UILabel!
    //@IBOutlet weak var price: UILabel!
    @IBOutlet weak var details: UILabel!
    //@IBOutlet weak var subscribe: UILabel!
    @IBOutlet weak var purchaseViewHeight: NSLayoutConstraint!
    
    static let categoryHeaderCellReuseIdentifier = "CategoryHeaderCollectionView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // self.purchased.isHidden = true
        self.backgroundColor = .white
        self.title.textColor = UIColor(hex: Constants.Colors.darkBlue)
        self.details.textColor = UIColor(hex: Constants.Colors.darkBlue)
        let tapOnLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryHeaderCollectionView.subscribe(_:)))
        tapOnLabel.numberOfTapsRequired = 1
        tapOnLabel.numberOfTouchesRequired = 1
        tapOnLabel.cancelsTouchesInView = false
        //self.subscribe.isUserInteractionEnabled = true
        //self.subscribe.addGestureRecognizer(tapOnLabel)
    }
    
    @objc func subscribe(_ sender: Any) {
        let subscriptionVC = SubscriptionsViewController(nibName: "SubscriptionsViewController", bundle: nil)
        subscriptionVC.hidesBottomBarWhenPushed = true
        subscriptionVC.modalPresentationStyle = .overFullScreen
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(subscriptionVC, animated: true, completion: nil)
        }
    }
    
    func updateCellWithCategory(category: Category) {
        self.title.text = category.name
        self.details.text = category.details
        if IAPHandler.canMakePayments() && IAPHandler.shared.availableProducts[IAPHandler.productIdMonthlySubscription] != nil{
            let product = IAPHandler.shared.availableProducts[IAPHandler.productIdMonthlySubscription]
            Utilities.priceFormatter.locale = product?.priceLocale
            //self.price.text = "\(Utilities.priceFormatter.string(from: (product?.price)!) ?? "") / mo"
        }
        
        AwashUser.shared.isSubscribed { active in
            if active {
                DispatchQueue.main.async {
                    self.purchaseViewHeight.constant = 0
                }
            }
        }
    }
    
    /*
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            self.title.text = product.localizedTitle
            self.details.text = product.localizedDescription
            
            if IAPHandler.shared.isProductPurchased(product.productIdentifier) {
                //self.buyButton.isHidden = true
                //self.purchased.isHidden = false
            } else if IAPHandler.canMakePayments() {
                Utilities.priceFormatter.locale = product.priceLocale
                //self.buyButton.setTitle("\(Utilities.priceFormatter.string(from: product.price) ?? "")", for: .normal)
            } else {
                //self.details.text = "Not available (you cannot make purchases)"
                //self.buyButton.isHidden = true
            }
            
            
            
        }
    }
 */
}
