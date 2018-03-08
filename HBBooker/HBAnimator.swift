//
//  HBAnimator.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/7.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

enum KLClassAnchorType {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    
    var point : CGPoint {
        switch self {
        case .topLeft:
            return CGPoint.init(x: 0, y: 0)
        case .topCenter:
            return CGPoint.init(x: 0.5, y: 0)
        case .topRight:
            return CGPoint.init(x: 1, y: 0)
        case .centerLeft:
            return CGPoint.init(x: 0, y: 0.5)
        case .center:
            return CGPoint.init(x: 0.5, y: 0.5)
        case .centerRight:
            return CGPoint.init(x: 1, y: 0.5)
        case .bottomLeft:
            return CGPoint.init(x: 0, y: 1)
        case .bottomCenter:
            return CGPoint.init(x: 0.5, y: 1)
        case .bottomRight:
            return CGPoint.init(x: 1, y: 1)
        }
    }
    
}
class HBAnimator: NSObject, CAAnimationDelegate {
    open var animBeginHandler : ((_ anim: CAAnimation) -> ())?
    open var animEndHandler : ((_ anim: CAAnimation,_ flag: Bool,_ hold: UIView?) -> ())?
    weak fileprivate var hold = UIView()
    //static let instance = KLClassAnimManager()
    /** Circle Enlarge
     */
    func circleTransform(next:UIView ,
                         frame:CGRect ,
                         kIfSetDelegate:Bool = true,
                         duration:TimeInterval = 2) -> () {
        let startFrame = CGRect.init(x: (frame.width - 5) / 2, y: (frame.height - 5) / 2, width: 5, height: 5)
        let startCircle = UIBezierPath.init(ovalIn: startFrame)
        let radius = sqrtf(Float(pow(frame.width, 2) + pow(frame.height, 2)))
        
        let endCircle = UIBezierPath.init(arcCenter: CGPoint.init(x: frame.width / 2, y: frame.height / 2), radius: CGFloat(radius / 2), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endCircle.cgPath
        next.layer.mask = maskLayer
        
        let maskAnimation = CABasicAnimation.init(keyPath: "path")
        maskAnimation.fromValue = startCircle.cgPath
        maskAnimation.toValue = endCircle.cgPath
        maskAnimation.duration = duration
        if kIfSetDelegate {
            maskAnimation.delegate = self
        }
        maskAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskLayer.add(maskAnimation, forKey: "amplifyAnimation")
    }
    
    /** Circle Shrink
     */
    func circleTransform(pre:UIView ,
                         frame:CGRect ,
                         kIfSetDelegate:Bool = true,
                         duration:TimeInterval = 2) -> () {
        let startFrame = CGRect.init(x: (frame.width - 5) / 2, y: (frame.height - 5) / 2, width: 5, height: 5)
        let radius = sqrtf(Float(pow(frame.width, 2) + pow(frame.height, 2)))
        let startCircle = UIBezierPath.init(arcCenter: CGPoint.init(x: frame.width / 2, y: frame.height / 2), radius: CGFloat(radius / 2), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let endCircle = UIBezierPath.init(ovalIn: startFrame)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endCircle.cgPath
        pre.layer.mask = maskLayer
        
        let maskAnimation = CABasicAnimation.init(keyPath: "path")
        maskAnimation.fromValue = startCircle.cgPath
        maskAnimation.toValue = endCircle.cgPath
        maskAnimation.duration = duration
        if kIfSetDelegate {
            maskAnimation.delegate = self
        }
        maskAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskLayer.add(maskAnimation, forKey: "shrinkAnimation")
    }
    
    /** Move Layer
     */
    func move(hold:UIView,
              from:CGPoint,
              to:CGPoint,
              duration:TimeInterval = 5,
              max:Float,
              fillMode:String = kCAFillModeForwards,
              isRemovedOnCompletion:Bool = false,
              kIfSetDelegate:Bool = true,
              timing:CAMediaTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)) -> () {
        self.hold = hold
        let anim = CABasicAnimation.init(keyPath: "position")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = duration
        anim.repeatCount = max
        anim.beginTime = CACurrentMediaTime()
        anim.timingFunction = timing
        if kIfSetDelegate {
            anim.delegate = self
        }
        anim.fillMode = fillMode
        anim.isRemovedOnCompletion = isRemovedOnCompletion
        hold.layer.add(anim, forKey: "move-layer")
    }
    
    /** Shake Layer according to layer's position and anchorPoint
     */
    func opacity(layer:CALayer,
                 values:[CGFloat] = [1,0],
                 autoreverses:Bool = true,
                 duration:TimeInterval = 2.5,
                 max:Float,
                 fillMode:String = kCAFillModeForwards,
                 isRemovedOnCompletion:Bool = false,
                 kIfSetDelegate:Bool = true,
                 timing:CAMediaTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)) -> () {
        let anim = CAKeyframeAnimation.init(keyPath: "opacity")
        anim.values = values
        anim.duration = duration
        anim.autoreverses = autoreverses
        anim.repeatCount = max
        anim.beginTime = CACurrentMediaTime()
        anim.timingFunction = timing
        anim.fillMode = fillMode
        anim.isRemovedOnCompletion = isRemovedOnCompletion
        if kIfSetDelegate {
            anim.delegate = self
        }
        layer.add(anim, forKey: "shake-layer")
    }
    
