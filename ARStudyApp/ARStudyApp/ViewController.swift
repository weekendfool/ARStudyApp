//
//  ViewController.swift
//  ARStudyApp
//
//  Created by Oh!ara on 2023/04/15.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var arButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        
    }
    
    // 準備
    func setup() {
        
    }
    
    // 回転
    func lound() {
        
    }
    
    // 発射
    func shoot() {
        
    }
}
