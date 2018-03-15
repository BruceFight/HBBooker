//
//  HBNewBookView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

public protocol HBNewBookViewDelegate : class {
    /// 点击某页
    func hb_pageTapped(index: Int) -> ()
    
}

public protocol HBNewBookViewDataSource : class {
    /// 页面数量
    func hb_pageNumber(_ bookView: HBNewBookView) -> Int
    /// 页面内容
    func hb_pageContent(_ bookView: HBNewBookView, index: Int) -> HBNewPageView
}

open class HBNewBookView: UIView, HBNewPageViewDelegate {
    
    public weak var delegate: HBNewBookViewDelegate?
    public weak var dataSource: HBNewBookViewDataSource?
    /// 需要展示的最大数目
    var totalPageNumber : Int = 0
    /// 所有的Page
    var totalPages : [HBNewPageView] = []
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
    
    fileprivate var direction : HBDirection?
    fileprivate var firstTouchPoint : CGPoint = .zero
    
    fileprivate var currentPage : HBNewPageView?
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first {
            firstTouchPoint = firstTouch.location(in: UIApplication.shared.keyWindow)
        }
    }
    
    fileprivate var moveRatio : CGFloat = 0
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let secondTouch = touches.first {
            let secondTouchPoint = secondTouch.location(in: UIApplication.shared.keyWindow)
            if let _direction = direction {/// 如果有方向
                moveRatio = (firstTouchPoint.x - secondTouchPoint.x) / (bounds.width)
                switch _direction {
                case .left:
                    pageMoveLeft()
                    break
                case .right:
                    print("❤️ moveRatio -> \(moveRatio)")
                    pageMoveRight()
                    break
                }
            }else {/// 如果没有方向
                if secondTouchPoint.x > firstTouchPoint.x {
                    direction = .right
                }else if secondTouchPoint.x < firstTouchPoint.x {
                    direction = .left
                }
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pageMoveLeftDone()
    }
    
    fileprivate var previousPage : HBNewPageView?
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let secondTouch = touches.first {
            let secondTouchPoint = secondTouch.location(in: UIApplication.shared.keyWindow)
            moveRatio = (firstTouchPoint.x - secondTouchPoint.x) / (bounds.width / 2)
        }
        pageMoveLeftDone()
    }
}

//MARK: - HBNewPageViewDelegate
extension HBNewBookView {
    public func pageMoved(ratio: CGFloat, page: HBNewPageView) {
        /// Update whole position
        //print("❤️ ratio -> \(ratio)")
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
    
    public func pageMovedBack(ratio: CGFloat, page: HBNewPageView) {
        
    }
    
    public func pageRemoved(page: HBNewPageView) {
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
extension HBNewBookView {
    /// Init
    func initBook() -> () {
        totalPages.removeAll()
        if let pageView = PageClass.self as? HBNewPageView.Type {
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
    func setPageFrame(page: HBNewPageView, index: CGFloat) -> () {
        let _width : CGFloat = bounds.width - 2 * index * pageMargin
        let _height : CGFloat = bounds.height - CGFloat(visibleNumber - 1) * pageMargin
        page.transform = CGAffineTransform.init(translationX: -index * self.pageMargin, y: -index * self.pageMargin)
        page.frame = CGRect.init(x: index * self.pageMargin, y: index * self.pageMargin, width: _width, height: _height)
        page.pop_removeAllAnimations()
        page.alpha = 1
    }
    
    /// Create Page
    func createPage(withIdentifier: String, inQueue: Bool) -> HBNewPageView {
        let page = HBNewPageView()
        page.delegate = self
        page.reuseIdentifier = withIdentifier
        page.inQueue = inQueue
        return page
    }
    
    /// Reset Pages
    func resetAllPages() -> () {
        totalPages = totalPages.map({ (page) -> HBNewPageView in
            page.reuseIdentifier = self.reuseIdentifier
            page.inQueue = false
            return page
        })
    }
}

//MARK: - Methods For Outer
extension HBNewBookView {
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
            currentPage = totalPages.first
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
    func dequeueReusablePage(withIdentifier: String, index: Int) -> HBNewPageView? {
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


extension HBNewBookView {
    /// 左划操作,看有没有当前可见页
    func pageMoveLeft() -> () {
        if let _currentPage = currentPage {
            if moveRatio >= 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * self.moveRatio))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * self.moveRatio), y: 0)
                    _currentPage.transform = rotate.concatenating(move)
                }, completion: { (true) in
                    if self.moveRatio >= 1 {
                        self.previousPage = _currentPage
                    }
                })
            }
        }
    }
    
    /// 左划操作完
    func pageMoveLeftDone() -> () {
        direction = nil
        if moveRatio >= 0.5 {
            moveRatio = 1.2
        }else {
            moveRatio = 0
        }
        pageMoveLeft()
    }
    
    /// 右划操作,看有没有前一页
    func pageMoveRight() -> () {
        if let _previousPage = previousPage {
            if moveRatio <= 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * (1 + self.moveRatio)))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * (1 + self.moveRatio)), y: 0)
                    print("❤️❤️ 移动了 -- \(-(self.bounds.width * self.moveRatio))")
                    _previousPage.transform = rotate.concatenating(move)
                }, completion: { (true) in
                    if self.moveRatio == 0 {
                        //self.previousPage = nil
                    }
                })
            }
        }
    }
}

