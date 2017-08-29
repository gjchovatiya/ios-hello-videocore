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

extension UIImage {
    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
}

class ViewController: UIViewController, VCSessionDelegate {

    @IBOutlet weak var cameraContainer: UIView!
    
    var session:VCSimpleSession!
    let width = 1280
    let height = 720
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session  = VCSimpleSession(videoSize: CGSize(width: width, height: height), frameRate: 30, bitrate: 1000000, useInterfaceOrientation: false)
        cameraContainer.addSubview(session.previewView)
        session.previewView.frame = cameraContainer.bounds
        session.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func addImage(_ image: UIImage, inView view: UIView, origin: CGPoint, size: CGSize) {
        //let containerSize = view.bounds.size
        guard let img = image.scaleImage(toSize: size) else {
            return
        }
        let r = CGRect(x: size.width/2 + origin.x, y: size.height/2 + origin.y, width: size.width, height: size.height)
        session.addPixelBufferSource(img, with: r)
    }
    
    public func didAddCameraSource(_ session: VCSimpleSession!) {
//        session.filter = VCFilter.sepia
        let vcViewSize = CGSize(width: width, height: height)//view.bounds.size
        let gradientHeight = 0.3 * vcViewSize.height
        let origin = CGPoint(x: 0, y: vcViewSize.height - gradientHeight)
        addImage(UIImage(named: "logo")!, inView: view, origin: origin, size: CGSize(width: vcViewSize.width, height: gradientHeight))
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

