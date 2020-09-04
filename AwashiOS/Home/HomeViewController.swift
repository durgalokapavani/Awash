//
//  HomeViewController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import StoreKit

class HomeViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var categories = [Category]()
    let getCategoriesUseCase: GetCategoriesUseCase = GetCategoriesUseCase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //STEP 1: Fetch categories and bundles
        activityIndicator.startAnimating()
        self.fetchCategories()
        
        //TODO: create DB index on Original transation id
        //TODO: LISTEN to LOGIN SUCCESS and PURCHASE SUCCESS notifications
        //TODO:RESTORE products: show "You have no purchased proudcts"
        //TODO: ADD ANALYTICS to IAPHandler
        homeCollectionView.register(UINib(nibName: String(describing: "CategoryCollectionViewCell"), bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.categoryCellReuseIdentifier)
        
        let nib = UINib(nibName: String(describing: HomeFooterCollectionViewCell.homeFooterCellReuseIdentifier), bundle: nil)
        homeCollectionView.register(nib, forSupplementaryViewOfKind:
                UICollectionElementKindSectionFooter, withReuseIdentifier: HomeFooterCollectionViewCell.homeFooterCellReuseIdentifier)
        homeCollectionView.register(UINib(nibName: String(describing: HomeHeaderView.homeHeaderViewReuseIdentifier), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HomeHeaderView.homeHeaderViewReuseIdentifier)
    }
    
    //MARK: private methods
    /*
    private func fetchStoreProuducts() {
        let store = IAPHandler.shared
        store.requestProducts(productIdentifiers: Set(store.productIdentifiers)) {success, products in
            //STEP 3: If products found, search for purchased products by logged in user
            // If user is not logged in or no products, show categories and bundles
            if (success && products != nil && (products!.count > 0)){
                AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_STORE_PRODUCTS_SUCCESS", additionalInfo: ["productCount": String( describing: products!.count)])
                // Attached store products to Catetories
                products?.forEach { storeProduct in
                    store.availableProducts[storeProduct.productIdentifier] = storeProduct
                    
                }
            }
            
        }
    }
    */
 
    
    private func reloadCollectionView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.homeCollectionView.reloadData()
        }
    }
    
    private func fetchCategories() {
        checkForConnectivityAndPerform() {
            self.getCategoriesUseCase.delegate = self
            self.getCategoriesUseCase.performAction()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = categories[indexPath.row]
        let cell:CategoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.categoryCellReuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        cell.category = item
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: CategoryCollectionViewCell.cellWidth, height: CategoryCollectionViewCell.cellHeight)
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        if category.isCourse {
            let courseDetailsVC = CourseViewController(nibName: "CourseViewController", bundle: nil)
            courseDetailsVC.hidesBottomBarWhenPushed = true
            courseDetailsVC.category = category
            
            navigationController?.pushViewController(courseDetailsVC, animated: true)
            
        } else if category.isIntro {
            let introDetailsVC = IntroViewController(nibName: "IntroViewController", bundle: nil)
            introDetailsVC.hidesBottomBarWhenPushed = true
            introDetailsVC.category = category
            
            navigationController?.pushViewController(introDetailsVC, animated: true)
        } else {
            let categoryDetailsVC = CategoryDetailsViewController(nibName: "CategoryDetailsViewController", bundle: nil)
            categoryDetailsVC.hidesBottomBarWhenPushed = true
            categoryDetailsVC.category = category
            
            navigationController?.pushViewController(categoryDetailsVC, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter && indexPath.row == 0 {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeFooterCollectionViewCell.homeFooterCellReuseIdentifier, for: indexPath) as! HomeFooterCollectionViewCell
            
            if categories.count > 0 {
                footerView.notes = ""
            } else {
                footerView.notes = "go ahead -- hold your breath"
            }
            return footerView
            
        } else if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeHeaderView.homeHeaderViewReuseIdentifier, for: indexPath) 
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            
            return CGSize(width: collectionView.bounds.size.width, height: 70)
            
        }
        return CGSize(width: 0, height: 0)
    }

}

//MARK: GetCategoriesUseCaseDelegate methods
extension HomeViewController: GetCategoriesUseCaseDelegate {
    func getCategoriesSuccess(_ categoriesCollection: CategoriesCollection) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_CATEGORIES_SUCCESS", additionalInfo: [:])
        categories = categoriesCollection.categories
        //Fetch user purhcases,if user has logged in
        if AwashUser.shared.isLoggedIn() {
            self.fetchUserPurchases() { success in
                self.reloadCollectionView()
            }
            
        } else {
            self.reloadCollectionView()
        }
        //STEP 2: Fetch the products to display prices
        
        /*
        checkForConnectivityAndPerform {
            self.fetchStoreProuducts()
        }
 */
        
        
    }
    
    func getCategoriesFailure(_ error: (title: String, message: String), backendError: BackendError?) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_CATEGORIES_FAILED", additionalInfo: [:])
    }
    
    
}
