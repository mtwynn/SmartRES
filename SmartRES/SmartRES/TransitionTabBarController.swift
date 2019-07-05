//
//  TransitionTabBarController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/5/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit

class TransitionTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

    }
}

extension TransitionTabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
}
