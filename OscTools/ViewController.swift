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

    @IBOutlet weak var valueLabel: UILabel!
    
    
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
        guard gesture.numberOfTouches > 0 else { return }
        
        var touches = [CGPoint]()
        for i in 0..<gesture.numberOfTouches {
            let location = gesture.location(ofTouch: i, in: view)
            let normalized = normalReverseY(point: normalize(point: location))
            let converted = normalTo1920x1200(point: normalized)
            touches.append(converted)
        }
                        
        updateView(points: touches)
        let message = getOscMessage(points: touches)
        
        client.send(message)
    }
    
    func updateView(points: [CGPoint]) {
        var valueStr = ""
        for (i, point) in points.enumerated() {
            valueStr += "\(i) x: \(round(point.x)), y: \(round(point.y)), "
        }
        valueLabel.text = valueStr
    }
    
    func getOscMessage(points: [CGPoint]) -> OSCMessage {
        var values = [Int]()
        for point in points {
            values.append(Int(point.x))
            values.append(Int(point.y))
            values.append(0)
        }
        return OSCMessage(oscAddress, values)
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

