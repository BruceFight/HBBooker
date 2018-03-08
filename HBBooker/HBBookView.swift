//
//  HBBookView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

public protocol HBBookViewDelegate : class {
    /// 点击某页
    func hb_pageTapped(index: Int) -> ()
    
}

public protocol HBBookViewDataSource : class {
    /// 页面数量
    func hb_pageNumber(_ bookView: HBBookView) -> Int
    /// 页面内容
    func hb_pageContent(_ bookView: HBBookView, index: Int) -> HBPageView
}

open class HBBookView: UIView, HBPageViewDelegate {
    
    public weak var delegate: HBBookViewDelegate?
    public weak var dataSource: HBBookViewDataSource?
    /// 需要展示的最大数目
    var totalPageNumber : Int = 0
    /// 所有的Page
    var totalPages : [HBPageView] = []
    /// 最大可见总数
    var visibleNumber : Int = 3
    /// 重用标识
    var reuseIdentifier : String = ""
    /// 页-页差
    var pageMargin : CGFloat = 15
    /// 当前位置
    var currentPosition : Int = 0
    /// 移除操作数记录
    var removedTotal : Int = 0
    
    private var PageClass : AnyClass?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
        let blindHeight : CGFloat = CGFloat(visibleNumber - 1) * pageMargin
        let lindOriginY : CGFloat = bounds.height - blindHeight
        let blindRect : CGRect = CGRect.init(x: 0, y: lindOriginY, width: bounds.width, height: blindHeight)
        if blindRect.contains(point) {
            return self
        }else {
            return totalPages.first ?? nil
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - HBPageViewDelegate
extension HBBookView {
    public func pageMoved(ratio: CGFloat, page: HBPageView) {
        /// Update whole position
        print("❤️ ratio -> \(ratio)")
        if ratio <= 1 {
            for i in (0 ..< totalPages.count).reversed() {
                let _page = totalPages[i]
                let index : CGFloat = CGFloat(i) - ratio
                if _page != page {
                    setPageFrame(page: _page, index: max(index, 0))
                }
            }
        }
    }
    
    public func pageRemoved(page: HBPageView) {
        removedTotal += 1
        let remainNumber = totalPageNumber - removedTotal
        if remainNumber <= 0 {
            removedTotal = 0
            initBook()
            return
        }
        if remainNumber < visibleNumber {
            totalPages.removeFirst()
            reloadData()
        }
        
        if remainNumber >= visibleNumber {
            if let _last = totalPages.last {
                page.alpha = 0
                totalPages.insert(_last, at: 0)
                totalPages.removeLast()
                reloadData()
            }
        }
    }
}

//MARK: - Methods
extension HBBookView {
    /// Init
    func initBook() -> () {
        totalPages.removeAll()
        if let pageView = PageClass.self as? HBPageView.Type {
            for _ in 0 ..< visibleNumber {
                let page = pageView.init()
                page.delegate = self
                page.inQueue = false
                page.reuseIdentifier = reuseIdentifier
                totalPages.append(page)
            }
        }
    }
    
    /// Frame
    func setPageFrame(page: HBPageView, index: CGFloat) -> () {
        let _width : CGFloat = bounds.width - 2 * index * pageMargin
        let _height : CGFloat = bounds.height - CGFloat(visibleNumber - 1) * pageMargin
        page.transform = CGAffineTransform.init(translationX: -index * self.pageMargin, y: -index * self.pageMargin)
        page.frame = CGRect.init(x: index * self.pageMargin, y: index * self.pageMargin, width: _width, height: _height)
        page.pop_removeAllAnimations()
        page.alpha = 1
    }
    
    /// Create Page
    func createPage(withIdentifier: String, inQueue: Bool) -> HBPageView {
        let page = HBPageView()
        page.delegate = self
        page.reuseIdentifier = withIdentifier
        page.inQueue = inQueue
        return page
    }
    
    /// Reset Pages
    func resetAllPages() -> () {
        totalPages = totalPages.map({ (page) -> HBPageView in
            page.reuseIdentifier = self.reuseIdentifier
            page.inQueue = false
            return page
        })
    }
}

//MARK: - Methods For Outer
extension HBBookView {
    /// ReloadData
    func reloadData() -> () {
        if visibleNumber <= 0 {
            assert(false, "Visible pages can not be less than or equals to 0 !")
        }
        resetAllPages()
        if let _dataSource = dataSource {
            totalPageNumber = _dataSource.hb_pageNumber(self)
            if totalPageNumber <= 0 { return }
            
            for i in 0 ..< totalPages.count {
                let page = _dataSource.hb_pageContent(self, index: i + removedTotal)
                totalPages[i] = page
            }
            
            for i in (0 ..< totalPages.count).reversed() {
                let page = totalPages[i]
                setPageFrame(page: page, index: CGFloat(i))
                addSubview(page)
            }
        }
    }
    
    /// Register
    func register(pageClass: AnyClass?, reuseIdentifier: String) -> () {
        self.reuseIdentifier = reuseIdentifier
        if let _pageClass = pageClass {
            PageClass = _pageClass
            initBook()
        }
    }
    
    /// Dequeue
    func dequeueReusablePage(withIdentifier: String, index: Int) -> HBPageView? {
        for i in 0 ..< totalPages.count {
            let page = totalPages[i]
            if !page.inQueue {
                page.inQueue = true
                return page
            }
        }
        return createPage(withIdentifier: withIdentifier, inQueue: true)
    }
}


