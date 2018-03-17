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
    var dataPosition : Int = 0
    
    private var PageClass : AnyClass?
    typealias RemoveDone = ((_ ifDone: Bool) -> ())?
    fileprivate var animationDuration : TimeInterval = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var direction : HBDirection?
    fileprivate var firstTouchPoint : CGPoint = .zero
    fileprivate var currentPage : HBNewPageView?
    fileprivate var moveRatio : CGFloat = 0
    fileprivate var previousPage : HBNewPageView?
    fileprivate var touchIn : Bool = false
}

//MARK: - Touch
extension HBNewBookView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first {
            firstTouchPoint = firstTouch.location(in: UIApplication.shared.keyWindow)
        }
    }
    
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
                    pageMoveRight()
                    break
                }
            }else {/// 如果没有方向
                if self.touchIn == false {
                    if secondTouchPoint.x > firstTouchPoint.x {
                        direction = .right
                        
                    }else if secondTouchPoint.x < firstTouchPoint.x {
                        direction = .left
                        if let _pre = previousPage {
                            if self.totalPageNumber >= self.totalPages.count {
                                /// 卡片为1
                                if self.totalPageNumber <= 1 {
                                    return
                                }
                                /// 卡片 > 1 && 卡片 < self.visibleNumber + 1
                                var lastPosition : Int = self.dataPosition
                                if self.totalPageNumber >= self.visibleNumber + 1 {
                                    lastPosition = self.nextData(current: self.nextData(current: self.nextData(current: self.dataPosition)))
                                /// 卡片 > self.visibleNumber + 1
                                }else if self.totalPageNumber > 1 && self.totalPageNumber < self.visibleNumber + 1 {
                                    for _ in 0 ..< self.totalPageNumber - 1 {
                                        lastPosition = self.nextData(current: lastPosition)
                                    }
                                }
                                
                                _pre.inQueue = false
                                _pre.alpha = 0
                                _pre.transform = .identity
                                self.totalPages.append(_pre)
                                self.totalPages.removeFirst()
                                if let _dataSource = self.dataSource {
                                    let _newPage = _dataSource.hb_pageContent(self, index: lastPosition)
                                    insertSubview(_newPage, at: 0)
                                    let lastIndex : Int = self.totalPages.count - 1
                                    if let _ = self.totalPages.hb_object(for: lastIndex) {
                                        self.setPageFrame(page: _newPage, index: CGFloat(lastIndex))
                                        self.totalPages[lastIndex] = _newPage
                                    }
                                }
                            }else {
                                self.totalPages.removeFirst()
                            }
                        }
                    }
                    self.touchIn = true
                }
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.cancelOrEnd(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.cancelOrEnd(touches, with: event)
    }
    
    func cancelOrEnd(_ touches: Set<UITouch>, with event: UIEvent?) -> () {
        if let secondTouch = touches.first {
            let secondTouchPoint = secondTouch.location(in: UIApplication.shared.keyWindow)
            moveRatio = (firstTouchPoint.x - secondTouchPoint.x) / (bounds.width / 2)
        }
        if let _direction = self.direction {
            switch _direction {
            case .left:
                pageMoveLeftDone()
                break
            case .right:
                pageMoveRightDone()
                break
            }
        }
    }
}

//MARK: - Methods
extension HBNewBookView {
    /// Init
    func initBook() -> () {
        totalPages.removeAll()
        if let _dataSource = dataSource {
            self.totalPageNumber = _dataSource.hb_pageNumber(self)
            if totalPageNumber <= 0 { return }
            var needNumber : Int = totalPageNumber
            if totalPageNumber > visibleNumber + 1 {
                needNumber = visibleNumber + 1
            }
            if let pageView = PageClass.self as? HBNewPageView.Type {
                for i in 0 ..< needNumber {
                    let page = pageView.init()
                    page.delegate = self
                    page.inQueue = false
                    page.reuseIdentifier = reuseIdentifier
                    if totalPageNumber >= visibleNumber {
                        if i == visibleNumber {
                            page.alpha = 0
                        }
                    }
                    totalPages.append(page)
                }
            }
            
            for i in (0 ..< totalPages.count).reversed() {
                let page = totalPages[i]
                setPageFrame(page: page, index: CGFloat(i))
                addSubview(page)
            }
            
            for i in 0 ..< totalPages.count {
                let _getDataPage = _dataSource.hb_pageContent(self, index: i)
                totalPages[i] = _getDataPage
            }
            currentPage = totalPages.first
        }
    }
    
