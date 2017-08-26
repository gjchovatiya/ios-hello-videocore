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
        case aspectFit
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
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
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
        if scalingMode == .fill {
            scaledImageRect = CGRect(origin: CGPoint.zero, size: newSize)
        } else {
            let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
            scaledImageRect = CGRect.zero
            scaledImageRect.size.width  = size.width * aspectRatio
            scaledImageRect.size.height = size.height * aspectRatio
            scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
            scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
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

    public func addImage(_ image: UIImage, origin: CGPoint, size: CGSize) {
        //let containerSize = view.bounds.size
        let img = image.scaled(to: size, scalingMode: .fill)
        let r = CGRect(x: size.width/2 + origin.x, y: size.height/2 + origin.y, width: size.width, height: size.height)
        session.addPixelBufferSource(img, with: r)
    }
    
    public func didAddCameraSource(_ session: VCSimpleSession!) {
//        session.filter = VCFilter.sepia
        let gradientHeight = 0.3 * videoResolution.height
        let origin = CGPoint(x: 0, y: videoResolution.height - gradientHeight)
        let imageSize = CGSize(width: videoResolution.width, height: gradientHeight)
        addImage(UIImage(named: "logo")!, origin: origin, size: imageSize)
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

