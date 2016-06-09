//
//  AnimationView.swift
//  StrokeAnimation
//
//  Created by Sun Peng on 16/6/9.
//  Copyright © 2016年 Void Main. All rights reserved.
//
import UIKit

enum AnimationState {
    case Magnifier
    case Back

    func nextState() -> AnimationState {
        return self == .Magnifier ? .Back : .Magnifier
    }
}

let magnifierColor: CGColor = UIColor.lightGrayColor().CGColor
let magnifierFillColor: CGColor = UIColor.clearColor().CGColor

// 设置线宽
let magnifierLineWidth: CGFloat = 1

let animationDuration: CFTimeInterval = 1

class AnimationView: UIView {

    // 用于根据半径计算xy坐标偏移量
    let ratio: CGFloat = CGFloat(sqrt(2) * 0.5)

    // 用于设置放大镜有多大
    var magnifierRadius: CGFloat

    let wrapperLayer: CALayer
    let magnifierLayerTop: CAShapeLayer
    let magnifierLayerBottom: CAShapeLayer
    let magnifierHandle: CAShapeLayer
    let backTopLine: CAShapeLayer
    let backBottomLine: CAShapeLayer

    var state: AnimationState

    required init?(coder aDecoder: NSCoder) {
        state = .Magnifier

        magnifierRadius = 0

        wrapperLayer = CALayer()
        magnifierLayerTop = CAShapeLayer()
        magnifierLayerBottom = CAShapeLayer()
        magnifierHandle = CAShapeLayer()
        backTopLine = CAShapeLayer()
        backBottomLine = CAShapeLayer()

        super.init(coder: aDecoder)

        self.wrapperLayer.addSublayer(magnifierLayerTop)
        self.wrapperLayer.addSublayer(magnifierLayerBottom)
        self.wrapperLayer.addSublayer(magnifierHandle)
        self.wrapperLayer.addSublayer(backTopLine)
        self.wrapperLayer.addSublayer(backBottomLine)

        self.layer.addSublayer(wrapperLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = self.frame
        updateConfigSize(frame)
        setupLayersWithFrame(frame)
    }

    func updateConfigSize(frame: CGRect) {
        let size = min(frame.size.width, frame.size.height)
        self.magnifierRadius = size * 0.25
    }

    func setupLayersWithFrame(frame: CGRect) {
        let centerX = frame.size.width * 0.5
        let centerY = frame.size.height * 0.5
        let backStartPoint = CGPointMake(centerX, centerY)
        let magnifierCircleCenter = CGPointMake(centerX - magnifierRadius * ratio, centerY - magnifierRadius * ratio)

        switch state {
        case .Magnifier:
            setupCircleLayer(magnifierLayerTop,
                             center: magnifierCircleCenter,
                             radius: magnifierRadius,
                             startAngle: 5 * CGFloat(M_PI_4),
                             endAngle: CGFloat(M_PI_4),
                             strokeStart: 0,
                             strokeEnd: 1)
            setupCircleLayer(magnifierLayerBottom,
                             center: magnifierCircleCenter,
                             radius: magnifierRadius,
                             startAngle: CGFloat(M_PI_4),
                             endAngle: 5 * CGFloat(M_PI_4),
                             strokeStart: 0,
                             strokeEnd: 1)

            setupLineLayer(magnifierHandle,
                           length: magnifierRadius * 2,
                           rotation: CGFloat(M_PI_4),
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 1)
            setupLineLayer(backTopLine,
                           length: magnifierRadius / ratio,
                           rotation: 7 * CGFloat(M_PI_4),
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 0)
            setupLineLayer(backBottomLine,
                           length: magnifierRadius / ratio,
                           rotation: CGFloat(M_PI_4),
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 0)
            return
        default:
            setupCircleLayer(magnifierLayerTop,
                             center: magnifierCircleCenter,
                             radius: magnifierRadius,
                             startAngle: 5 * CGFloat(M_PI_4),
                             endAngle: CGFloat(M_PI_4),
                             strokeStart: 1,
                             strokeEnd: 1)
            setupCircleLayer(magnifierLayerBottom,
                             center: magnifierCircleCenter,
                             radius: magnifierRadius,
                             startAngle: CGFloat(M_PI_4),
                             endAngle: 5 * CGFloat(M_PI_4),
                             strokeStart: 0,
                             strokeEnd: 0)

            setupLineLayer(magnifierHandle,
                           length: magnifierRadius * 2,
                           rotation: 0,
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 1)
            setupLineLayer(backTopLine,
                           length: magnifierRadius / ratio,
                           rotation: 7 * CGFloat(M_PI_4),
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 1)
            setupLineLayer(backBottomLine,
                           length: magnifierRadius / ratio,
                           rotation: CGFloat(M_PI_4),
                           startPoint: backStartPoint,
                           strokeStart: 0,
                           strokeEnd: 1)
            return
        }
    }

    func setupCircleLayer(layer: CAShapeLayer, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, strokeStart: CGFloat = 0, strokeEnd: CGFloat = 1, lineWidth: CGFloat = magnifierLineWidth, strokeColor: CGColor = magnifierColor) {
        layer.path = UIBezierPath(arcCenter: center,
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true).CGPath
        layer.lineWidth = lineWidth
        layer.strokeColor = strokeColor
        layer.fillColor = nil
        layer.strokeStart = strokeStart
        layer.strokeEnd = strokeEnd
    }

    func setupLineLayer(layer: CAShapeLayer, length: CGFloat, rotation: CGFloat, startPoint: CGPoint, strokeStart: CGFloat, strokeEnd: CGFloat, strokeColor: CGColor = magnifierColor) {
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPointMake(0, 0))
        linePath.addLineToPoint(CGPointMake(length, 0))
        layer.path = linePath.CGPath
        layer.fillColor = nil
        layer.strokeColor = strokeColor
        layer.setAffineTransform(CGAffineTransformMakeRotation(rotation))
        layer.position = startPoint
        layer.strokeStart = strokeStart
        layer.strokeEnd = strokeEnd
    }

