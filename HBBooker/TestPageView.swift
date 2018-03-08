
//
//  TestPageView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class TestPageView: HBPageView {

    var index : Int = 0 {
        didSet{
            indexLabel.text = "\(index)"
            setNeedsLayout()
        }
    }

    fileprivate var indexLabel : UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        indexLabel.font = UIFont.systemFont(ofSize: 50)
        indexLabel.textColor = UIColor.brown
        indexLabel.textAlignment = .center
        addSubview(indexLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indexLabel.sizeToFit()
        indexLabel.frame = CGRect.init(x: (bounds.width - indexLabel.bounds.width) / 2, y: (bounds.width - indexLabel.bounds.height) / 2, width: indexLabel.bounds.width, height: indexLabel.bounds.height)
    }
    
}
