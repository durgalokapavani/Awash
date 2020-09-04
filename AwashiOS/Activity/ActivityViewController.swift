//
//  ActivityViewController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import FSCalendar
import SwiftChart

struct Metrics {
    var plays = 0
    var minutes = 0
    var streaks = 0
    var activityDates = Set<Date>()
    var mostListened = Dictionary<String, Int>()
}

class ActivityViewController: BaseViewController {

    @IBOutlet weak var calendarView:FSCalendar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var minutes: SpacingLabel!
    @IBOutlet weak var streaks: SpacingLabel!
    @IBOutlet weak var plays: SpacingLabel!
//    @IBOutlet weak var noGoalView: RoundUIView!
//    @IBOutlet weak var yourGoalView: RoundUIView!
//    @IBOutlet weak var goalProgressView: UIView!
//    @IBOutlet weak var goalRatingsView: UIView!
//    @IBOutlet weak var setGoalButton: UIButton!
    @IBOutlet weak var mostListnedStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var goalLabel: UILabel!
    
    //Most Listened
    @IBOutlet weak var most1View: UIView!
    @IBOutlet weak var most1Name: UILabel!
    @IBOutlet weak var most1Separator: UIView!
    @IBOutlet weak var most1Count: UILabel!
    
    @IBOutlet weak var most2View: UIView!
    @IBOutlet weak var most2Name: UILabel!
    @IBOutlet weak var most2Separator: UIView!
    @IBOutlet weak var most2Count: UILabel!
    
    @IBOutlet weak var most3View: UIView!
    @IBOutlet weak var most3Name: UILabel!
    @IBOutlet weak var most3Separator: UIView!
    @IBOutlet weak var most3Count: UILabel!
    
    @IBOutlet weak var most4View: UIView!
    @IBOutlet weak var most4Name: UILabel!
    @IBOutlet weak var most4Separator: UIView!
    @IBOutlet weak var most4Count: UILabel!
    
    @IBOutlet weak var most5View: UIView!
    @IBOutlet weak var most5Name: UILabel!
    @IBOutlet weak var most5Separator: UIView!
    @IBOutlet weak var most5Count: UILabel!
    
//    @IBOutlet weak var progressView: UIProgressView!
//    @IBOutlet weak var imageGroupView: UIView!
//
//    //MARK: Chart related
//    @IBOutlet weak var chart: Chart!
//    @IBOutlet weak var imageLeadingMarginConstraint: NSLayoutConstraint!
//    @IBOutlet weak var image: UIImageView!
//    fileprivate var imageLeadingMarginInitialConstant: CGFloat!
    
    var activities = [Activity]()
    var exclusiveStartKey = ""
    var ratingsExclusiveStartKey = ""
    var ratings = [Rating]()
    var metricStats = Metrics()
    var goal:Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.calendarHeaderView.backgroundColor = UIColor(hex: "F3F6FF")
        calendarView.calendarHeaderView.layer.cornerRadius = 10
        
        calendarView.appearance.titleFont = UIFont(name: "Rubik-Regular", size: 13.0)
        calendarView.appearance.weekdayFont = UIFont(name: "Rubik-Medium", size: 13.0)
        calendarView.appearance.headerTitleFont = UIFont(name: "Rubik-Medium", size: 15.0)
        calendarView.appearance.eventOffset = CGPoint(x: 10, y: -26)
//        self.noGoalView.isHidden = false
//        self.goalProgressView.isHidden = true
//        self.goalRatingsView.isHidden = true
//
//        setGoalButton.layer.cornerRadius = 18
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ActivityViewController.goalSet), name: NSNotification.Name(rawValue: Constants.Notifications.GoalSet), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ActivityViewController.goalDeleted), name: NSNotification.Name(rawValue: Constants.Notifications.GoalDeleted), object: nil)
        
//        imageLeadingMarginInitialConstant = imageLeadingMarginConstraint.constant
//        self.image.isHidden = true
    }
    
    /*
    private func setSimleyBasedOnRating(rating: Int){
        
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.9,
                       options: UIViewAnimationOptions(),
                       animations: {
                        self.activityIndicator.stopAnimating()
                        
                        self.imageGroupView.subviews.forEach { (view) in
                            view.removeFromSuperview()
                        }
                        
                        let smiley = UIImageView(image: self.getImageByRating(rating: rating))
                        smiley.frame = CGRect(x: 0, y: 0, width: 37, height: 45)
                        
                        self.imageGroupView.addSubview(smiley)
                        let eachSmileyWidth = self.imageGroupView.bounds.width/5
                        smiley.center = CGPoint(x: eachSmileyWidth * CGFloat(rating), y: self.imageGroupView.frame.minY - 4)
                        
                        self.progressView.setProgress(Float(Float(rating)/5), animated: true)
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil)
        
        
        
        
    }
    
    @objc func goalSet(_ notification: NSNotification)  {
        self.ratings.removeAll()
        ratingsExclusiveStartKey = ""
        self.fetchGoal()
    }
    
    @objc func goalDeleted(_ notification: NSNotification)  {
        self.goal = nil
        self.ratings.removeAll()
        ratingsExclusiveStartKey = ""
        DispatchQueue.main.async {
            self.noGoalView.isHidden = false
            self.goalProgressView.isHidden = true
        }
        
    }*/
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.activities.removeAll()
        self.ratings.removeAll()
        exclusiveStartKey = ""
        ratingsExclusiveStartKey = ""
        metricStats = Metrics()
        self.fetchActvities()
