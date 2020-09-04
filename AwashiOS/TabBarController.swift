//
//  TabBarController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit

enum TabBarItems: String {
    
    case home = "Home"
    case activity = "Activity"
    case settings = "Settings"
    
    var selectedImage: UIImage {
        switch self {
        case .home:
            return #imageLiteral(resourceName: "homeSelected")
        case .activity:
            return #imageLiteral(resourceName: "activitySelected")
        case .settings:
            return #imageLiteral(resourceName: "settingsSelected")
        }
    }
    
    var image: UIImage {
        switch self {
        case .home:
            return #imageLiteral(resourceName: "home")
        case .activity:
            return #imageLiteral(resourceName: "activity")
        case .settings:
            return #imageLiteral(resourceName: "settings")
        }
    }
    
    var viewController: UIViewController {
        let rootController: UIViewController
        let navController: UINavigationController
        
        switch self {
        case .home:
            rootController = HomeViewController.init(nibName:"HomeViewController",bundle:nil)
            navController = UINavigationController(rootViewController: rootController)
            break
            
        case .activity:
            rootController = ActivityViewController.init(nibName:"ActivityViewController",bundle:nil)
            navController = UINavigationController(rootViewController: rootController)
            break
        case .settings:
            rootController = SettingsViewController.init(nibName:"SettingsViewController",bundle:nil)
            navController = UINavigationController(rootViewController: rootController)
            break
            
        }
        
        navController.tabBarItem = UITabBarItem(title: "",
                                                    image: image,
                                                    selectedImage: selectedImage)
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        navController.tabBarItem.title = nil
        
        return navController
        
    }
}

class TabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeTabbar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: private methods
    private func initializeTabbar() {
        var viewControllers = [UIViewController]()
        viewControllers.append(TabBarItems.activity.viewController)
        viewControllers.append(TabBarItems.home.viewController)
        viewControllers.append(TabBarItems.settings.viewController)
        self.viewControllers = viewControllers
        self.selectedIndex = 1
        self.setupTabBarAppearence()
    }
    
    private func setupTabBarAppearence() {
        self.tabBar.isTranslucent = false
        self.tabBarController?.delegate = self
        self.tabBarController?.tabBar.backgroundColor = .white
        UITabBar.appearance().tintColor = UIColor(hex: Constants.Colors.lightishBlue)
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        
        tabBar.backgroundColor = UIColor.white
        //tabBar.shadowImage = UIImage(named: "transparentShadow.png")
        
        if let items = self.tabBar.items {
            for item in items{
                item.image =  item.image?.withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray
                    ], for: .normal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor(hex: Constants.Colors.lightishBlue)], for: .selected)
            }
        }
    }
    
}

//MARK: UITabBarControllerDelegate methods
extension TabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}
