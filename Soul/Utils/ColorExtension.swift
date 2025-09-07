//
//  ColorExtension.swift
//  Soul
//
//  Created by Ricard.li on 2025/9/7.
//

import Foundation


import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        
        switch hexSanitized.count {
        case 3: // RGB (12-bit, like #F0A)
            let r = (rgbValue & 0xF00) >> 8
            let g = (rgbValue & 0x0F0) >> 4
            let b = rgbValue & 0x00F
            self.init(
                red: CGFloat(r) / 15.0,
                green: CGFloat(g) / 15.0,
                blue: CGFloat(b) / 15.0,
                alpha: 1.0
            )
        case 6: // RGB (24-bit, like #FF00AA)
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        case 8: // RGBA (32-bit, like #FF00AAFF)
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        default:
            self.init(white: 0.0, alpha: 0.0) // 兜底透明色
        }
    }
}
