//
//  ConicalGradientView.swift
//  GradientColorPicker
//
//  Created by Pedro Saldanha on 14/05/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit

/**
 Simple subclass of UIView which uses `AEConicalGradient.Layer` as the view’s Core Animation layer.
 
 You can configure conical gradient options in `gradient` property.
 */
open class ConicalGradientView: UIView {
    
    // MARK: Properties
    /// The view’s conical gradient layer used for rendering. (read-only)
    open var gradient: ConicalGradientLayer { return layer as! ConicalGradientLayer }
    
    /// The class used to create the view’s Core Animation layer.
    open override class var layerClass : AnyClass {
        return ConicalGradientLayer.self
    }
    
    // MARK: Lifecycle
    /**
     Initializes and returns a newly allocated conical gradient view object with the specified frame rectangle.
     
     - parameter frame: The frame rectangle for the view, measured in points.
     
     - returns: An initialized conical gradient view object.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - parameter decoder: An unarchiver object.
     
     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        layer.needsDisplayOnBoundsChange = true
        layer.setNeedsDisplay()
    }
    
}
