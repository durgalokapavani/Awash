//
//  ViewController.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let accessCode = UserDefaultsUtil.accessCode()
        let validate = ValidateAccessCodeUseCase()
        validate.delegate = self
        validate.params["accessCode"] = accessCode
        validate.performAction()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

extension ViewController: ValidateAccessCodeUseCaseDelegate {
    
    func validationSuccess() {
        let window = UIApplication.shared.windows[0]
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    func validationFailure() {
        
        DispatchQueue.main.async  {
            let window = UIApplication.shared.windows[0]
            let verifyVC = VerificationViewController(nibName: "VerificationViewController", bundle: nil)
            self.navigationController?.pushViewController(verifyVC, animated: true)
            window.rootViewController = verifyVC
        }
        
        
    }
}
