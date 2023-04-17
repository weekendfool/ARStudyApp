//
//  ARTestViewController.swift
//  ARStudyApp
//
//  Created by Oh!ara on 2023/04/15.
//

import UIKit
import RealityKit
import ARKit

class ARTestViewController: UIViewController {

    
    // MARK: - UI
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var arButton: UIButton!
    
    @IBOutlet weak var arButton2: UIButton!
    // MARK: - 変数
    
    let rootAnchor = AnchorEntity()
    let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.3, 0.3)))
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self
        
        setup()
        
//        makeBoxView()
        
    }
    
    // MARK: - 関数
    // 準備
    func setup() {
        
        let configuration = ARWorldTrackingConfiguration()
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        arView.session.run(configuration)
        arView.scene.addAnchor(rootAnchor)
    }
    
    // 立方体の生成
    func makeBoxView() {
        rootAnchor.position = simd_make_float3(0, -0.5, -1)
        
//       let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.3, 0.3)))
        let unlitMaterial = UnlitMaterial(color: .systemBlue)
        box.model?.materials = [unlitMaterial]
        
        rootAnchor.addChild(box)
        arView.scene.anchors.append(rootAnchor)
    }
    
    // 弾丸の生成
    func makeBullet() {
        // 大きさ
        let size: Float = 0.1
        // 色
        let color = UIColor.systemBlue
        
        // 球体を生成
        let bulletNode = MeshResource.generateBox(size: size)
        
        // 3dコンテンツ
        let bulletModel = ModelEntity(mesh: bulletNode)
        
        rootAnchor.addChild(bulletModel)
        arView.scene.anchors.append(rootAnchor)
    }
    
    // 回転
    func lound() {
        
    }
    
    // 発射
    func shoot() {
        let newPosition = simd_make_float3(
            rootAnchor.transform.translation.x + 0.05,
            rootAnchor.transform.translation.y,
            rootAnchor.transform.translation.z
            )
        
        let controller = box.move(
            to: Transform(scale: simd_make_float3(1, 1, 1),
                          rotation: rootAnchor.orientation,
                          translation: newPosition),
            relativeTo: rootAnchor,
            duration: 5,
            timingFunction: .linear
            )
        
       
        print("----------------------")
       
    }
    
    func shoot2() {
        makeBullet()
    }
    
    // 座標取得
    func getPosition() {
        
    }

    @IBAction func tappedARButton(_ sender: Any) {
       
        
        shoot()
    }
    
    @IBAction func tappedARButton2(_ sender: Any) {
        makeBullet()
    }
}

extension ARTestViewController: ARSessionDelegate {
    
}
