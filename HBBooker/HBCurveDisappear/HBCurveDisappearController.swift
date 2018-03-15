//
//  HBCurveDisappearController.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/15.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class HBCurveDisappearController: UIViewController, HBBookViewDelegate, HBBookViewDataSource {
    let bookView = HBBookView()
    let reloadBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CurveDisappear"
        view.backgroundColor = .gray
        bookView.frame = CGRect.init(x: 20, y: 20, width: view.bounds.width - 40, height: view.bounds.height * 0.5)
        bookView.delegate = self
        bookView.dataSource = self
        bookView.register(pageClass: TestPageView.self, reuseIdentifier: "TestPageView")
        bookView.reloadData()
        view.addSubview(bookView)
        reloadBtn.frame = CGRect.init(x: (view.bounds.width - 100) / 2, y: bookView.frame.maxY + 50, width: 100, height: 30)
        reloadBtn.addTarget(self, action: #selector(reload), for: .touchUpInside)
        reloadBtn.setTitle("Reload", for: .normal)
        reloadBtn.setTitleColor(.blue, for: .normal)
        reloadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        view.addSubview(reloadBtn)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reload() -> () {
        bookView.reloadData()
    }
    
}

///HBBookViewDelegate
extension HBCurveDisappearController {
    func hb_pageTapped(index: Int) {
        
    }
}

///HBBookViewDataSource
extension HBCurveDisappearController {
    func hb_pageNumber(_ bookView: HBBookView) -> Int {
        return 5
    }
    
    func hb_pageContent(_ bookView: HBBookView, index: Int) -> HBPageView {
        if let page = bookView.dequeueReusablePage(withIdentifier: "TestPageView", index: index) as? TestPageView {
            page.index = index
            return page
        }
        return TestPageView()
    }
}
