//
//  UIViewControllerExtension.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/04/29.
//

import UIKit

extension UIViewController {
    var tutorialStoryboard: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func initTutorialVC(withIdentifier id: String) -> UIViewController {
        return self.tutorialStoryboard.instantiateViewController(withIdentifier: id)
    }
}
