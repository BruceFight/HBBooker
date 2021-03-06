//
//  TestCurvePageView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/4/5.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit


class TestCurvePageView: HBCurvePageView {
    
    var index : String = "" {
        didSet{
            indexLabel.text = index
            setNeedsLayout()
        }
    }
    
    var imageView = UIImageView()
    
    
    fileprivate var indexLabel : UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        imageView.image = #imageLiteral(resourceName: "lufei")
        addSubview(imageView)
        indexLabel.font = UIFont.systemFont(ofSize: 80)
        indexLabel.textColor = .white
        indexLabel.textAlignment = .center
        addSubview(indexLabel)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indexLabel.sizeToFit()
        imageView.frame = bounds
        indexLabel.frame = CGRect.init(x: (bounds.width - indexLabel.bounds.width) / 2, y: (bounds.width - indexLabel.bounds.height) / 2, width: indexLabel.bounds.width, height: indexLabel.bounds.height)
    }
    
}
