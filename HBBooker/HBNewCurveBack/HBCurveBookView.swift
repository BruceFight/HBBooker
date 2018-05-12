//
//  HBCurveBookView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

/// 方向
public enum HBCurveDirection {
    case left
    case right
}

public protocol HBCurveBookViewDelegate : class {
    /// 点击某页
    func hb_pageTapped(index: Int,page: HBCurvePageView) -> ()
    /// 页面翻到了(index位置)
    func hb_pageTo(index: Int,page: HBCurvePageView?) -> ()
    /// 页面移动
    func hb_pageMoved(ratio: CGFloat,direction: HBCurveDirection,page: HBCurvePageView?) -> ()
    
    func hb_pageFlyDone() -> ()
}

public protocol HBCurveBookViewDataSource : class {
    /// 页面数量
    func hb_pageNumber(_ bookView: HBCurveBookView) -> Int
    /// 页面内容
    func hb_pageContent(_ bookView: HBCurveBookView, index: Int) -> HBCurvePageView
}

open class HBCurveBookView: UIView, HBCurvePageViewDelegate, UIGestureRecognizerDelegate {
    
    public weak var delegate_: HBCurveBookViewDelegate?
    public weak var dataSource: HBCurveBookViewDataSource?

    /// 需要展示的最大数目
    var totalPageNumber : Int = 0
    /// 所有的Page
    var totalPages : [HBCurvePageView] = []
    /// 最大可见总数
    var visibleNumber : Int = 3
    /// 重用标识
    var reuseIdentifier : String = ""
    /// 页-页差
    var pageMargin : CGFloat = 15
    /// (Data)当前位置
    var dataPosition : Int = 0
    /// (Page)当前位置 <<<暂时无用>>>
    var pagePosition : Int = 0
    
    var flyDone: (() -> ())?
    fileprivate var largerestRatio : CGFloat = 1.3
    
    private var PageClass : AnyClass?
    typealias RemoveDone = ((_ ifDone: Bool) -> ())?
    fileprivate var animationDuration : TimeInterval = 0.2
    fileprivate var rotationAngle : CGFloat = CGFloat.pi / 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var direction : HBCurveDirection?
    var currentPage : HBCurvePageView?
    fileprivate var moveRatio : CGFloat = 0
    fileprivate var previousPage : HBCurvePageView?
    fileprivate var touchIn : Bool = false
}


