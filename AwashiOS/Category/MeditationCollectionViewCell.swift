//
//  MeditationCollectionViewCell.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import AVFoundation

class MeditationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    static let meditationCellReuseIdentifier = "MeditationCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Code below is needed to make the self-sizing cell work when building for iOS 12 from Xcode 10.0:
        if #available(iOS 12, *) {
            let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
            let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
            let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
            let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        } else {
            let screenWidth = UIScreen.main.bounds.size.width
            widthConstraint.constant = screenWidth - (2 * 11)
        }
        
        
        
    }
    
    func setMeditation(meditation: Meditation) {
        self.name.text = meditation.meditationName
        self.details.text = meditation.meditationDescription
        //self.type.text = meditation.type
        if meditation.type.elementsEqual("free") {
            self.playImage.image = UIImage(named: "play")
        } else {
            self.playImage.image = UIImage(named: "lock")
        }
        
        AwashUser.shared.isUserAllowedAccess(meditation: meditation) { allowed in
            if allowed {
                DispatchQueue.main.async {
                    self.playImage.image = UIImage(named: "play")
                }
                
            }
        }
        
    }
    
}
