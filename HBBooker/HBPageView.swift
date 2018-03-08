//
//  HBPageView.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit
import pop

public protocol HBPageViewDelegate : class {
    /// 页面移动比例
    func pageMoved(ratio: CGFloat, page: HBPageView) -> ()
    /// 页面本轮生命周期结束
    func pageRemoved(page: HBPageView) -> ()
}

open class HBPageView: UIView ,UIGestureRecognizerDelegate {
    
    open var reuseIdentifier : String?
    open var inQueue : Bool = true
    open var position : Int = 0
    
    public weak var delegate : HBPageViewDelegate?
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var dragDistance = CGPoint.zero
    private var rotationMax : CGFloat = 1.0
    private var scaleMin : CGFloat = 0.8
    private var rotationAngle = CGFloat(Double.pi) / 10.0
    private var animationDirectionY: CGFloat = 1.0
    internal var cardSwipeActionAnimationDuration: TimeInterval = HBDragSpeed.fast.rawValue
    fileprivate var xPositionRatio : CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: GestureRecognizers
extension HBPageView {
    @objc func panGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        dragDistance = gestureRecognizer.translation(in: self)
        let touchLocation = gestureRecognizer.location(in: self)
        switch gestureRecognizer.state {
        case .began:
            let firstTouchPoint = gestureRecognizer.location(in: self)
            let newAnchorPoint = CGPoint(x: firstTouchPoint.x / bounds.width, y: firstTouchPoint.y / bounds.height)
            let oldPosition = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
            let newPosition = CGPoint(x: bounds.size.width * newAnchorPoint.x, y: bounds.size.height * newAnchorPoint.y)
            layer.anchorPoint = newAnchorPoint
            layer.position = CGPoint(x: layer.position.x - oldPosition.x + newPosition.x, y: layer.position.y - oldPosition.y + newPosition.y)
            animationDirectionY = touchLocation.y >= frame.size.height / 2 ? -1.0 : 1.0
            layer.rasterizationScale = UIScreen.main.scale
            layer.pop_removeAllAnimations()
            layer.shouldRasterize = true
        case .changed:
            let rotationStrength = min(dragDistance.x / frame.width, rotationMax)
            let rotationAngle = animationDirectionY * self.rotationAngle * rotationStrength
            let scaleStrength = 1 - ((1 - scaleMin) * fabs(rotationStrength))
            let scale = max(scaleStrength, scaleMin)
            var transform = CATransform3DIdentity
            transform = CATransform3DScale(transform, scale, scale, 1)
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, dragDistance.x, dragDistance.y, 0)
            layer.transform = transform
            
            if let _delegate = delegate {
                xPositionRatio = abs(dragDistance.x) / (bounds.width / 2)
                _delegate.pageMoved(ratio: min(xPositionRatio, 1), page: self)
            }
        case .ended:
            gestureEnd()
            layer.shouldRasterize = false
        default:
            layer.shouldRasterize = false
        }
    }
}

//MARK: - Methods
extension HBPageView {
    func gestureEnd() -> () {
        let endPoint : CGPoint = CGPoint.init(x: center.x + dragDistance.x, y: center.y + dragDistance.y)
        //let distanceToXAxis : CGFloat = -(endPoint.y - center.y)
        //let distanceToYAxis : CGFloat = endPoint.x - center.x
        //let distanceBetweenP : CGFloat = CGFloat(sqrtf(Float(distanceToXAxis * distanceToXAxis + distanceToYAxis * distanceToYAxis)))
        //print("❤️ Base Position -> \(sin(CGFloat.pi/8))")
        //print("❤️ Real Position -> \(distanceToXAxis / distanceBetweenP)")
        var direction : HBDirection = HBDirection.left
        if endPoint.x - center.x > 0 {
            direction = .right
        }
        
        
        if xPositionRatio >= 1 {// end animation
            var endPoint : NSValue = NSValue.init()
            switch direction {
            case .left:
                endPoint = NSValue(cgPoint: CGPoint.init(x: -max(bounds.width, bounds.height) * 1.5, y: UIScreen.main.bounds.height))
                break
            case .right:
                endPoint = NSValue(cgPoint: CGPoint.init(x:  UIScreen.main.bounds.width + max(bounds.width, bounds.height) * 1.5, y: UIScreen.main.bounds.height))
                break
            }
            let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY)
            translationAnimation?.duration = cardSwipeActionAnimationDuration
            translationAnimation?.fromValue = NSValue(cgPoint: POPLayerGetTranslationXY(layer))
            translationAnimation?.toValue = endPoint//animationPointForDirection(direction))
            translationAnimation?.completionBlock = { _, _ in
                self.removeFromSuperview()
                if let _delegate = self.delegate {
                    _delegate.pageRemoved(page: self)
                }
            }
            layer.pop_add(translationAnimation, forKey: "swipeTranslationAnimation")
        }else {
            if let _delegate = delegate {
                _delegate.pageMoved(ratio: 0, page: self)
            }
            
            let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
            resetPositionAnimation?.fromValue = NSValue(cgPoint:POPLayerGetTranslationXY(layer))
            resetPositionAnimation?.toValue = NSValue(cgPoint: CGPoint.zero)
            resetPositionAnimation?.springBounciness = 10.0
            resetPositionAnimation?.springSpeed = 20.0
            resetPositionAnimation?.completionBlock = {
                (_, _) in
                self.layer.transform = CATransform3DIdentity
            }
            layer.pop_add(resetPositionAnimation, forKey: "resetPositionAnimation")
            
            let resetRotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
            resetRotationAnimation?.fromValue = POPLayerGetRotationZ(layer)//POPLayerGetRotation(layer)
            resetRotationAnimation?.toValue = CGFloat(0.0)
            resetRotationAnimation?.duration = HBPageParam.cardResetAnimationDuration
            layer.pop_add(resetRotationAnimation, forKey: "resetRotationAnimation")
            
            let resetScaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            resetScaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0))
            resetScaleAnimation?.duration = HBPageParam.cardResetAnimationDuration
            layer.pop_add(resetScaleAnimation, forKey: "resetScaleAnimation")
        }
    }
}
