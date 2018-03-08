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
enum HBDirection {
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
