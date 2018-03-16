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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        title = "CurveBack"
        bookView.frame = CGRect.init(x: 20, y: 20, width: view.bounds.width - 40, height: view.bounds.height * 0.5)
        bookView.delegate = self
        bookView.dataSource = self
        bookView.register(pageClass: TestNewPageView.self, reuseIdentifier: "TestNewPageView")
        //bookView.reloadData()
        view.addSubview(bookView)
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
        print("❤️ dataPosition ::: \(index)")
    }
}

///HBBookViewDataSource
extension HBCurveBackController {
    func hb_pageNumber(_ bookView: HBNewBookView) -> Int {
        return 4
    }
    
    func hb_pageContent(_ bookView: HBNewBookView, index: Int) -> HBNewPageView {
        if let page = bookView.dequeueReusablePage(withIdentifier: "TestNewPageView", index: index) as? TestNewPageView {
            page.index = index
            return page
        }
        return TestNewPageView()
    }
}
