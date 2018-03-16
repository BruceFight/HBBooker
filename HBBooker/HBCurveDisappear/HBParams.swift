//
//  HBParams.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/7.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

/// 速度
public enum HBDragSpeed: TimeInterval {
    case slow = 2.0
    case moderate = 1.5
    case `default` = 0.8
    case fast = 0.4
}

/// 方向
public enum HBDirection {
    case left
    case right
}

public struct HBPageParam {
    public static let cardResetAnimationDuration: TimeInterval = 0.2
}

extension Array {
    func hb_object(for index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}



/**
 RGBA颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 - parameter alpha:      透明度值
 
 - returns: 相应颜色
 */
func RGBA(_ colorValue: UInt32, alpha: CGFloat) -> UIColor {
    
    return UIColor.init(red: CGFloat((colorValue>>16)&0xFF)/256.0, green: CGFloat((colorValue>>8)&0xFF)/256.0, blue: CGFloat((colorValue)&0xFF)/256.0 , alpha: alpha)
}

/**
 RGB颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 
 - returns: 相应颜色
 */
func RGB(_ colorValue: UInt32) -> UIColor {
    return RGBA(colorValue, alpha: 1.0)
}

