//
//  UIColorExtension.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/04/29.
//

import UIKit

extension UIColor {
    static func fromRGB(rgbValue: UInt, alpha: CGFloat = CGFloat(0.7)) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF)) / 255.0,
            alpha: alpha)
    }
}
