//
//  ViewExtension.swift
//  Dandy
//
//  Created by Evan Gruère on 27/04/2016.
//  Copyright © 2016 Evan Gruère. All rights reserved.
//

import UIKit


@IBDesignable
class Border: CALayer {
    var width: CGFloat = 0
    var color: UIColor = UIColor.blackColor() {
        didSet {
            self.backgroundColor = self.color.CGColor
        }
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    init(width: CGFloat = 0, color: UIColor = UIColor.clearColor()) {
        super.init()
        self.width = width
        self.backgroundColor = color.CGColor
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Border(width: self.width, color: self.color)
        return copy
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@IBDesignable
class BorderSet: CALayer {
    
    var padding = UIEdgeInsets()
    
    var radius: CGFloat = 0 {
        didSet {
            self.topLeftRadius      = self.radius
            self.topRightRadius     = self.radius
            self.bottomLeftRadius   = self.radius
            self.bottomRightRadius  = self.radius
        }
    }
    
    var width: CGFloat = 0 {
        didSet {
            self.top.width      = self.width
            self.right.width    = self.width
            self.bottom.width   = self.width
            self.left.width     = self.width
        }
    }
    
    var topLeftRadius:      CGFloat = 0
    var topRightRadius:     CGFloat = 0
    var bottomLeftRadius:   CGFloat = 0
    var bottomRightRadius:  CGFloat = 0
    
    var top     = Border(),
        right   = Border(),
        bottom  = Border(),
        left    = Border()
    
    let maskLayer = CAShapeLayer()
    var maskPath = UIBezierPath()
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        self.addSublayer(maskLayer)
        self.addSublayer(top)
        self.addSublayer(right)
        self.addSublayer(bottom)
        self.addSublayer(left)
    }
    
    init(edges: UIRectEdge, withBorder border: Border = Border()) {
        super.init()
        if edges.contains(.Top) {
            self.top = border.copy() as! Border
            self.addSublayer(self.top)
        }
        if edges.contains(.Right) {
            self.right = border.copy() as! Border
            self.addSublayer(self.right)
        }
        if edges.contains(.Bottom) {
            self.bottom = border.copy() as! Border
            self.addSublayer(self.bottom)
        }
        if edges.contains(.Left) {
            self.left = border.copy() as! Border
            self.addSublayer(self.left)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        top.frame = self.bounds
        top.bounds.size.height = top.width
        top.frame.origin.y = 0
        
        right.frame = self.bounds
        right.bounds.size.width = right.width
        right.frame.origin.x = self.bounds.width - right.width
        
        bottom.frame = self.bounds
        bottom.bounds.size.height = bottom.width
        bottom.frame.origin.y = self.bounds.height - bottom.width
        
        left.frame = self.bounds
        left.bounds.size.width = left.width
        left.frame.origin.x = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private var borderAssociationKey: UInt8 = 0

extension UIView {
    var border: BorderSet {
        get {
            var border = objc_getAssociatedObject(self, &borderAssociationKey) as? BorderSet
            if border == nil {
                border = BorderSet()
                objc_setAssociatedObject(self, &borderAssociationKey, border, .OBJC_ASSOCIATION_RETAIN)
                self.layer.addSublayer(border!)
                print("GET: No borders. Creating one with adress : ", unsafeAddressOf(border!))
            }
            return border!
        }
        set(border) {
            let existingBorder = objc_getAssociatedObject(self, &borderAssociationKey) as? BorderSet
            
            if existingBorder != nil {
                print("SET: Replace existing border : ", unsafeAddressOf(existingBorder!))
                existingBorder?.removeFromSuperlayer()
            }
            
            print("SET: The border is now : ", unsafeAddressOf(border))
            objc_setAssociatedObject(self, &borderAssociationKey, border, .OBJC_ASSOCIATION_RETAIN)
            self.layer.addSublayer(border)
        }
    }
    
    func layoutBorder() {
        self.border.frame = self.bounds
        self.border.frame.size.height = self.bounds.height + self.border.bottom.width + self.border.top.width + (self.border.padding.bottom * 2)
        self.border.frame.size.width = self.bounds.width + self.border.left.width + self.border.right.width + self.border.padding.right
        self.border.frame.origin.x = -self.border.left.width - self.border.padding.top
        self.border.frame.origin.y = -self.border.top.width - self.border.padding.bottom
    }
}