    /// page move ratio
    func pageMoved(ratio: CGFloat, page: HBNewPageView, direction: HBDirection) {
        /// Update whole position
        var realRatio = ratio
        switch direction {
        case .left:/// 左划调整
            if ratio > 1 {
                realRatio = 1
            }
            break
        case .right:/// 右划调整
            if ratio < -1 {
                realRatio = -1
            }
            break
        }
        for i in (0 ..< totalPages.count).reversed() {
            let _page = totalPages[i]
            let index : CGFloat = (direction == .right) ? CGFloat(i - 1) + CGFloat(fabsf(Float(realRatio))) : CGFloat(i) - realRatio
            if _page != page {
                switch direction {
                case .left:
                    if _page.alpha < 1 {
                        _page.alpha = (direction == .right) ? realRatio + 1 : realRatio
                    }
                    break
                case .right:
                    if i == totalPages.count - 1 {
                        _page.alpha = (direction == .right) ? realRatio + 1 : realRatio
                    }
                    break
                }
                setPageFrame(page: _page, index: max(index, 0))
            }
        }
    }
    
    /// page remove
    func pageRemove(removedPage: HBNewPageView) -> () {
        if let _pre = self.previousPage {
            if let removeIndex = totalPages.index(of: removedPage) {
                for i in 0 ..< self.totalPages.count {
                    let page = self.totalPages[i]
                    if page != _pre && page != removedPage {
                        self.setPageFrame(page: page, index: CGFloat(i - 1 - removeIndex))
                    }
                }
            }
        }else {
            if let removeIndex = totalPages.index(of: removedPage) {
                for i in 0 ..< self.totalPages.count {
                    let page = self.totalPages[i]
                    if i <= 3 {
                        page.alpha = 1
                    }
                    if page != removedPage {
                        self.setPageFrame(page: page, index: CGFloat(i - 1 - removeIndex))
                    }
                }
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
    }
    
    /// Create Page
    func createPage(withIdentifier: String, inQueue: Bool) -> HBNewPageView {
        let page = HBNewPageView()
        page.delegate = self
        page.reuseIdentifier = withIdentifier
        page.inQueue = inQueue
        return page
    }
    
    /// 下一页
    fileprivate func nextData(current: NSInteger) -> NSInteger {
        let total = self.totalPageNumber
        if total > 0 {
            return (current + 1) % total //队列指针+1
        }
        return 0
    }
    
    /// 上一页
    fileprivate func preData(current: NSInteger) -> NSInteger {
        let total = self.totalPageNumber
        if total > 0 {
            return (current - 1 + total) % total // 队列指针-1
        }
        return 0
    }
}

//MARK: - Methods For Outer
extension HBNewBookView {
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
    
    /// 页面飞走
    func pageMove(done: ((_ position: Int) -> (Bool))?) -> () {
        if let _currentPage = currentPage {
            if self.totalPageNumber <= 0 { return }
            if self.touchIn == false {            
                self.touchIn = true
                if previousPage == currentPage {
                    UIView.animate(withDuration: animationDuration, animations: {
                        let rotate = CGAffineTransform.init(rotationAngle: 0)
                        let move = CGAffineTransform.init(translationX: 0, y: 0)
                        _currentPage.transform = rotate.concatenating(move)
                    }, completion: { (true) in
                        self.fly(_currentPage: _currentPage, done: done)
                    })
                }else {
                    self.fly(_currentPage: _currentPage, done: done)
                }
            }
        }
    }
    
    /// 飞
    func fly(_currentPage: HBNewPageView,done: ((_ position: Int) -> (Bool))?) -> () {
        UIView.animate(withDuration: animationDuration, animations: {
            let rotate = CGAffineTransform.init(rotationAngle: CGFloat.pi / 12)
            let move = CGAffineTransform.init(translationX: self.bounds.width, y: -UIScreen.main.bounds.height)
            _currentPage.transform = rotate.concatenating(move)
            self.pageRemove(removedPage: _currentPage)
        }, completion: { (true) in
            _currentPage.alpha = 0
            _currentPage.transform = .identity
            _currentPage.inQueue = false
            
            var nextIndex = 0
            for i in 0 ..< self.totalPages.count {
                let _page = self.totalPages[i]
                if _currentPage == _page {
                    self.totalPages.remove(at: i)
                    nextIndex = i
                    if let _ifDone = done?(self.dataPosition) {
                        if _ifDone {
                            if let _dataSource = self.dataSource {
                                self.totalPageNumber = _dataSource.hb_pageNumber(self)
                                if self.dataPosition >= self.totalPageNumber {
                                    self.dataPosition = 0
                                }
                                print("❤️removeDone + dataPosition --- \(self.dataPosition)")
                                self.removeDoneOperation(nextIndex: nextIndex, _currentPage: _currentPage)
                            }
                        }
                    }
                    break
                }
            }
        })
    }
    
    /// remove done operation
    func removeDoneOperation(nextIndex: Int, _currentPage: HBNewPageView) -> () {
        /// >= 4
        if self.totalPageNumber >= self.visibleNumber + 1 {
            self.totalPages.append(_currentPage)
            if let _dataSource = self.dataSource {
                /// 有前一页
                let lastPosition : Int = self.nextData(current: self.nextData(current: self.dataPosition))
                var page = HBNewPageView()
                if let _ = previousPage {
                    page = _dataSource.hb_pageContent(self, index: lastPosition)
                /// 没有前一页
                }else {
                    page = _dataSource.hb_pageContent(self, index: self.nextData(current: lastPosition))
                }
                
                page.alpha = (previousPage == nil) ? 1 : 0
                page.transform = .identity
                self.insertSubview(page, at: 0)
                let lastIndex : Int = self.totalPages.count - 1
                if let _ = self.totalPages.hb_object(for: lastIndex) {
                    self.setPageFrame(page: page, index: CGFloat(lastIndex))
                    self.totalPages[lastIndex] = page
                }
                
                if let _nextPage = self.totalPages.hb_object(for: nextIndex) {
                    self.currentPage = _nextPage
                }
                
                UIView.animate(withDuration: animationDuration, animations: {
                    page.alpha = (self.previousPage == nil) ? 0 : 1
                    self.setPageFrame(page: page, index: 2)
                }, completion: { (true) in
                    self.touchIn = false
                })
            }
        }else {
            _currentPage.removeFromSuperview()
            if self.totalPageNumber == 1 {
                if let _pre = self.previousPage {
                    UIView.animate(withDuration: animationDuration, animations: {
                        let rotate = CGAffineTransform.init(rotationAngle: 0)
                        let move = CGAffineTransform.init(translationX: 0, y: 0)
                        _pre.transform = rotate.concatenating(move)
                    }, completion: { (true) in
                        self.currentPage = _pre
                        self.touchIn = false
                    })
                }else {
                    if let _firstPage = self.totalPages.first {
                        self.currentPage = _firstPage
                    }
                    self.touchIn = false
                }
            }else {
                if let _nextPage = self.totalPages.hb_object(for: nextIndex) {
                    self.currentPage = _nextPage
                }
                self.touchIn = false
            }
        }
    }
}

//MARK: - Operation
extension HBNewBookView {
    /// 左划操作,看有没有当前可见页
    func pageMoveLeft() -> () {
        if let _currentPage = currentPage {
            if _currentPage.frame.origin.x <= -(self.bounds.width * 1.2) { return }
            if moveRatio >= 0 {
                pageMoved(ratio: moveRatio, page: _currentPage, direction: .left)
                UIView.animate(withDuration: animationDuration, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * self.moveRatio))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * self.moveRatio), y: 0)
                    _currentPage.transform = rotate.concatenating(move)
                }, completion: { (true) in})
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
        leftDoneAnimation()
    }
    
    /// 左划完成动画
    func leftDoneAnimation() -> () {
        if let _currentPage = currentPage {
            if moveRatio >= 0 {
                pageMoved(ratio: moveRatio, page: _currentPage, direction: .left)
                UIView.animate(withDuration: animationDuration, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * self.moveRatio))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * self.moveRatio), y: 0)
                    _currentPage.transform = rotate.concatenating(move)
                }, completion: { (true) in
                    if self.moveRatio >= 1 {
                        /// 更新previousPage
                        self.previousPage = _currentPage
                        /// 更新数据数组位置
                        self.dataPosition = self.nextData(current: self.dataPosition)
                        print("❤️ dataPosition --- \(self.dataPosition)")
                        /// 找到下一页,并确立为当前页
                        if let nextPage = self.totalPages.hb_object(for: 1) {
                            self.currentPage = nextPage
                        }
                        self.touchIn = false
                    }else {
                        /// 左划取消的时候,根据是否有前页---> 
                        /// 如果有前页,取出并获取对应位置数据,贴在数组和界面的最前面
                        if let _ = self.previousPage {
                            if let _lastPage = self.totalPages.last {
                                _lastPage.inQueue = false
                                _lastPage.transform = .identity
                                _lastPage.frame = _currentPage.frame
                                self.totalPages.insert(_lastPage, at: 0)
                                self.totalPages.removeLast()
                                if let _dataSource = self.dataSource {
                                    let _prePage = _dataSource.hb_pageContent(self, index: self.preData(current: self.dataPosition))
                                    self.totalPages[0] = _prePage
                                    self.insertSubview(_prePage, aboveSubview: _currentPage)
                                    UIView.animate(withDuration: self.animationDuration, animations: {
                                        let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * 1.2))
                                        let move = CGAffineTransform.init(translationX: -(self.bounds.width * 1.2), y: 0)
                                        _prePage.transform = rotate.concatenating(move)
                                    }, completion: { (true) in
                                        _prePage.alpha = 1
                                        self.touchIn = false
                                    })
                                }
                            }
                        }else {
                            self.touchIn = false
                        }
                    }
                })
            }else {
                self.touchIn = false
            }
        }else {
            self.touchIn = false
        }
    }
    
    /// 右划操作,看有没有前一页
    func pageMoveRight() -> () {
        if let _previousPage = previousPage {
            if _previousPage.frame.origin.x == 0 { return }
            if moveRatio <= 0 {
                pageMoved(ratio: moveRatio, page: _previousPage, direction: .right)
                UIView.animate(withDuration: animationDuration, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * (1 + self.moveRatio)))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * (1 + self.moveRatio)), y: 0)
                    _previousPage.transform = rotate.concatenating(move)
                }, completion: { (true) in })
            }
        }
    }
    
    /// 右划操作完
    func pageMoveRightDone() -> () {
        direction = nil
        if moveRatio <= -0.5 {
            moveRatio = -1
        }else {
            moveRatio = 0
        }
        rightDoneAnimation()
    }
    
    /// 右划完成动画
    func rightDoneAnimation() -> () {
        if let _previousPage = previousPage {
            if moveRatio >= 0 {
                pageMoved(ratio: moveRatio, page: _previousPage, direction: .right)
                UIView.animate(withDuration: animationDuration, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * (1.2)))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * (1.2)), y: 0)
                    _previousPage.transform = rotate.concatenating(move)
                }, completion: { (true) in
                    self.touchIn = false
                })
            }else {
                pageMoved(ratio: moveRatio, page: _previousPage, direction: .right)
                UIView.animate(withDuration: animationDuration, animations: {
                    let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * (1 + self.moveRatio)))
                    let move = CGAffineTransform.init(translationX: -(self.bounds.width * (1 + self.moveRatio)), y: 0)
                    _previousPage.transform = rotate.concatenating(move)
                }, completion: { (true) in
                    self.currentPage = _previousPage
                    if self.totalPageNumber <= 1 {
                        self.touchIn = false
                        return
                    }
                    self.dataPosition = self.preData(current: self.dataPosition)
                    print("❤️ dataPosition --- \(self.dataPosition)")
                    if let _lastPage = self.totalPages.last {
                        _lastPage.alpha = 0
                        _lastPage.inQueue = false
                        _lastPage.transform = .identity
                        _lastPage.frame = _previousPage.frame
                        self.totalPages.insert(_lastPage, at: 0)
                        self.totalPages.removeLast()
                        if let _dataSource = self.dataSource {
                            let _prePage = _dataSource.hb_pageContent(self, index: self.preData(current: self.dataPosition))
                            self.totalPages[0] = _prePage
                            self.insertSubview(_prePage, aboveSubview: _previousPage)
                            UIView.animate(withDuration: self.animationDuration, animations: {
                                let rotate = CGAffineTransform.init(rotationAngle: -(CGFloat.pi / 12 * 1.2))
                                let move = CGAffineTransform.init(translationX: -(self.bounds.width * 1.2), y: 0)
                                _prePage.transform = rotate.concatenating(move)
                            }, completion: { (true) in
                                _prePage.alpha = 1
                                self.previousPage = _prePage
                                self.touchIn = false
                            })
                        }
                    }
                })
            }
        }else {
            self.touchIn = false
        }
    }
    
}

//MARK: - HBNewPageViewDelegate
extension HBNewBookView {
    public func pageTapped(page: HBNewPageView) {
        if let _currentPage = currentPage {
            if page == _currentPage {
                delegate?.hb_pageTapped(index: self.dataPosition)
            }
        }
    }
}

