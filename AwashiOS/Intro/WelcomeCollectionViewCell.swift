//
//  WelcomeCollectionViewCell.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/14/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class WelcomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var listen: UIButton!
    
    @IBOutlet weak var welcomeView: UIView!
    var listenButtonHandler: (() -> ())?
    
    static let welcomeCollectionViewCellReuseIdentifier = "WelcomeCollectionViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.listen.layer.cornerRadius = 20
        self.listen.layer.masksToBounds = true
        
        self.welcomeView.layer.cornerRadius = 15
        self.welcomeView.layer.borderWidth = 1.0
        self.welcomeView.layer.borderColor = UIColor.clear.cgColor
        self.welcomeView.layer.masksToBounds = true
    }
    
    @IBAction func listenTapped(_ sender: Any) {
        listenButtonHandler?()
    }
    

}