    func animatePartTo(part: CAShapeLayer, startFrom: CGFloat, startTo: CGFloat, endFrom: CGFloat, endTo: CGFloat, rotationStart: CGFloat? = nil, rotationEnd: CGFloat? = nil, translationStart: CGFloat? = nil, translationEnd: CGFloat? = nil) {
        part.strokeStart = startFrom
        part.strokeEnd = endFrom

        let anims: NSMutableArray = []

        let start = CABasicAnimation(keyPath: "strokeStart")
        start.fromValue = startFrom
        start.toValue = startTo
        start.fillMode = kCAFillModeForwards
        start.removedOnCompletion = false
        anims.addObject(start)

        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = endFrom
        end.toValue = endTo
        end.fillMode = kCAFillModeForwards
        start.removedOnCompletion = false
        anims.addObject(end)

        let group = CAAnimationGroup()
        group.animations = anims as NSArray as? [CAAnimation]
        group.duration = animationDuration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        group.fillMode = kCAFillModeForwards
        group.removedOnCompletion = false

        part.addAnimation(group, forKey: nil)
    }

    func animatePartRotation(part: CAShapeLayer, rotationStart: CGFloat, rotationEnd: CGFloat) {
        part.setAffineTransform(CGAffineTransformMakeRotation(rotationStart))

        let anims: NSMutableArray = []

        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = rotationStart
        anim.toValue = rotationEnd
        anim.fillMode = kCAFillModeForwards
        anim.removedOnCompletion = false
        anims.addObject(anim)

        let group = CAAnimationGroup()
        group.animations = anims as NSArray as? [CAAnimation]
        group.duration = animationDuration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.fillMode = kCAFillModeForwards
        group.removedOnCompletion = false

        part.addAnimation(group, forKey: nil)
    }

    func animateToState(state: AnimationState) {
        self.state = state

        CATransaction.begin()
        CATransaction.setCompletionBlock { 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.animateToState(self.state.nextState())
            })
        }

        switch state {
        case .Magnifier:
            animatePartTo(magnifierLayerTop, startFrom: 1.0, startTo: 0.0, endFrom: 1.0, endTo: 1.0)
            animatePartTo(magnifierLayerBottom, startFrom: 0.0, startTo: 0.0, endFrom: 0.0, endTo: 1.0)
            animatePartRotation(magnifierHandle, rotationStart: 0, rotationEnd: CGFloat(M_PI_4))
            animatePartTo(backTopLine, startFrom: 0.0, startTo: 0.0, endFrom: 1.0, endTo: 0.0)
            animatePartTo(backBottomLine, startFrom: 0.0, startTo: 0.0, endFrom: 1.0, endTo: 0.0)
        case .Back:
            animatePartTo(magnifierLayerTop, startFrom: 0.0, startTo: 1.0, endFrom: 1.0, endTo: 1.0)
            animatePartTo(magnifierLayerBottom, startFrom: 0.0, startTo: 0.0, endFrom: 1.0, endTo: 0.0)
            animatePartRotation(magnifierHandle, rotationStart: CGFloat(M_PI_4), rotationEnd: 0)
            animatePartTo(backTopLine, startFrom: 0.0, startTo: 0.0, endFrom: 0.0, endTo: 1.0)
            animatePartTo(backBottomLine, startFrom: 0.0, startTo: 0.0, endFrom: 0.0, endTo: 1.0)
        }

        CATransaction.commit()
    }
}
