//
//  HomeFooterCollectionViewCell.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/22/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class HomeFooterCollectionViewCell: UICollectionReusableView {

    static let homeFooterCellReuseIdentifier = "HomeFooterCollectionViewCell"
    @IBOutlet weak var footerNotes: UILabel!
    
    var notes: String? {
        didSet {
            footerNotes.text = notes
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