    /** Shake Layer according to layer's position and anchorPoint
     */
    func shake(layer:CALayer,
               values:[CGFloat] = [0.01,-0.03,0.03,-0.01],
               duration:TimeInterval = 5,
               max:Float,
               anchorType:KLClassAnchorType = .center,
               position:CGPoint,
               fillMode:String = kCAFillModeForwards,
               isRemovedOnCompletion:Bool = false,
               kIfSetDelegate:Bool = true,
               timing:CAMediaTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)) -> () {
        let anim = CAKeyframeAnimation.init(keyPath: "transform.rotation.z")
        anim.values = values
        anim.duration = duration
        anim.autoreverses = true
        anim.repeatCount = max
        anim.beginTime = CACurrentMediaTime()
        anim.timingFunction = timing
        anim.fillMode = fillMode
        anim.isRemovedOnCompletion = isRemovedOnCompletion
        if kIfSetDelegate {
            anim.delegate = self
        }
        layer.anchorPoint = anchorType.point
        layer.position = position
        layer.add(anim, forKey: "shake-layer")
    }
    
    /** Shrink or enlarge Layer's scale
     */
    func scale(layer:CALayer,
               values:[CGFloat] = [1.04,1,1.04,1],
               duration:TimeInterval = 5,
               max:Float,
               fillMode:String = kCAFillModeForwards,
               isRemovedOnCompletion:Bool = false,
               kIfSetDelegate:Bool = true,
               timing:CAMediaTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)) -> () {
        let anim = CAKeyframeAnimation.init(keyPath: "transform.scale.x")
        anim.values = [1.04,1,1.04,1]
        anim.duration = duration
        anim.autoreverses = true
        anim.repeatCount = max
        anim.beginTime = CACurrentMediaTime()
        anim.timingFunction = timing
        anim.fillMode = fillMode
        anim.isRemovedOnCompletion = isRemovedOnCompletion
        if kIfSetDelegate {
            anim.delegate = self
        }
        layer.add(anim, forKey: "scale-layer")
    }
    
    /** 合成图片
     */
    func mixImageBy(images:[String]) -> UIImage? {
        for i in 0 ..< images.count {
            let imageString = images[i]
            if let image = UIImage.init(named: imageString) {
                if i == 0 {
                    UIGraphicsBeginImageContext(image.size)
                }
                image.draw(in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
   
}

extension HBAnimator {
    func animationDidStart(_ anim: CAAnimation) {
        self.animBeginHandler?(anim)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animEndHandler?(anim,flag,hold)
    }
}

