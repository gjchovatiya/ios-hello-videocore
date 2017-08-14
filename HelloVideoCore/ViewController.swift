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

class ViewController: UIViewController, VCSessionDelegate {

    @IBOutlet weak var cameraContainer: UIView!
    
    var session:VCSimpleSession = VCSimpleSession(videoSize: CGSize(width: 1280, height: 720), frameRate: 30, bitrate: 1000000, useInterfaceOrientation: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraContainer.addSubview(session.previewView)
        session.previewView.frame = cameraContainer.bounds
        session.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func didAddCameraSource(_ session: VCSimpleSession!) {
        session.filter = VCFilter.sepia
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

