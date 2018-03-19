//
//  HBCurveBackController.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/15.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBCurveBackController: UIViewController, HBNewBookViewDelegate, HBNewBookViewDataSource {
    let bookView = HBNewBookView()
    
    var models = [String]()
    
    let flyButton = UIButton()
    
    let reloadButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        for index in 0 ..< 5 {
            models.append("\(index)")
        }
        view.backgroundColor = .gray
        title = "CurveBack"
        bookView.frame = CGRect.init(x: 20, y: (view.bounds.height - view.bounds.height * 0.5) / 2, width: view.bounds.width - 40, height: view.bounds.height * 0.5)
        bookView.delegate = self
        bookView.dataSource = self
        bookView.register(pageClass: TestNewPageView.self, reuseIdentifier: "TestNewPageView")
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
    
    @objc func fly() -> () {
        bookView.pageMove {[weak self] (position) -> (Bool) in
            self?.models.remove(at: position)
            return true
        }
    }

    @objc func reload() -> () {
        models[2] = "20"
        bookView.reload(item: 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Deinit \(self)")
    }
}

///HBBookViewDelegate
extension HBCurveBackController {
    func hb_pageTapped(index: Int) {
        print("❤️ page tapped ::: \(index)")
    }
    
    func hb_pageTo(index: Int) {
        print("❤️❤️ page move to ::: \(index)")
    }
}

///HBBookViewDataSource
extension HBCurveBackController {
    func hb_pageNumber(_ bookView: HBNewBookView) -> Int {
        return models.count
    }
    
    func hb_pageContent(_ bookView: HBNewBookView, index: Int) -> HBNewPageView {
        if let page = bookView.dequeueReusablePage(withIdentifier: "TestNewPageView", index: index) as? TestNewPageView {
            if let _model = models.hb_object(for: index) {
                page.index = _model
            }
            return page
        }
        return TestNewPageView()
    }
}
