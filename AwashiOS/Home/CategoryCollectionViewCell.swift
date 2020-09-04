//
//  CategoryCollectionViewCell.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let imageGradient = CAGradientLayer()
    
    static let categoryCellReuseIdentifier = "CategoryCollectionViewCell"
    static let cellHeight: CGFloat = 370.0
    static let cellWidth: CGFloat = 320
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    private func roundCornersAndDropShadow() {
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width:0,height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false;
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        

        
    
    }
    
    var category : Category? {
        didSet {
            guard let category = category else { return }
            if category.isCourse {
                self.imageView.image = UIImage(named: Utilities.getDayOfWeek())
            } else {
                self.imageView.image = UIImage(named: category.type!)
            }
            
            self.title.text = category.name
            self.details.text = category.details
            //self.applyGradient()
            
            imageGradient.removeFromSuperlayer() // Every time view is scrolled, we need to remove previous and new one
            imageView.addGradientLayer(frame: self.imageView.frame, colors: Utilities.gradientForImage(name: category.type!), gradient: imageGradient)
            self.roundCornersAndDropShadow()
            
        }
    }
    
    /*
    private func applyGradient(){
        let view = UIView(frame: imageView.frame)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = view.frame
        
        gradient.colors = [UIColor(hex: "5427cb").withAlphaComponent(0).cgColor, UIColor(hex: "5326ca").withAlphaComponent(0.58).cgColor, UIColor(hex: "5024c9").withAlphaComponent(1).cgColor]
        
        gradient.locations = [0.2, 0.5]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        imageView.addSubview(view)
        
        imageView.bringSubview(toFront: view)
    }
 */

}

extension UIImageView{
    func addGradientLayer(frame: CGRect, colors: [UIColor], gradient: CAGradientLayer){
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
    }
}
