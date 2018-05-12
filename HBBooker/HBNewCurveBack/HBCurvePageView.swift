//
//  HBCurvePageView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

public protocol HBCurvePageViewDelegate : class {
    /// 页面点击
    func pageTapped(page: HBCurvePageView) -> ()
    
    func pageBeginMove(page: HBCurvePageView,direction: HBCurveDirection?) -> ()
    
    func pageInMove(page: HBCurvePageView,ratio: CGFloat,direction: HBCurveDirection) -> ()
    
    func pageMoveDone(page: HBCurvePageView,ratio: CGFloat,direction: HBCurveDirection?) -> ()
}

open class HBCurvePageView: UIView ,UIGestureRecognizerDelegate {
    
    open var reuseIdentifier : String?
    open var inQueue : Bool = true
    open var position : Int = 0
    
    public weak var _delegate : HBCurvePageViewDelegate?
    fileprivate var panGesture: UIPanGestureRecognizer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        addGestureRecognizer(tapGestureRecognizer)
        
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(sender:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc func tap() -> () {
        _delegate?.pageTapped(page: self)
    }
    
    func panUnEnabled() -> () {
        panGesture.removeTarget(self, action: #selector(panGestureRecognized(sender:)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var firstTouchPoint : CGPoint = .zero
    fileprivate var direction : HBCurveDirection?
    fileprivate var moveRatio : CGFloat = 0
    fileprivate var rotationAngle : CGFloat = CGFloat.pi / 12
    fileprivate var largerestRatio : CGFloat = 1.3
}

extension HBCurvePageView {
    @objc func panGestureRecognized(sender: UIPanGestureRecognizer) -> () {
        switch sender.state {
        case .began:
            firstTouchPoint = sender.translation(in: UIApplication.shared.keyWindow)
            break
        case .changed:
            let secondTouchPoint = sender.translation(in: UIApplication.shared.keyWindow)
            if let _direction = direction {/// 如果有方向
                moveRatio = (firstTouchPoint.x - secondTouchPoint.x) / (bounds.width)
                var operateRatio : CGFloat = moveRatio
                
                switch _direction {
                case .left:
                    if operateRatio <= 0 {
                        operateRatio = 0
                    }
                    var transform = CATransform3DIdentity
                    transform = CATransform3DTranslate(transform, -(bounds.width * operateRatio), 0, 0)
                    transform = CATransform3DRotate(transform, -(rotationAngle * operateRatio), 0, 0, 1)
                    layer.transform = transform
                    break
                case .right:
                    
                    
                    break
                }
                _delegate?.pageInMove(page: self, ratio: moveRatio, direction: _direction)
            }else {/// 如果没有方向
                if secondTouchPoint.x > firstTouchPoint.x {
                    direction = .right
                }else {
                    direction = .left
                }
                
                _delegate?.pageBeginMove(page: self,direction: direction)
            }
            break
        case .cancelled,.ended,.failed:
            let secondTouchPoint = sender.translation(in: UIApplication.shared.keyWindow)
            moveRatio = (firstTouchPoint.x - secondTouchPoint.x) / (bounds.width / 2)
            
            if let _direction = direction {
                switch _direction {
                case .left:
                    if moveRatio >= 0.5 {
                        moveRatio = largerestRatio
                    }else {
                        moveRatio = 0
                    }
                    
                    if moveRatio == largerestRatio {
                        UIView.animate(withDuration: 0.05, animations: {
                            var transform = CATransform3DIdentity
                            transform = CATransform3DTranslate(transform, -(self.bounds.width * self.moveRatio), 0, 0)
                            transform = CATransform3DRotate(transform, -(self.rotationAngle * self.moveRatio), 0, 0, 1)
                            self.layer.transform = transform
                        }, completion: { (true) in
                        })
                        self._delegate?.pageMoveDone(page: self, ratio: self.moveRatio, direction: self.direction)
                        self.direction = nil
                    }else {
                        UIView.animate(withDuration: 0.05, animations: {
                            self.layer.transform = CATransform3DIdentity
                        }, completion: { (true) in
                        })
                        self._delegate?.pageMoveDone(page: self, ratio: self.moveRatio, direction: self.direction)
                        self.direction = nil
                    }
                    break
                case .right:
                    self._delegate?.pageMoveDone(page: self, ratio: self.moveRatio, direction: self.direction)
                    self.direction = nil
                    break
                }
            }else {
                self.direction = nil
            }
            break
        default:
            
            break
        }
    }
}
