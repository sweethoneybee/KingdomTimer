//
//  UIAlertController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/06/02.
//

import UIKit

extension UIAlertController {
    static func makeSimpleAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        return alert
    }
}
