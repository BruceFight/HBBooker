//
//  HBNewCurveBackController.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/4/5.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBNewCurveBackController: UIViewController, HBCurveBookViewDelegate, HBCurveBookViewDataSource  {
    let bookView = HBCurveBookView()
    
    var models = [String]()
    
    let flyButton = UIButton()
    let reloadButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.masksToBounds = true
        for index in 0 ..< 1 {
            models.append("\(index)")
        }
        view.backgroundColor = .gray
        title = "CurveBack"
        bookView.frame = CGRect.init(x: 20, y: (view.bounds.height - view.bounds.height * 0.5) / 2, width: view.bounds.width - 40, height: view.bounds.height * 0.5)
        bookView.delegate_ = self
        bookView.dataSource = self
        bookView.register(pageClass: TestCurvePageView.self, reuseIdentifier: "TestCurvePageView")
        //bookView.reloadData()
        view.addSubview(bookView)
        
        flyButton.setTitle("FLY", for: .normal)
        flyButton.setTitleColor(.black, for: .normal)
        flyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        flyButton.addTarget(self, action: #selector(fly), for: .touchUpInside)
        flyButton.sizeToFit()
        flyButton.frame = CGRect.init(x: (view.bounds.width - flyButton.bounds.width) / 2, y: bookView.frame.maxY + 10, width: flyButton.bounds.width, height: flyButton.bounds.height)
        view.addSubview(flyButton)
        
        reloadButton.setTitle("reload", for: .normal)
        reloadButton.setTitleColor(.black, for: .normal)
        reloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        reloadButton.sizeToFit()
        reloadButton.frame = CGRect.init(x: (view.bounds.width - reloadButton.bounds.width) / 2, y: flyButton.frame.maxY + 10, width: reloadButton.bounds.width, height: reloadButton.bounds.height)
        view.addSubview(reloadButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func fly() -> () {
//        bookView.pageMove {[weak self] (position) -> (Bool) in
//            self?.models.remove(at: position)
//            return true
//        }
    }
    
    @objc func reload() -> () {
//        if let _ = models.hb_object(for: 2) {
//            models[2] = "20"
//        }
//        bookView.reload(item: 2)
    }
}

///HBBookViewDelegate
extension HBNewCurveBackController {

    
    func hb_pageTapped(index: Int, page: HBCurvePageView) {
        print("❤️ page tapped ::: \(index)")
    }
    
    func hb_pageTo(index: Int, page: HBCurvePageView?) {
        print("❤️❤️ page move to ::: \(index)")
    }
    
    func hb_pageMoved(ratio: CGFloat, direction: HBCurveDirection, page: HBCurvePageView?) {
        
    }
    
    func hb_pageFlyDone() {
        
    }
}

///HBBookViewDataSource
extension HBNewCurveBackController {
    func hb_pageNumber(_ bookView: HBCurveBookView) -> Int {
        return models.count
    }
    
    func hb_pageContent(_ bookView: HBCurveBookView, index: Int) -> HBCurvePageView {
        if let page = bookView.dequeueReusablePage(withIdentifier: "TestCurvePageView", index: index) as? TestCurvePageView {
            if let _model = models.hb_object(for: index) {
                page.index = _model
            }
            return page
        }
        return TestCurvePageView()
    }
}

