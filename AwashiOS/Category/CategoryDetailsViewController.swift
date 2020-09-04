//
//  CategoryDetailsViewController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import StoreKit
import AWSAuthCore
import AWSAuthUI

class CategoryDetailsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    private var _templateHeader : CategoryHeaderCollectionView!
    private var meditationPlayed = false
    //let imageGradient = CAGradientLayer()

    var category:Category?
    
    var meditations:[Meditation] = []
    var exclusiveStartKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.layer.cornerRadius = 12.0
        categoryCollectionView.register(UINib(nibName: String(describing: MeditationCollectionViewCell.meditationCellReuseIdentifier), bundle: nil), forCellWithReuseIdentifier: MeditationCollectionViewCell.meditationCellReuseIdentifier)
        
        let nib = UINib(nibName: String(describing: CategoryHeaderCollectionView.categoryHeaderCellReuseIdentifier), bundle: nil)
        categoryCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CategoryHeaderCollectionView.categoryHeaderCellReuseIdentifier)
        _templateHeader = nib.instantiate(withOwner: nil, options:nil)[0] as? CategoryHeaderCollectionView

        if let flowLayout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if #available(iOS 12, *) {
                flowLayout.estimatedItemSize = CGSize(width: 300,height: 250)
            } else {
                flowLayout.estimatedItemSize = CGSize(width: 1,height: 1)
            }
            
        }
        
        fetchMeditations()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryDetailsViewController.buyProductNotificatonHandler), name: NSNotification.Name(rawValue: Constants.Notifications.BuyProductNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryDetailsViewController.purchasedProductNotificatonHandler), name: NSNotification.Name(rawValue: IAPHandler.IAPHandlerPurchaseNotification), object: nil)

    }
    
    //MARK: Fetch Metidations
    fileprivate func fetchMeditations() {
        let getMeditationsUseCase = GetMeditationsUseCase()
        getMeditationsUseCase.delegate = self
        if let categoryObj = category {
            getMeditationsUseCase.categoryName = categoryObj.name
            self.backgroundImage.image = UIImage(named: categoryObj.type!)
            
        }
        if !exclusiveStartKey.isEmpty {
            getMeditationsUseCase.exclusiveStartKey = exclusiveStartKey
        }
        
        getMeditationsUseCase.performAction()
        self.activityIndicator.startAnimating()
    }
    
    @objc func buyProductNotificatonHandler(_ notification: NSNotification)  {
        if let productId = notification.userInfo?["productId"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.buyProduct(productId: productId)
            }
            
        }
    }
    
    @objc func purchasedProductNotificatonHandler(_ notification: NSNotification)  {
        DispatchQueue.main.async {
            self.categoryCollectionView.reloadData()
        }
    }
    
    deinit {
        if meditationPlayed {
            InAppRatingHandler.shared.showRatingForRule(rule: .meditationComplete)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*
        if let categoryObj = category {
            imageGradient.removeFromSuperlayer()
            backgroundImage.addGradientLayer(frame: self.backgroundImage.frame, colors: Utilities.gradientForImage(name: categoryObj.type!), gradient: imageGradient)
            
        }
         */
        
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
    

    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.meditations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MeditationCollectionViewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: MeditationCollectionViewCell.meditationCellReuseIdentifier, for: indexPath) as! MeditationCollectionViewCell
        cell.setMeditation(meditation: self.meditations[indexPath.row])
        if #available(iOS 12, *) {
            cell.widthConstraint.constant = collectionView.frame.size.width - (2 * 12)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader && indexPath.row == 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeaderCollectionView.categoryHeaderCellReuseIdentifier, for: indexPath) as! CategoryHeaderCollectionView
            
            if let categoryObj = self.category {
                headerView.updateCellWithCategory(category: categoryObj)
            }
            
            headerView.setNeedsUpdateConstraints()
            headerView.updateConstraintsIfNeeded()
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            return headerView
            
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if let categoryObj = self.category {
                _templateHeader.updateCellWithCategory(category: categoryObj)
            }
            
            _templateHeader.setNeedsUpdateConstraints();
            _templateHeader.updateConstraintsIfNeeded()
            
            _templateHeader.setNeedsLayout();
            _templateHeader.layoutIfNeeded();
            _templateHeader.bounds = CGRect(x: _templateHeader.bounds.minX, y: _templateHeader.bounds.minY, width: collectionView.bounds.width, height: _templateHeader.bounds.height)
            
            let computedSize = _templateHeader.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

            if #available(iOS 12, *) {
                return CGSize(width: collectionView.bounds.size.width, height: 350)
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: computedSize.height)
            }
            
        }
        return CGSize(width: 0, height: 0)
    }
    
    //MARK: Pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == meditations.count && !exclusiveStartKey.isEmpty {
            //print("pagination at index: \(indexPath.row)")
            fetchMeditations()
        }
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meditation = self.meditations[indexPath.row]
        meditationPlayed = true
        playMeditionIfAllowed(meditation, category: category!)
        
    }
    
}

// MARK: GetMeditationsUseCaseDelegate
extension CategoryDetailsViewController: GetMeditationsUseCaseDelegate {
    func getMeditationsSuccess(_ meditationsCollections: MeditationsCollection) {
        if !self.meditations.isEmpty {
            self.meditations.append(contentsOf: meditationsCollections.meditations)
        } else {
            self.meditations = meditationsCollections.meditations
        }
        
        self.exclusiveStartKey = meditationsCollections.LastEvaluatedKey
        
        DispatchQueue.main.async {
            self.categoryCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    func getMeditationsFailure(_ error: (title: String, message: String), backendError:BackendError?) {
        self.activityIndicator.stopAnimating()
    }
    
}