//MARK: - Methods
extension HBCurveBookView {
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
            if let pageView = PageClass.self as? HBCurvePageView.Type {
                for i in 0 ..< needNumber {
                    let page = pageView.init()
                    page._delegate = self
                    page.inQueue = false
                    if needNumber == 1 {
                        page.panUnEnabled()
                    }
                    page.reuseIdentifier = reuseIdentifier
                    if totalPageNumber >= visibleNumber {
                        if i == visibleNumber {
                            //page.alpha = 0
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
            
            currentPage = totalPages.first
            
            var position : Int = dataPosition
            for i in 0 ..< totalPages.count {
                let _getDataPage = _dataSource.hb_pageContent(self, index: position)
                totalPages[i] = _getDataPage
                position = nextData(current: position)
            }
            
            if dataPosition > 0 && dataPosition < totalPageNumber {
                if let _lastPage = totalPages.last {
                    previousPage = _lastPage
                    setFaceFrame(page: _lastPage)
                    var transform = CATransform3DIdentity
                    transform = CATransform3DTranslate(transform, -(bounds.width * largerestRatio), 0, 0)
                    transform = CATransform3DRotate(transform, -(rotationAngle * largerestRatio), 0, 0, 1)
                    _lastPage.layer.transform = transform
                    totalPages.insert(_lastPage, at: 0)
                    totalPages.removeLast()
                    setPageAgain(page: _lastPage, position: preData(current: dataPosition))
                }
            }
        }
    }
    
    func setPageAgain(page: HBCurvePageView, position: Int) -> () {
        if let _index = totalPages.index(of: page) {
            page.inQueue = false
            if let _dataSource = dataSource {
                let newPage = _dataSource.hb_pageContent(self, index: position)
                totalPages[_index] = newPage
            }
        }
    }
    
    /// page remove
    func pageRemove(removedPage: HBCurvePageView) -> () {
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
    func setPageFrame(page: HBCurvePageView, index: CGFloat) -> () {
        let _width : CGFloat = bounds.width - 2 * index * pageMargin
        let _height : CGFloat = bounds.height - CGFloat(visibleNumber - 1) * pageMargin
        page.layer.transform = CATransform3DIdentity
        page.frame = CGRect.init(x: index * self.pageMargin, y: index * self.pageMargin, width: _width, height: _height)
    }
    
    /// Create Page
    func createPage(withIdentifier: String, inQueue: Bool) -> HBCurvePageView {
        let page = HBCurvePageView()
        page._delegate = self
        page.reuseIdentifier = withIdentifier
        page.inQueue = inQueue
        return page
    }
    
    /// setTransform
    func setTransform(page: UIView,angle: CGFloat,transX: CGFloat,transY: CGFloat = 1,scale: CGFloat = 1) -> () {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, transX, transY, 0)
        transform = CATransform3DRotate(transform, angle, 0, 0, 1)
        transform = CATransform3DScale(transform, scale, scale, 1)
        page.layer.transform = transform
    }
    
    /// 下一页(数据)
    fileprivate func nextData(current: NSInteger) -> NSInteger {
        let total = self.totalPageNumber
        if total > 0 {
            return (current + 1) % total //队列指针+1
        }
        return 0
    }
    
    /// 上一页(数据)
    fileprivate func preData(current: NSInteger) -> NSInteger {
        let total = self.totalPageNumber
        if total > 0 {
            return (current - 1 + total) % total // 队列指针-1
        }
        return 0
    }
    
    /// 下一页(Page)
    fileprivate func nextPage(current: NSInteger) -> NSInteger {
        let total = self.totalPages.count
        if total > 0 {
            return (current + 1) % total //队列指针+1
        }
        return 0
    }
    
    /// 上一页(Page)
    fileprivate func prePage(current: NSInteger) -> NSInteger {
        let total = self.totalPages.count
        if total > 0 {
            return (current - 1 + total) % total // 队列指针-1
        }
        return 0
    }
}

//MARK: - Methods For Outer
extension HBCurveBookView {
    /// reloadData
    func reloadData() -> () {
        if let _dataSource = dataSource {
            let totalNumber = _dataSource.hb_pageNumber(self)
            if totalNumber <= 0 {
                return
            }
        }
        if self.totalPages.count > 0 || self.totalPageNumber > 0 {
            return
        }
        
        if let _PageClass = PageClass {
            self.register(pageClass: _PageClass, reuseIdentifier: reuseIdentifier)
        }
    }
    
    /// realoda item (默认刷新当前页)
    func reload(item: Int) -> () {
        if let _dataSource = dataSource {
            let totalNumber = _dataSource.hb_pageNumber(self)
            if item > totalNumber || item < 0 || item != dataPosition {
                return
            }
            
            reloadPage(item: item, page: currentPage)
        }
    }
    
    /// item: 数据源索引; page: 对应的页
    func reloadPage(item: Int,page: HBCurvePageView?) -> () {
        if let _dataSource = dataSource {
            for i in 0 ..< totalPages.count {
                let _page = totalPages[i]
                if _page == page {
                    _page.inQueue = false
                    let _newPage = _dataSource.hb_pageContent(self, index: item)
                    totalPages[i] = _newPage
                    break
                }
            }
        }
    }
    
    /// 刷新下一页
    func reloadNextPage(current: Int) -> () {
        var currentPageIndex : Int = 0
        if let _dataSource = dataSource ,
            let _currentPage = currentPage {
            for i in 0 ..< totalPages.count {
                let _page = totalPages[i]
                if _page == _currentPage {
                    currentPageIndex = i
                    break
                }
            }
            
            let nextPageIndex = nextPage(current: currentPageIndex)
            let nextDataPosition = nextData(current: current)
            if let _nextPage = totalPages.hb_object(for: nextPageIndex) {
                _nextPage.inQueue = false
                let _newNextPage = _dataSource.hb_pageContent(self, index: nextDataPosition)
                totalPages[nextPageIndex] = _newNextPage
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
    func dequeueReusablePage(withIdentifier: String, index: Int) -> HBCurvePageView? {
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
    func pageFly(done: ((_ position: Int) -> (Bool))?) -> () {
        if let _currentPage = currentPage {
            if self.totalPageNumber <= 0 { return }
            if self.totalPageNumber != 1 {
                if let _pre = previousPage {
                    reloadPage(item: self.preData(current: self.dataPosition), page: _pre)
                }
                if let _currentPage = currentPage {
                    for i in 0 ..< totalPages.count {
                        let page = totalPages[i]
                        if page == _currentPage {
                            reloadPage(item: self.nextData(current: self.dataPosition), page: totalPages[self.nextPage(current: i)])
                            break
                        }
                    }
                }
            }
            
            if self.touchIn == false {            
                self.touchIn = true
                if previousPage == currentPage {
                    UIView.animate(withDuration: animationDuration, animations: {
                        //self.setTransform(page: _currentPage, angle: 0, transX: 0, transY: 0)
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
    func fly(_currentPage: HBCurvePageView,done: ((_ position: Int) -> (Bool))?) -> () {
        UIView.animate(withDuration: animationDuration, animations: {
            //self.setTransform(page: _currentPage, angle: self.rotationAngle, transX: self.bounds.width, transY: -UIScreen.main.bounds.height)
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
    func removeDoneOperation(nextIndex: Int, _currentPage: HBCurvePageView) -> () {
        /// >= 4
        if self.totalPageNumber >= self.visibleNumber + 1 {
            self.totalPages.append(_currentPage)
            if let _dataSource = self.dataSource {
                /// 有前一页
                let lastPosition : Int = self.nextData(current: self.nextData(current: self.dataPosition))
                var page = HBCurvePageView()
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
                    self.delegate_?.hb_pageFlyDone()
                })
            }
        }else {
            _currentPage.removeFromSuperview()
            if self.totalPageNumber == 1 {
                if let _previousPage = self.previousPage {
                    UIView.animate(withDuration: animationDuration, animations: {
                        //self.setTransform(page: _previousPage, angle: 0, transX: 0, transY: 0)
                    }, completion: { (true) in
                        self.currentPage = _previousPage
                        self.touchIn = false
                        self.delegate_?.hb_pageFlyDone()
                    })
                }else {
                    if let _firstPage = self.totalPages.first {
                        self.currentPage = _firstPage
                    }
                    self.touchIn = false
                    self.delegate_?.hb_pageFlyDone()
                }
            }else {
                if let _nextPage = self.totalPages.hb_object(for: nextIndex) {
                    self.currentPage = _nextPage
                }
                self.touchIn = false
                self.delegate_?.hb_pageFlyDone()
            }
        }
    }
}

//MARK: - HBCurvePageViewDelegate
extension HBCurveBookView {
    func prePage() -> HBCurvePageView {
        if let _prePage = previousPage {
            return _prePage
        }
        return HBCurvePageView()
    }
    
    public func pageTapped(page: HBCurvePageView) {
        if let _currentPage = currentPage {
            if page == _currentPage {
                delegate_?.hb_pageTapped(index: self.dataPosition,page: page)
            }
        }
    }
    
    public func pageBeginMove(page: HBCurvePageView,direction: HBCurveDirection?) {
        if let _direction = direction {
            switch _direction {
            case .left:
                if let _prePage = previousPage {
                    insertSubview(_prePage, at: 0)
                }
                break
            case .right:
                if let _prePage = previousPage {
                    _prePage.alpha = 1
                    bringSubview(toFront: _prePage)
                }
                break
            }
        }
    }
    
    public func pageInMove(page: HBCurvePageView,ratio: CGFloat,direction: HBCurveDirection) -> () {
        switch direction {
        case .left:
            var operateRatio : CGFloat = ratio
            if operateRatio <= 0 {
                operateRatio = 0
            }
            var index : Int = 0
            if let _index = totalPages.index(of: page) {
                if _index == 0 {
                    index = 0
                }else {
                    index = -1
                }
            }
            for i in (0 ..< totalPages.count).reversed() {
                let index : CGFloat = CGFloat(i + index) - operateRatio
                let _page = totalPages[i]
                if page != _page && prePage() != _page {
                    setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                }
            }
            break
        case .right:
            if let _prePage = previousPage {
                var transform = CATransform3DIdentity
                transform = CATransform3DTranslate(transform, -(_prePage.bounds.width * (1 + ratio)), 0, 0)
                transform = CATransform3DRotate(transform, -(rotationAngle * (1 + ratio)), 0, 0, 1)
                _prePage.layer.transform = transform
                for i in (0 ..< totalPages.count).reversed() {
                    let index : CGFloat = CGFloat(i) - (1 + ratio)
                    let _page = totalPages[i]
                    if _prePage != _page {
                        setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                    }
                }
            }
            break
        }
    }
    
    public func pageMoveDone(page: HBCurvePageView,ratio: CGFloat,direction: HBCurveDirection?) -> () {
        if let _direction = direction {
            switch _direction {
            case .left:
                if ratio == largerestRatio {
                    dataPosition = nextData(current: dataPosition)
                    print("❤️dataPosition --> \(dataPosition)")
                    
                    if let _prePage = previousPage {
                        setFaceFrame(page: _prePage)
                        _prePage.layer.transform = CATransform3DIdentity
                        totalPages.append(_prePage)
                        totalPages.removeFirst()
                    }
                    
                    for i in (0 ..< totalPages.count).reversed() {
                        let index : CGFloat = CGFloat(i - 1)
                        let _page = totalPages[i]
                        if page != _page {
                            setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                        }
                    }
                    previousPage = page
                    if let secondPage = totalPages.hb_object(for: 1) {
                        currentPage = secondPage
                    }
                }else {
                    for i in (0 ..< totalPages.count).reversed() {
                        let index : CGFloat = CGFloat(i - 1)
                        let _page = totalPages[i]
                        if prePage() != _page {
                            setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                        }
                    }
                }
                
                let nextDataPosition = nextData(current: dataPosition)
                if let _currentPage = currentPage {
                    if let _currentIndex = totalPages.index(of: _currentPage) {
                        let _nextIndex = nextPage(current: _currentIndex)
                        if let _nextPage = totalPages.hb_object(for: _nextIndex) {
                            _nextPage.inQueue = false
                            if let _dataSource = dataSource {
                                let _newNextPage = _dataSource.hb_pageContent(self, index: nextDataPosition)
                                totalPages[_nextIndex] = _newNextPage
                            }
                        }
                    }
                }
                
                break
            case .right:
                var operateRatio : CGFloat = ratio
                if operateRatio >= -0.5 {
                    operateRatio = -1
                }else {
                    operateRatio = 0
                }
                
                if operateRatio == -1 {
                    if let _prePage = previousPage {
                        UIView.animate(withDuration: 0.05, animations: {
                            var transform = CATransform3DIdentity
                            transform = CATransform3DTranslate(transform, -(self.bounds.width * self.largerestRatio), 0, 0)
                            transform = CATransform3DRotate(transform, -(self.rotationAngle * self.largerestRatio), 0, 0, 1)
                            _prePage.layer.transform = transform
                        }, completion: { (true) in
                            
                        })
                        for i in (0 ..< totalPages.count).reversed() {
                            let index : CGFloat = CGFloat(i) + operateRatio
                            let _page = totalPages[i]
                            if _page != prePage() {
                                setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                            }
                        }
                    }
                }else {
                    if let _prePage = previousPage {
                        currentPage = _prePage
                        dataPosition = preData(current: dataPosition)
                        print("❤️dataPosition --> \(dataPosition)")
                        UIView.animate(withDuration: 0.05, animations: {
                            _prePage.layer.transform = CATransform3DIdentity
                            self.setFaceFrame(page: _prePage)
                        }, completion: { (true) in
                            
                        })
                        for i in (0 ..< totalPages.count).reversed() {
                            let index : CGFloat = CGFloat(i) - operateRatio
                            let _page = totalPages[i]
                            setPageFrame(page: _page, index: CGFloat(max(index, 0)))
                        }
                        
                        if let _lastPage = totalPages.last {
                            setFaceFrame(page: _lastPage)
                            var transform = CATransform3DIdentity
                            transform = CATransform3DTranslate(transform, -(bounds.width * largerestRatio), 0, 0)
                            transform = CATransform3DRotate(transform, -(rotationAngle * largerestRatio), 0, 0, 1)
                            _lastPage.layer.transform = transform
                            totalPages.insert(_lastPage, at: 0)
                            totalPages.removeLast()
                            previousPage = _lastPage
                        }
                        
                        let preDataPosition = preData(current: dataPosition)
                        if let _currentPage = currentPage {
                            if let _currentIndex = totalPages.index(of: _currentPage) {
                                let _preIndex = prePage(current: _currentIndex)
                                if let _prePage = totalPages.hb_object(for: _preIndex) {
                                    _prePage.inQueue = false
                                    if let _dataSource = dataSource {
                                        let _preNextPage = _dataSource.hb_pageContent(self, index: preDataPosition)
                                        totalPages[_preIndex] = _preNextPage
                                    }
                                }
                            }
                        }
                    }
                }
                break
            }
        }
    }
    
    func setFaceFrame(page: HBCurvePageView) -> () {
        let _width : CGFloat = bounds.width - 2 * CGFloat(visibleNumber - 1) * pageMargin
        let _height : CGFloat = bounds.height - CGFloat(visibleNumber - 1) * pageMargin
        page.frame = CGRect.init(x: CGFloat(visibleNumber - 1) * self.pageMargin, y: CGFloat(visibleNumber - 1) * self.pageMargin, width: _width, height: _height)
    }
}
