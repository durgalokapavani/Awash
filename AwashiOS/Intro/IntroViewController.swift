//
//  IntroViewController.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/14/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

class IntroViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var introCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var category:Category?
    
    var meditations:[Meditation] = []
    var goal:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchMeditations()
        
        introCollectionView.register(UINib(nibName: String(describing: WelcomeCollectionViewCell.welcomeCollectionViewCellReuseIdentifier), bundle: nil), forCellWithReuseIdentifier: WelcomeCollectionViewCell.welcomeCollectionViewCellReuseIdentifier)
//        introCollectionView.register(UINib(nibName: String(describing: GoalCollectionViewCell.goalCollectionViewCellReuseIdentifier), bundle: nil), forCellWithReuseIdentifier: GoalCollectionViewCell.goalCollectionViewCellReuseIdentifier)
        
        self.introCollectionView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
       
        if AwashUser.shared.isLoggedIn() {
            self.fetchGoal()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Fetch Metidations
    fileprivate func fetchMeditations() {
        let getMeditationsUseCase = GetMeditationsUseCase()
        getMeditationsUseCase.delegate = self
        if let categoryObj = category {
            getMeditationsUseCase.categoryName = categoryObj.name
            
        }
        
        getMeditationsUseCase.performAction()
        self.activityIndicator.startAnimating()
    }
    
    private func fetchGoal(){
        checkForConnectivityAndPerform {
            let getGoalsUseCase = GetGoalUseCase()
            getGoalsUseCase.performAction { (success, goal) in
                if success && goal != nil {
                    self.goal = goal?.goal?.capitalizingFirstLetter() ?? ""
                    DispatchQueue.main.async {
                        self.introCollectionView.reloadData()
                    }
                }
                
            }
        }
    }
    
    private func postGoal(goal: String){
        self.checkForConnectivityAndPerform {
            if !self.goal.isEmpty {
                let putGoalUseCase = PutGoalUseCase(goal: goal)
                putGoalUseCase.performAction { (success) in
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.GOAL_UPDATED, additionalInfo: ["goal": goal])
                }
            } else {
                let goalsUseCase = PostGoalUseCase(goal: goal)
                goalsUseCase.performAction { (success) in
                    AnalyticsHandler.shared.trackEvent(of: .event, name: Constants.Analytics.GOAL_ADDED, additionalInfo: ["goal": goal])
                }
            }
            
        }
        
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let userInfo = notification.userInfo!
            let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            introCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 40, right: 0)
            
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        
        let userInfo = notification.userInfo!
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        self.introCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.meditations.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WelcomeCollectionViewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: WelcomeCollectionViewCell.welcomeCollectionViewCellReuseIdentifier, for: indexPath) as! WelcomeCollectionViewCell
        
        cell.listenButtonHandler = {
            self.presentPlayer(meditation: self.meditations[0], category: self.category!)
        }
        
        return cell
        
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.size.width - 40, height: collectionView.bounds.size.height - 64)

    }
    
    
}

// MARK: GetMeditationsUseCaseDelegate
extension IntroViewController: GetMeditationsUseCaseDelegate {
    func getMeditationsSuccess(_ meditationsCollections: MeditationsCollection) {
        self.meditations = meditationsCollections.meditations
        
        DispatchQueue.main.async {
            self.introCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    func getMeditationsFailure(_ error: (title: String, message: String), backendError:BackendError?) {
        self.activityIndicator.stopAnimating()
    }
    
}
