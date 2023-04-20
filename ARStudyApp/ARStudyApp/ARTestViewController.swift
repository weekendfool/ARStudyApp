//
//  ARTestViewController.swift
//  ARStudyApp
//
//  Created by Oh!ara on 2023/04/15.
//

import UIKit
import RealityKit
import ARKit
import MultipeerConnectivity

class ARTestViewController: UIViewController {

    
    // MARK: - UI
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var arButton: UIButton!
    
    @IBOutlet weak var arButton2: UIButton!
    // MARK: - 変数
    
    let rootAnchor = AnchorEntity()
    let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.3, 0.3)))
    
    var bulletModel = ModelEntity()
    
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
//    func makeBoxView() {
//        rootAnchor.position = simd_make_float3(0, -0.5, -1)
//
////       let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.3, 0.3)))
//        let unlitMaterial = UnlitMaterial(color: .systemBlue)
//        box.model?.materials = [unlitMaterial]
//
//        rootAnchor.addChild(box)
//        arView.scene.anchors.append(rootAnchor)
//    }
    
    // 弾丸の生成
    func makeBullet() {
        // 大きさ
        let size: Float = 0.1
        // 色
        let color = UIColor.systemBlue
        
        // 球体を生成
        let bulletNode = MeshResource.generateBox(size: size)
        
        // 3dコンテンツ
        bulletModel = ModelEntity(mesh: bulletNode)
        
        let unlitMaterial = UnlitMaterial(color: .systemBlue)
        bulletModel.model?.materials = [unlitMaterial]
        
        rootAnchor.addChild(bulletModel)
        arView.scene.anchors.append(rootAnchor)
    }
    
    // 弾丸
    func shoot2() {
        
        
        // カメラ座標mの三メートル先
        let infrontOfCamera = SIMD3<Float>(x: 0, y: 0, z: -5)
        
        // カメラ座標　-> アンカー座標
        let bulletPos = rootAnchor.convert(position: infrontOfCamera, to: rootAnchor)
        
        // ３d座標を行列に変換
        let movePos = float4x4.init(translation: bulletPos)
        
        // 移動
        let animeMove = bulletModel.move(
            to: movePos,
            relativeTo: nil,
            duration: 1.5,
            timingFunction: .linear
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.bulletModel.removeFromParent()
                }
        
        print("------------------")
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
    
   
    
    // 座標取得
    func getPosition() {
        
    }

    @IBAction func tappedARButton(_ sender: Any) {
       
        makeBullet()
        
    }
    
    @IBAction func tappedARButton2(_ sender: Any) {
        shoot2()
    }
}

extension ARTestViewController: ARSessionDelegate {
    
}

extension float4x4 {
init(translation vector: SIMD3<Float>) {
    self.init(.init(1, 0, 0, 0),
              .init(0, 1, 0, 0),
              .init(0, 0, 1, 0),
              .init(vector.x, vector.y, vector.z, 1))
}
}
