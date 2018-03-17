//
//  HBNewPageView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit
import pop

public protocol HBNewPageViewDelegate : class {
    /// 页面点击
    func pageTapped(page: HBNewPageView) -> ()
}

open class HBNewPageView: UIView ,UIGestureRecognizerDelegate {
    
    open var reuseIdentifier : String?
    open var inQueue : Bool = true
    open var position : Int = 0
    
    public weak var delegate : HBNewPageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tap() -> () {
        delegate?.pageTapped(page: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
