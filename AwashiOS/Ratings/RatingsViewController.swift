//
//  RatingsViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/23/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.applyGradient()
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func greatTapped(_ sender: Any) {
        
    }
    @IBAction func notGreatTapped(_ sender: Any) {
        
    }
    
    
    func applyGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "3476ff").cgColor,
                           UIColor(hex: "9234ff").cgColor]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.locations = [0.0, 0.7]
        let bounds = UIScreen.main.bounds
        gradient.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        self.view.layer.insertSublayer(gradient, at: 0)
    }

}
