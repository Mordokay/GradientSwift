//
//  ViewController.swift
//  GradientColorPicker
//
//  Created by Pedro Saldanha on 14/05/2019.
//  Copyright © 2019 GreenSphereStudios. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    var externalBorderLayer: CALayer!
    // MARK: Properties
    let vividColors: [UIColor] = [.red, .green, .blue, .cyan, .yellow, .magenta, .orange, .purple, .brown]
    let bondColors: [UIColor] = [   UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1),
                                    UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1),
                                    UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
                                    UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1),
                                    UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
                                    UIColor(red: 255/255, green: 95/255, blue: 0/255, alpha: 1),
                                    UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)]
    let grayscaleColors: [UIColor] = [.white, .lightGray, .gray, .darkGray, .black]
    
    var draggableCircle: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let background =  UIView(frame: CGRect(origin: .zero, size: CGSize.currentWindowSize))
    
    let gradientCircle: ConicalGradientView = {
        let view = ConicalGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var lastLocation = CGPoint.zero
    var panRecognizer: UIPanGestureRecognizer!
    var ringThickness: CGFloat = 10
    var borderDraggableAlpha: CGFloat!
    var borderDraggableWidth: CGFloat!
    var draggableBackgroundColor: UIColor!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(background)
        view.addSubview(gradientCircle)
        view.addSubview(draggableCircle)
        
        background.setVerticalGradient(startColor: UIColor(red: 0/255, green: 15/255, blue: 33/255, alpha: 1    ), endColor: UIColor(red: 0/255, green: 72/255, blue: 111/255, alpha: 1))
        
        ringThickness = relativeWidth(20)
        
        gradientCircle.gradient.colors = bondColors
        gradientCircle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedGradient)))
        gradientCircle.isUserInteractionEnabled = true
        setupViews()
    }
    
    func setupBorderLayer() {
        borderDraggableAlpha = 0.3
        borderDraggableWidth = relativeWidth(5)
        
        externalBorderLayer = CALayer()
        externalBorderLayer.frame = CGRect(x: -borderDraggableWidth, y: -borderDraggableWidth, width: draggableCircle.frame.size.width + 2 * borderDraggableWidth, height: draggableCircle.frame.size.height + 2 * borderDraggableWidth)
        externalBorderLayer.borderColor = draggableBackgroundColor.withAlphaComponent(borderDraggableAlpha).cgColor
        externalBorderLayer.borderWidth = borderDraggableWidth
        externalBorderLayer.cornerRadius = (draggableCircle.frame.size.width + 2 * borderDraggableWidth) / 2
        externalBorderLayer.name = "externalBorder"
        draggableCircle.layer.addSublayer(externalBorderLayer)
    }
    
    func drawDirectionLine() {
        let circlePath = UIBezierPath(arcCenter: gradientCircle.center, radius: (gradientCircle.frame.width - ringThickness) / 2, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.red.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc
    func tappedGradient(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: gradientCircle)
        let color = gradientCircle.gradient.colorOfPoint(point: touchPoint)
        view.backgroundColor = UIColor(cgColor: color)
        print("tapped gradient \(touchPoint)")
    }
    
    func setupDraggableImage() {
        self.draggableBackgroundColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)
        
        let size =  CGSize(width: relativeWidth(50), height: relativeWidth(50))
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        
        draggableCircle.isUserInteractionEnabled = true
        draggableCircle.addGestureRecognizer(panRecognizer!)
        draggableCircle.backgroundColor = UIColor.black
        draggableCircle.layer.cornerRadius = size.width / 2
        draggableCircle.backgroundColor = draggableBackgroundColor
        
        let radius = (gradientCircle.frame.width - ringThickness) / 2
        let x = gradientCircle.center.x + radius * cos(0)
        let y = gradientCircle.center.y + radius * sin(0)
        lastLocation = CGPoint(x: x - size.width / 2, y: y - size.height / 2)
        draggableCircle.frame = CGRect(origin: lastLocation, size: size)
    }

    @objc
    func detectPan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            lastLocation = draggableCircle.center
        } else if recognizer.state == .changed {
            let translation = recognizer.translation(in: draggableCircle.superview!)
            draggableCircle.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            
            //Converts the draggable circle to a point inside the gradient
            let rads = atan2(draggableCircle.center.y - gradientCircle.center.y, draggableCircle.center.x - gradientCircle.center.x)
            let radius = (gradientCircle.frame.width - ringThickness) / 2
            let x = gradientCircle.center.x + radius * cos(rads)
            let y = gradientCircle.center.y + radius * sin(rads)
            draggableCircle.center = CGPoint(x: x, y: y)
            
            
            //Detects color underneath draggable circle and changes it
            let touchPoint = view.convert(draggableCircle.center, to: gradientCircle)
            let color = gradientCircle.gradient.colorOfPoint(point: touchPoint)
            
            draggableBackgroundColor = UIColor(cgColor: color)
            draggableCircle.backgroundColor = draggableBackgroundColor
            externalBorderLayer.borderColor = draggableBackgroundColor.withAlphaComponent(borderDraggableAlpha).cgColor
            
            print("rads: \(rads)  point: \(CGPoint(x: x, y: y))")
        } else if recognizer.state == .ended {
//            UIView.animate(withDuration: 0.2, animations: {
//                self.draggableCircle.center = self.lastLocation
//            }, completion: { _ in
//
//            })
        }
    }
    
    func setupViews() {
        NSLayoutConstraint.activate([
         gradientCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         gradientCircle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         gradientCircle.widthAnchor.constraint(equalToConstant: relativeWidth(300)),
         gradientCircle.heightAnchor.constraint(equalToConstant: relativeWidth(300))
        ])
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientCircle.gradient.ringThickness = ringThickness
        
        //drawDirectionLine()
        setupDraggableImage()
        setupBorderLayer()
    }
}

