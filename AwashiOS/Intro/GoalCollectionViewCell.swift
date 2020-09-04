//
//  GoalCollectionViewCell.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/14/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class GoalCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var headerText: UILabel!
    
    static let goalCollectionViewCellReuseIdentifier = "GoalCollectionViewCell"
    let placeHolderColor = UIColor(hex: "3476FF").withAlphaComponent(0.6)
    let regularTextColor = UIColor(hex: "002D9C")
    
    var postGoalHandler: ((_ goal: String) -> ())?
    
    
    var goal: String? {
        didSet {
            textView.text = goal
            textView.textColor = regularTextColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
        textView.text = "Set a goal"
        textView.textColor = placeHolderColor
        
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        headerText.text = "You came here for a reason\n\n What are you looking to change about your current mindfulness state?\n\n You owe yourself your best foot forward and we are here to help.\n\n Write a short but meaningful goal for youself which you will be able to track the progress toward. Get ready to Awash yourself in a new you."
        
    }

    //MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHolderColor {
            textView.text = nil
            textView.textColor = regularTextColor
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            guard let text = textView.text, !text.isEmpty else {
                return true
            }
            postGoalHandler?(text)
            return false
        }
        return true
    }
    
}

