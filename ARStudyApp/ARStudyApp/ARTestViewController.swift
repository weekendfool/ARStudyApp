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
    @IBOutlet weak var arButton3: UIButton!
    // MARK: - 変数
    let worldAnchor: AnchorEntity = AnchorEntity()
    
//    let rootAnchor = AnchorEntity()
//    let box = ModelEntity(mesh: .generateBox(size: simd_make_float3(0.3, 0.3, 0.3)))
    
    var bulletModel = ModelEntity()
    var bulletAnthor = AnchorEntity()
    
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
        
        // 平面の発見
        configuration.planeDetection = [.horizontal, .vertical]
        
        
        
        arView.session.run(configuration)
        arView.scene.addAnchor(worldAnchor)
    }
    
   
    
    // 弾丸の生成
    func makeBullet() {
        // 大きさ
        let size: Float = 0.1
        // 色
        let color = UIColor.systemBlue.withAlphaComponent(0.8)
        
        
        // 球体を生成
        let bulletNode = MeshResource.generateBox(size: size)
        
        // 3dコンテンツ
        bulletModel = ModelEntity(mesh: bulletNode)
        
        let unlitMaterial = UnlitMaterial(color: color)
        bulletModel.model?.materials = [unlitMaterial]
        
        bulletAnthor.addChild(bulletModel)
        arView.scene.anchors.append(bulletAnthor)
    }
    
    // 弾丸
    func shoot2() {
        
        
        // カメラ座標mの三メートル先
        let infrontOfCamera = SIMD3<Float>(x: 0, y: 0, z: -5)
        
        // カメラ座標　-> アンカー座標
        let bulletPos = bulletAnthor.convert(position: infrontOfCamera, to: nil)
        
        // ３d座標を行列に変換
        let movePos = float4x4.init(translation: bulletPos)
        
        // 移動: アンカーを動かすともの全てが動く,モデルだけ動かすと二つに増える
        let animeMove = bulletAnthor.move(
            to: movePos,
            relativeTo: nil,
            duration: 1.5,
            timingFunction: .linear
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.bulletAnthor.removeFromParent()
                }
        
        print("------------------")
    }
    
    // 壁の生成
    func makeWallModel(anchor: ARPlaneAnchor) {
        // 大きさ
        let size: Float = 0.5
        // 色
        let color = UIColor.systemRed.withAlphaComponent(0.1)
        
        var wallAnchor = AnchorEntity(anchor: anchor)
        var wallEntity = ModelEntity()
                
        
        // 球体を生成
        let wall = MeshResource.generatePlane(width: size, depth: 1)
        
        // 3dコンテンツ
        wallEntity = ModelEntity(mesh: wall)
        
        let unlitMaterial = UnlitMaterial(color: color)
        wallEntity.model?.materials = [unlitMaterial]
        
        wallAnchor.addChild(wallEntity)
        arView.scene.anchors.append(wallAnchor)
    }
    
    // 回転
    func lound() {
        // 回転させたい角度
        let rotation: Float = 180 * .pi / 180
        
        //アンカー座標内でアンカーを回転させる
        bulletAnthor.move(
            to: Transform(pitch: 0, yaw: 0, roll: rotation),
            relativeTo: bulletAnthor,
            duration: 1
        )
        
        
    }
    
    // 反射
    func reflection() {
        // 平面の発見
        // 当たったことの検知
        // 方向転換
    }
    
    // 発射
//    func shoot() {
//        let newPosition = simd_make_float3(
//            worldAnchor.transform.translation.x + 0.05,
//            worldAnchor.transform.translation.y,
//            worldAnchor.transform.translation.z
//            )
//
//        let controller = bulletModel.move(
//            to: Transform(scale: simd_make_float3(1, 1, 1),
//                          rotation: worldAnchor.orientation,
//                          translation: newPosition),
//            relativeTo: nil,
//            duration: 5,
//            timingFunction: .linear
//            )
//
//
//        print("----------------------")
//
//    }
    
   
    
    // 座標取得
    func getPosition() {
        
    }

    @IBAction func tappedARButton(_ sender: Any) {
       
        makeBullet()
        
    }
    
    @IBAction func tappedARButton2(_ sender: Any) {
        shoot2()
    }
    
    @IBAction func tappedARButton3(_ sender: Any) {
        lound()
    }
    
}

extension ARTestViewController: ARSessionDelegate {
    // 平面追加時の処理
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let planeAnchor = anchors as? [ARPlaneAnchor] {
            print("==================")
            print("平面発見")
            print("anchors: \(anchors)")
            
            makeWallModel(anchor: planeAnchor.first!)
        }
        
       
        
    }
}


extension float4x4 {
init(translation vector: SIMD3<Float>) {
    self.init(.init(1, 0, 0, 0),
              .init(0, 1, 0, 0),
              .init(0, 0, 1, 0),
              .init(vector.x, vector.y, vector.z, 1))
}
}