extension UIViewController {
    func relativeWidth(_ width: CGFloat) -> CGFloat {
        return CGSize.getRelativeWidth(from: width, fromTemplate: .iPhoneXs)
    }
    func relativeHeight(_ height: CGFloat) -> CGFloat {
        return CGSize.getRelativeHeight(from: height, fromTemplate: .iPhoneXs)
    }
}

extension UserDefaults {
    func reset() {
        for key in dictionaryRepresentation().keys {
            removeObject(forKey: key)
        }
    }
}

extension CGSize {
    static var currentWindowSize: CGSize {
        return  UIApplication.shared.keyWindow?.bounds.size ?? UIWindow().bounds.size
    }
    
    static func getSize(from original: CGSize, fromTemplate template: DeviceTemplate = .iPhonePlus) -> CGSize {
        return CGSize(width: currentWindowSize.width * (original.width / template.rawValue.width), height: currentWindowSize.height * (original.height / template.rawValue.height))
    }
    
    static func getRelativeWidth(from original: CGFloat, fromTemplate template: DeviceTemplate = .iPhonePlus) -> CGFloat {
        return currentWindowSize.width * (original / template.rawValue.width)
    }
    static func getRelativeHeight(from original: CGFloat, fromTemplate template: DeviceTemplate = .iPhonePlus) -> CGFloat {
        return currentWindowSize.height * (original / template.rawValue.height)
    }
    
    static var maxWidth: CGFloat {
        if DeviceTemplate.currentType == .iPhoneSE {
            return 315
        }
        return 295
    }
}

extension CGSize: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let size = NSCoder.cgSize(for: value)
        self.init(width: size.width, height: size.height)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        let size = NSCoder.cgSize(for: value)
        self.init(width: size.width, height: size.height)
    }
    
    public init(unicodeScalarLiteral value: String) {
        let size = NSCoder.cgSize(for: value)
        self.init(width: size.width, height: size.height)
    }
}

enum DeviceTemplate: CGSize {
    case iPhoneSE = "{320, 568}"
    case iPhone6 = "{375, 667}"
    case iPhonePlus = "{414, 736}"
    case iPhoneX = "{375, 812}"
    case iPhoneXs = "{414, 896}"
    
    static var currentType: DeviceTemplate? {
        
        switch CGSize.currentWindowSize {
        case DeviceTemplate.iPhoneSE.rawValue:
            return .iPhoneSE
        case DeviceTemplate.iPhone6.rawValue:
            return .iPhone6
        case DeviceTemplate.iPhonePlus.rawValue:
            return .iPhonePlus
        case DeviceTemplate.iPhoneXs.rawValue:
            return .iPhoneXs
        default:
            return .iPhoneX
        }
    }
}

extension CALayer {
    
    func colorOfPoint(point:CGPoint) -> CGColor {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.render(in: context!)
        
        let red: CGFloat   = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.cgColor
    }
}

extension UIView {
    func addExternalBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = UIColor.white) {
        let externalBorder = CALayer()
        externalBorder.frame = CGRect(x: -borderWidth, y: -borderWidth, width: frame.size.width + 2 * borderWidth, height: frame.size.height + 2 * borderWidth)
        externalBorder.borderColor = borderColor.cgColor
        externalBorder.borderWidth = borderWidth
        externalBorder.cornerRadius = (frame.size.width + 2 * borderWidth) / 2
        externalBorder.name = "externalBorder"
        layer.insertSublayer(externalBorder, at: 0)
        layer.masksToBounds = false
    }
    
    func setVerticalGradient(startColor: UIColor, endColor: UIColor) {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.colors = [startColor.cgColor,endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(gradientLayer)
    }
}
