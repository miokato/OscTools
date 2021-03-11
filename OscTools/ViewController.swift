//
//  ViewController.swift
//  OscTools
//
//  Created by mio kato on 2021/03/06.
//

import UIKit
import SwiftOSC

class ViewController: UIViewController {
    var client: OSCClient!
    var oscAddress: OSCAddressPattern!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupOsc()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(panGesture)
                        
    }
    
    private func setupOsc() {
        let oscIP = UserDefaults.standard.string(forKey: "oscIP") ?? "127.0.0.1"
        let oscPort = UserDefaults.standard.integer(forKey: "oscPort")
        let address = UserDefaults.standard.string(forKey: "oscAddress") ?? "/default"
        oscAddress = OSCAddressPattern(address)
        client = OSCClient(address: oscIP, port: oscPort)
        #if DEBUG
            print("\(oscIP), \(oscPort), \(address)")
        #endif
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
                
        let normalized = normalReverseY(point: normalize(point: location))
        
        let converted = normalTo1920x1200(point: normalized)
        
        updateView(point: converted)
        
        let message = getOscMessage(point: converted)
        
        client.send(message)
    }
    
    func updateView(point: CGPoint) {
        xLabel.text = String(format: "%.0f", point.x)
        yLabel.text = String(format: "%.0f", point.y)
    }
    
    func getOscMessage(point: CGPoint) -> OSCMessage {
        
        return OSCMessage(oscAddress, Int(point.x), Int(point.y), 0)
    }
    
    func normalTo1920x1200(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * 1920, y: point.y * 1200)
    }
    
    func normalize(point: CGPoint) -> CGPoint {
        let x = point.x / view.bounds.width
        let y = point.y / view.bounds.height
        return CGPoint(x: x, y: y)
    }
    
    func normalReverseY(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x, y: 1 - point.y)
    }
    


}

