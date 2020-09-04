//
//  CourseViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/22/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class CourseViewController: BaseViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var sunday: UILabel!
    @IBOutlet weak var monday: UILabel!
    @IBOutlet weak var tuesday: UILabel!
    @IBOutlet weak var wednesday: UILabel!
    @IBOutlet weak var thursday: UILabel!
    @IBOutlet weak var friday: UILabel!
    @IBOutlet weak var saturday: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let imageGradient = CAGradientLayer()
    
    var category: Category?
    var meditations:[Meditation] = []
    var dayOfWeekMeditation:Meditation?
    
    let bubble = UIImageView(image: UIImage(named: "bubble"))
    
    @IBAction func play(_ sender: Any) {
        self.playImage.isHidden = true
        if let medidataion = dayOfWeekMeditation {
            self.playMeditionIfAllowed(medidataion, category: self.category!)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapOnView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CourseViewController.play))
        tapOnView.numberOfTapsRequired = 1
        tapOnView.numberOfTouchesRequired = 1
        tapOnView.cancelsTouchesInView = false
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapOnView)
        
        weekLabel.text = ""
        self.fetchMeditation()

        NotificationCenter.default.addObserver(self, selector: #selector(CategoryDetailsViewController.buyProductNotificatonHandler), name: NSNotification.Name(rawValue: Constants.Notifications.BuyProductNotification), object: nil)
    }
    
    @objc func buyProductNotificatonHandler(_ notification: NSNotification)  {
        if let productId = notification.userInfo?["productId"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.buyProduct(productId: productId)
            }
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Private
    private func fetchMeditation() {
        let getMeditationsUseCase = GetMeditationsUseCase()
        getMeditationsUseCase.delegate = self
        if let categoryObj = category {
            getMeditationsUseCase.categoryName = categoryObj.type
            getMeditationsUseCase.performAction()
            self.activityIndicator.startAnimating()
        }
    }
    
    private func setLabelGradient() {
        let day = Utilities.getDayOfWeek()
        let dayColor =  Utilities.gradientByDay(day: Utilities.getDayOfWeek())[2]
        
        bubble.frame = CGRect(x: 0, y: 0, width: 36, height: 42)
        
        var dayLabel = self.sunday!
        switch day {
        case "Sunday":
            dayLabel = self.sunday
        case "Monday":
            dayLabel = self.monday
        case "Tuesday":
            dayLabel = self.tuesday
        case "Wednesday":
            dayLabel = self.wednesday
        case "Thursday":
            dayLabel = self.thursday
        case "Friday":
            dayLabel = self.friday
        case "Saturday":
            dayLabel = self.saturday
        
        default:
            dayLabel = self.sunday
        }
        
        dayLabel.alpha = 1.0
        self.bubble.removeFromSuperview()
        self.weekView.addSubview(bubble)
        self.weekView.bringSubview(toFront: dayLabel)
        bubble.center = CGPoint(x:dayLabel.center.x, y: dayLabel.center.y + 4)
        let xpoint = dayLabel.center.x - 22
        let percentage = self.progressView.frame.width / xpoint
        progressView.progress = Float(1 / percentage)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        dayLabel.textColor = dayColor
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageGradient.removeFromSuperlayer()
        backgroundImageView.addGradientLayer(frame: self.backgroundImageView.frame, colors: Utilities.gradientForImage(name: category!.type!), gradient: imageGradient)
        
        if self.category != nil {
            
            self.backgroundImageView.image = UIImage(named: Utilities.getDayOfWeek())
//            let percentages: [String: Float] = ["Sunday" : 0, "Monday" : 1/6, "Tuesday" : 2/6, "Wednesday" : 3/6, "Thursday" : 4/6, "Friday" : 5/6, "Saturday" : 1]
//            progressView.progress = percentages[Utilities.getDayOfWeek()]!
            
            self.setLabelGradient()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


// MARK: GetMeditationsUseCaseDelegate
extension CourseViewController: GetMeditationsUseCaseDelegate {
    func getMeditationsSuccess(_ meditationsCollections: MeditationsCollection) {
        self.meditations = meditationsCollections.meditations
        
        self.meditations = meditationsCollections.meditations
        let dayOfWeek = Utilities.getDayOfWeek()
        
        if let dayMeditation = meditations.first(where: { $0.meditationName!.lowercased().contains(dayOfWeek.lowercased()) }) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.courseTitle.text = dayMeditation.meditationName
                self.weekLabel.text = dayMeditation.meditationDescription
                self.dayOfWeekMeditation = dayMeditation
            }
        }
        
        self.activityIndicator.stopAnimating()
        self.playImage.isHidden = false
    }
    func getMeditationsFailure(_ error: (title: String, message: String), backendError:BackendError?) {
        self.activityIndicator.stopAnimating()
        self.playImage.isHidden = false
    }
    
}
