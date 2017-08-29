//
//  ViewController.swift
//  VideoCore Test
//
//  Created by François Rouault on 14/08/2017.
//  Copyright © 2017 Firekast. All rights reserved.
//

import Foundation
import UIKit
import videocore

//extension UIImage {
//
//    func scaleImage(toSize newSize: CGSize) -> UIImage? {
//        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
//        if let context = UIGraphicsGetCurrentContext() {
//            context.interpolationQuality = .high
//            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
//            context.concatenate(flipVertical)
//            context.draw(self.cgImage!, in: newRect)
//            let newImage = UIImage(cgImage: context.makeImage()!)
//            UIGraphicsEndImageContext()
//            return newImage
//        }
//        return nil
//    }
//
//}

// MARK: - Image Scaling.
extension UIImage {
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit(alignment: UIImage.Alignment)
        case fill
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .fill:
                return 1
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit(_):
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    enum Alignment {
        case center, right, left
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect: CGRect
        switch scalingMode {
        case .fill:
            scaledImageRect = CGRect(origin: CGPoint.zero, size: newSize)
        case .aspectFill:
            let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
            scaledImageRect = CGRect.zero
            scaledImageRect.size.width  = size.width * aspectRatio
            scaledImageRect.size.height = size.height * aspectRatio
            scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
            scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0
        case .aspectFit(let alignment):
            let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
            scaledImageRect = CGRect.zero
            scaledImageRect.size.width  = size.width * aspectRatio
            scaledImageRect.size.height = size.height * aspectRatio
            switch alignment {
            case .center:
                scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
                scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0
            case .right:
                scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) - scaledImageRect.width / 2.0
                scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio)
            case .left:
                scaledImageRect.origin.x = scaledImageRect.width / 2.0
                scaledImageRect.origin.y = 0
            }
        }
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(newSize)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

class ViewController: UIViewController, VCSessionDelegate {
    
    @IBOutlet weak var cameraContainer: UIView!
    
    var session:VCSimpleSession!
    let videoResolution = CGSize(width: 1280, height: 720)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session  = VCSimpleSession(videoSize: videoResolution, frameRate: 30, bitrate: 1000000, useInterfaceOrientation: false)
        cameraContainer.addSubview(session.previewView)
        session.previewView.frame = cameraContainer.bounds
        session.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func addImage(_ image: UIImage, origin: CGPoint, size: CGSize, scaleMode: UIImage.ScalingMode) {
        //let containerSize = view.bounds.size
        let img = image.scaled(to: size, scalingMode: scaleMode)
        let r = CGRect(x: size.width/2 + origin.x, y: size.height/2 + origin.y, width: size.width, height: size.height)
        session.addPixelBufferSource(img, with: r)
    }
    
    public func didAddCameraSource(_ session: VCSimpleSession!) {
        print("Video resolution ratio : \(videoResolution.width/videoResolution.height)")
        print("Camera container ratio : \(cameraContainer.bounds.width/cameraContainer.bounds.height)")
        let orientation = UIApplication.shared.statusBarOrientation
        // TEMOIN
        let temoin = UIImage(named: "temoin")!
//        let temoinVertical = UIImage(named: "temoin-vertical")!
//        let temoinHorizontal = UIImage(named: "temoin-horizontal")!
        let size = CGSize(width: 640, height: 16)
        let originTopLeft = CGPoint(x: 0, y: 0)
//        let originBottomLeft = CGPoint(x: 0, y: videoResolution.height - size.height)
//        let originTopRight = CGPoint(x: videoResolution.width - size.width, y: 0)
//        let originBottomRight = CGPoint(x: videoResolution.width - size.width, y: videoResolution.height - size.height)
        addImage(temoin, origin: originTopLeft, size: size, scaleMode: .fill)
        // TEST1
//        //        session.filter = VCFilter.sepia
//        let gradientHeight = 0.3 * videoResolution.height
//        let gradientOrigin = CGPoint(x: 0, y: videoResolution.height - gradientHeight)
//        let gradientSize = CGSize(width: videoResolution.width, height: gradientHeight)
//        //        addImage(UIImage(named: "firekast-with-gradient")!, origin: origin, size: imageSize)
//        addImage(UIImage(named: "gradient")!, origin: gradientOrigin, size: gradientSize, scaleMode: .fill)
////        let logo = UIImage(named: "firekast-with-gradient")
//        let logo = UIImage(named: "temoin-horizontal")
//        let logoSize = CGSize(width: 0.3*videoResolution.width, height: gradientHeight)
//        let logoOrigin = CGPoint(x: videoResolution.width-logoSize.width, y: videoResolution.height-logoSize.height)
//        addImage(logo!, origin: logoOrigin, size: logoSize, scaleMode: .aspectFit(alignment: .center))
        // TEST2
        // - gradient
        let imgGradient = UIImage(named: "gradient")!
        let gradientSize = CGSize(width: videoResolution.width, height: 0.3 * videoResolution.height)
        let gradientOrigin = CGPoint(x: 0, y: videoResolution.height - gradientSize.height)
        print("Gradient origin: \(gradientOrigin), size: \(gradientSize)")
        addImage(imgGradient, origin: gradientOrigin, size: gradientSize, scaleMode: .fill)
        // - logo
        let imgLogo = UIImage(named: "temoin-horizontal")!
        print("imgLogo.size = \(imgLogo.size)")
        let imgRatio = imgLogo.size.width / imgLogo.size.height
        let logoMargin = 0.1 * gradientSize.height
//        let logoHeight = gradientSize.height - 2 * logoMargin
//        let logoWidth = imgRatio * logoHeight
        let logoWidth = 0.3 * videoResolution.width
        let logoHeight = logoWidth / imgRatio
        let logoSize = CGSize(width: logoWidth, height: logoHeight)
        let logoOrigin = CGPoint(x: videoResolution.width - logoSize.width - logoMargin, y: videoResolution.height - logoSize.height - logoMargin)
//        let logoOrigin = CGPoint(x: videoResolution.width - logoSize.width, y: videoResolution.height - logoSize.height - logoMargin)
        print("Logo origin: \(logoOrigin), size: \(logoSize)")
        addImage(imgLogo, origin: logoOrigin, size: logoSize, scaleMode: .fill)
    }
    
    func connectionStatusChanged(_ sessionState: VCSessionState) {
        switch session.rtmpSessionState {
        case .starting:
            print("starting")
            //            btnConnect.setTitle("Connecting", forState: .Normal)
            
        case .started:
            print("disconnect")
            //            btnConnect.setTitle("Disconnect", forState: .Normal)
            
        default:
            print("connect")
            //            btnConnect.setTitle("Connect", forState: .Normal)
        }
    }
    
}