//        if AwashUser.shared.isLoggedIn() {
//            self.fetchGoal()
//        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.setSimleyBasedOnRating(rating: 1)
    }

    //MARK: Chart
    private func getRatingsForChart() -> Array<Dictionary<String, Any>> {
        
        // Parse data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let values = self.ratings.reversed().map { rating -> Dictionary<String, Any> in
            let date = Utilities.utcToLocalDate(date: rating.activityDate!)
            let close = (rating.rating as NSNumber).doubleValue
            return ["date": date, "rating": close]
        }
        
        return values
        
    }
    
    /*
    func initializeChart() {
        chart.delegate = self
        chart.series.removeAll()
        
        // Initialize data series and labels
        let stockValues = self.getRatingsForChart()
        
        var serieData: [Double] = []
        var labels: [Double] = []
        var labelsAsString: Array<String> = []
        
        // Date formatter to retrieve the month names
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        for (i, value) in stockValues.enumerated() {
            
            serieData.append(value["rating"] as! Double)
            
            // Use only one label for each month
            let month = Int(dateFormatter.string(from: value["date"] as! Date))!
            let monthAsString:String = dateFormatter.monthSymbols[month - 1]
            if (labels.count == 0 || labelsAsString.last != monthAsString) {
                labels.append(Double(i))
                labelsAsString.append(monthAsString)
            }
        }
        
        let series = ChartSeries(serieData)
        series.area = true
        series.color = UIColor(hex: "FF0044")
        
        // Configure chart layout
        
        chart.lineWidth = 0.5
        //chart.highlightLineColor = UIColor(hex: "FF0044")
        chart.labelFont = UIFont(name: "Rubik-Medium", size: 11.0)
        chart.xLabels = labels
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        chart.xLabelsTextAlignment = .center
        chart.labelColor = UIColor(hex: "FF0044")
        //chart.yLabels = []
        chart.yLabelsOnRightSide = true
        chart.showYLabelsAndGrid = false
        
        chart.add(series)
    }
    
    private func fetchGoal(){
        checkForConnectivityAndPerform {
            let getGoalsUseCase = GetGoalUseCase()
            getGoalsUseCase.performAction { (success, goal) in
                if success && goal == nil{
                    self.noGoalView.isHidden = false
                    self.goalProgressView.isHidden = true
                    
                } else if success && goal != nil {
                    self.goalLabel.text = " \"\(goal?.goal?.capitalizingFirstLetter() ?? "")\""
                    self.goalProgressView.isHidden = false
                    self.noGoalView.isHidden = true
                    self.goal = goal
                    //Fetch Ratings:
                    self.fetchRatings()
                    
                }
                
            }
        }
    }
    
    private func fetchRatings() {
        checkForConnectivityAndPerform() {
            AwashUser.shared.getUserId { (userID) in
                let getRatingsUseCase = GetRatingsUseCase()
                getRatingsUseCase.params["startDate"] = self.goal?.createdAt as AnyObject
                getRatingsUseCase.delegate = self
                if !self.ratingsExclusiveStartKey.isEmpty {
                    getRatingsUseCase.ExclusiveStartKey = self.ratingsExclusiveStartKey
                }
                getRatingsUseCase.performAction()
            }
        }
    }
 */
    
    private func fetchActvities() {
        checkForConnectivityAndPerform() {
            AwashUser.shared.getUserId { (userID) in
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                let activitiesUseCase = GetActivitiesUseCase(userId: userID)
                activitiesUseCase.delegate = self
                if !self.exclusiveStartKey.isEmpty {
                    activitiesUseCase.ExclusiveStartKey = self.exclusiveStartKey
                }
                activitiesUseCase.performAction()
            }
        }
    }
    
    private func updateUI(metrics: Metrics) {
        self.metricStats = metrics
        DispatchQueue.main.async {
            self.minutes.text = "\(metrics.minutes)"
            self.streaks.text = "\(metrics.streaks)"
            self.plays.text = "\(metrics.plays)"
            self.calendarView.reloadData()
            
            self.most1View.isHidden = true
            self.most2View.isHidden = true
            self.most3View.isHidden = true
            self.most4View.isHidden = true
            self.most5View.isHidden = true
            
            var index = 0
            let sortedTupleArray = Array(self.metricStats.mostListened).sorted {$0.1 > $1.1}
            let top5Listens = sortedTupleArray.prefix(5)
            for (k,v) in top5Listens {
                if index == 5 {return}
                switch (index){
                case 0:
                    self.most1View.isHidden = false
                    self.most1Name.text = k
                    self.most1Count.text = "\(v)"
                    self.most1Count.layer.cornerRadius = 15
                    self.most1Count.layer.masksToBounds = true
                    if top5Listens.count - 1 == index {
                        self.most1Separator .isHidden = true
                    }
                case 1:
                    self.most2View.isHidden = false
                    self.most2Name.text = k
                    self.most2Count.text = "\(v)"
                    self.most2Count.layer.masksToBounds = true
                    self.most2Count.layer.cornerRadius = 15
                    if top5Listens.count - 1 == index {
                        self.most2Separator .isHidden = true
                    }
                case 2:
                    self.most3View.isHidden = false
                    self.most3Name.text = k
                    self.most3Count.text = "\(v)"
                    self.most3Count.layer.masksToBounds = true
                    self.most3Count.layer.cornerRadius = 15
                    if top5Listens.count - 1 == index {
                        self.most3Separator .isHidden = true
                    }
                case 3:
                    self.most4View.isHidden = false
                    self.most4Name.text = k
                    self.most4Count.text = "\(v)"
                    self.most4Count.layer.masksToBounds = true
                    self.most4Count.layer.cornerRadius = 15
                    if top5Listens.count - 1 == index {
                        self.most4Separator .isHidden = true
                    }
                case 4:
                    self.most5View.isHidden = false
                    self.most5Name.text = k
                    self.most5Count.text = "\(v)"
                    self.most5Count.layer.masksToBounds = true
                    self.most5Count.layer.cornerRadius = 15
                    if top5Listens.count - 1 == index {
                        self.most5Separator .isHidden = true
                    }
                    
                default:
                   break
                }
                index += 1
            }
            
            
        }
    }
    private func calculateMetrics() {
        var metrics = Metrics()
        metrics.plays = self.activities.count
        
        let sortedActivities = activities.sorted(by: { $0.activityDateWithNoTimestamp > $1.activityDateWithNoTimestamp })
        
        for activity in sortedActivities {
            //playTime Calculation
            if let playTime = activity.playTime {
                metrics.minutes += playTime / 60
            }
            
            //Activity Dates
            metrics.activityDates.insert( activity.activityDateWithNoTimestamp)
            
            //Most Listened
            if let count = metrics.mostListened[activity.meditationName!] {
                metrics.mostListened[activity.meditationName!] = count + 1
            } else {
                metrics.mostListened[activity.meditationName!] = 1
            }
            
        }
        
        //Streaks Calculation
         metrics.streaks = getStreakCount(activityDates: metrics.activityDates)
        self.activityIndicator.stopAnimating()
        updateUI(metrics: metrics)
        
    }
    
    private func getStreakCount(activityDates: Set<Date>) -> Int {
        if activityDates.isEmpty {return 0}
        
        
        var streakCount = 0
        let cal = Calendar(identifier: .gregorian)
        let sortedActivityDates = activityDates.sorted(by: { $0 > $1 })
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))!
        let yesterDayorder = NSCalendar.current.compare(sortedActivityDates.first! , to: yesterday, toGranularity: .day)
        let todayDayorder = NSCalendar.current.compare(sortedActivityDates.first! , to: cal.startOfDay(for: Date()), toGranularity: .day)

        //If first day is today or yesterday then there is a start of streak
        if  todayDayorder == .orderedSame || yesterDayorder == .orderedSame {
            streakCount = 1
            for (date, nextDate) in zip(sortedActivityDates, sortedActivityDates.dropFirst()) {
                let num = Calendar.current.dateComponents([.day], from: date, to: cal.startOfDay(for: Date())).day ?? 0
                let nextNum = Calendar.current.dateComponents([.day], from: nextDate, to: cal.startOfDay(for: Date())).day ?? 0
                if (nextNum - num) != 1 {
                    return streakCount
                } else {
                    streakCount += 1
                }
            }
            
        }
        
        return streakCount
    }
    
    //MARK: Button actions
    @IBAction func setGoalTapped(_ sender: Any) {
        if AwashUser.shared.isLoggedIn() {
            let goalVC = GoalViewController(nibName: "GoalViewController", bundle: nil)
            goalVC.modalPresentationStyle = .overFullScreen
            self.present(goalVC, animated: true, completion: nil)
        } else {
            goToLogin {
                let goalVC = GoalViewController(nibName: "GoalViewController", bundle: nil)
                goalVC.modalPresentationStyle = .overFullScreen
                self.present(goalVC, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func editGoalTapped(_ sender: Any) {
        if AwashUser.shared.isLoggedIn() {
            let goalVC = GoalViewController(nibName: "GoalViewController", bundle: nil)
            goalVC.modalPresentationStyle = .overFullScreen
            goalVC.goal = self.goal
            self.present(goalVC, animated: true, completion: nil)
        }
        
    }
    

}

// MARK: GetActivitiesUseCaseDelegate methods
extension ActivityViewController: GetActivitiesUseCaseDelegate {
    func getActivitiesSuccess(_ activitiesCollection: ActivitiesCollection) {
        if !self.activities.isEmpty {
            self.activities.append(contentsOf: activitiesCollection.activities)
        } else {
            self.activities = activitiesCollection.activities
        }
        
        self.exclusiveStartKey = activitiesCollection.LastEvaluatedKey
        if !self.exclusiveStartKey.isEmpty {
            fetchActvities()
            return
        }
        
        self.calculateMetrics()
    }
    
    func getactivitiesFailure(_ error: (title: String, message: String), backendError: BackendError?) {
        self.activityIndicator.stopAnimating()
    }
    
}

// MARK: GetRatingsUseCaseDelegate methods
/*
extension ActivityViewController: GetRatingsUseCaseDelegate {
    func getRatingsSuccess(_ ratingsCollection: RatingsCollection) {
        guard ratingsCollection.ratings.count > 0 else {
            self.goalRatingsView.isHidden = true
            return
            
        }
        
        if !self.ratings.isEmpty {
            self.ratings.append(contentsOf: ratingsCollection.ratings)
        } else {
            self.ratings = ratingsCollection.ratings
        }
        
        self.ratingsExclusiveStartKey = ratingsCollection.LastEvaluatedKey
        if !self.ratingsExclusiveStartKey.isEmpty {
            self.fetchRatings()
            return
        }
        
        self.goalRatingsView.isHidden = false
        DispatchQueue.main.async {
            self.initializeChart()
        }
        
        // Update Smiley progress
        if ratings.count > 0 {
            let sumArray = ratings.reduce(0) {$0 + $1.rating}
            let avgArrayValue = ceil(Double(sumArray / ratings.count))
            
            DispatchQueue.main.async {
                self.setSimleyBasedOnRating(rating: Int(avgArrayValue))
            }
            
        }
        
    }
    
    func getRatingsFailure(_ error: (title: String, message: String), backendError: BackendError?) {
        
    }
    
}
*/

// MARK: FSCalendarDelegate methods
extension ActivityViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance  {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let cal = Calendar(identifier: .gregorian)
        if self.metricStats.activityDates.contains(cal.startOfDay(for: date)) {
            return 1
        }
        
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if NSCalendar.current.compare(Date(), to: date, toGranularity: .day) == .orderedSame {
            return UIColor.white
        }
        
        let cal = Calendar(identifier: .gregorian)
        if self.metricStats.activityDates.contains(cal.startOfDay(for: date)) {
            return UIColor(hex: "3476FF").withAlphaComponent(1.0)
        } else if NSCalendar.current.compare(Date(), to: date, toGranularity: .month) == .orderedSame {
            return UIColor(hex: "3476FF").withAlphaComponent(0.6)
        }
        return UIColor(hex: "3476FF").withAlphaComponent(0.23)
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let ninetyDays = Calendar.current.date(byAdding: .day, value: -90, to: Date())
        
        return ninetyDays ?? Date()
    }

}

//MARK: ChartDelegate
 /*
extension ActivityViewController: ChartDelegate {
    // Chart delegate
    private func getImageByRating(rating: Int)  -> UIImage? {
        switch rating {
        case 1:
            return #imageLiteral(resourceName: "sadRed")
        case 2:
            return #imageLiteral(resourceName: "sadNuetralRed")
        case 3:
            return #imageLiteral(resourceName: "nuetralRed")
        case 4:
            return #imageLiteral(resourceName: "nuetralHappyRed")
        case 5:
            return #imageLiteral(resourceName: "happyRed")
        default:
            return #imageLiteral(resourceName: "nuetralWhite")
        }
    }
    
   
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            let rating = Int(value)
            self.image.isHidden = false
            self.image.image = getImageByRating(rating: rating)
            
            // Align the image to the touch left position, centered
            var constant = imageLeadingMarginInitialConstant + left - (image.frame.width / 2)
            
            // Avoid placing the image on the left of the chart
            if constant < 0 {
                constant = 0
                
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width + (self.image.frame.width / 2)
            if constant > rightMargin {
                constant = rightMargin
            }
            
            imageLeadingMarginConstraint.constant = constant
            
        }
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.image.isHidden = true
        imageLeadingMarginConstraint.constant = imageLeadingMarginInitialConstant
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
 
}
*/
