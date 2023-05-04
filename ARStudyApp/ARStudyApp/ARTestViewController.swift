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
//import Combine

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
//    var wallAnchor = AnchorEntity()
    
    var wallEntity = ModelEntity()
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self
        arView.environment.sceneUnderstanding.options = [.physics, .collision]
        
        
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
        
        //　物理的挙動の追加
        // 物理衝突設定
        let massProperties = PhysicsMassProperties(mass: 0)
        bulletModel.physicsBody = PhysicsBodyComponent(massProperties: massProperties, material: nil, mode: .static)
//
        bulletModel.generateCollisionShapes(recursive: true)
//
        bulletAnthor.addChild(bulletModel)
        arView.scene.anchors.append(bulletAnthor)
    }
    
    // 弾丸
    func shoot2() {
        
        
        // カメラ座標mの三メートル先
        let infrontOfCamera = SIMD3<Float>(x: 0, y: 0, z: -3)
        
        // カメラ座標　-> アンカー座標
        let bulletPos = bulletAnthor.convert(position: infrontOfCamera, to: nil)
        
        // ３d座標を行列に変換
        let movePos = float4x4.init(translation: bulletPos)
        
        // 移動: アンカーを動かすともの全てが動く,モデルだけ動かすと二つに増える
        let animeMove = bulletAnthor.move(
            to: movePos,
            relativeTo: nil,
            duration: 3,
            timingFunction: .linear
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.bulletAnthor.removeFromParent()
                }
        
        print("------------------")
    }
    
    // 壁の生成
    func makeWallModel() {
        // アンカーの設置
        let wallAnchor = AnchorEntity()
        // アンカーの位置を設定
        wallAnchor.position = simd_make_float3(0, 0, -1)
        // 色
        let color = UIColor.systemMint.withAlphaComponent(0.8)
        
        // 壁を生成
        let horizontalPlane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.5, cornerRadius: 0))
        
        horizontalPlane.physicsBody = PhysicsBodyComponent(
            massProperties: .default, // 質量
                material: .generate(friction: 1, // 摩擦係数
                                    restitution: 0.1), // 衝突の運動エネルギーの保存率
                mode: .static
        )

        horizontalPlane.generateCollisionShapes(recursive: true)
        
        let unlitMaterial = UnlitMaterial(color: color)
        horizontalPlane.model?.materials = [unlitMaterial]

//        worldAnchor.addChild(wallAnchor)
//        worldAnchor.addChild(horizontalPlane)
        
        
        wallAnchor.addChild(horizontalPlane)
        arView.scene.anchors.append(wallAnchor)
        
    
    }
    
   
    
    func makeWallModel2(anchor: ARPlaneAnchor) {
        // 大きさ
        let size = anchor.extent
        // 色
        let color = UIColor.systemRed.withAlphaComponent(0.5)
        
       
        var wallAnchor = AnchorEntity(anchor: anchor)
                
        
        // 壁を生成
        let wall = MeshResource.generatePlane(width: anchor.planeExtent.width, depth: anchor.planeExtent.height)
        
        // 3dコンテンツ
        wallEntity = ModelEntity(mesh: wall)
        
        let unlitMaterial = UnlitMaterial(color: color)
        wallEntity.model?.materials = [unlitMaterial]
        
       // 物理衝突設定
        wallEntity.physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(),
            mode:.static
        )
        
        wallEntity.generateCollisionShapes(recursive: false)
        
        
        
        
        print("$$$$$$$$$$$$$$$$")
        print("wall: \(wallAnchor.anchorIdentifier)")
        wallAnchor.addChild(wallEntity)
//        worldAnchor.addChild(worldAnchor)
        
        arView.scene.anchors.append(wallAnchor)
    }
    
    
    func makeWallModel3() {
        // アンカーの設置
        let wallAnchor = AnchorEntity()
        // アンカーの位置を設定
        wallAnchor.position = simd_make_float3(0, 0, -1)
        // 色
        let color = UIColor.systemMint.withAlphaComponent(0.8)
        
        let horizontalPlane = ModelEntity(mesh: .generateBox(size: [0.2, 0.2, 0.003]),
                                                     materials: [SimpleMaterial(color: color,
                                                     isMetallic: false)])

        horizontalPlane.physicsBody = PhysicsBodyComponent(massProperties: .default, // 質量
                                                           material: .generate(friction: 0.1, // 摩擦係数
                                                                               restitution: 0.1), // 衝突の運動エネルギーの保存率
                                                           mode: .static)
         // .kinematic モードで物理ボディをつける

        horizontalPlane.generateCollisionShapes(recursive: false)
        
        horizontalPlane.position = simd_make_float3(0, 0, -0.5)
         // 衝突形状をつける。子ノードまで recursive　につけることも可能

        worldAnchor.addChild(horizontalPlane)

    
    }
    
    func makeSample() {
        
        let horizontalPlane = ModelEntity(mesh: .generateBox(size: [0.2,0.003,0.2]),
                                                     materials: [SimpleMaterial(color: .white,
                                                     isMetallic: true)])

        horizontalPlane.physicsBody = PhysicsBodyComponent(massProperties: .default, // 質量
                                                           material: .generate(friction: 0.1, // 摩擦係数
                                                                               restitution: 0.1), // 衝突の運動エネルギーの保存率
                                                           mode: .kinematic)
         // .kinematic モードで物理ボディをつける

        horizontalPlane.generateCollisionShapes(recursive: false)
         // 衝突形状をつける。子ノードまで recursive　につけることも可能

        worldAnchor.addChild(horizontalPlane)

        // 添付Gif の verticalPlane も同様です

        let colors:[UIColor] = [.red,.orange,.magenta,.yellow,.purple,.white]
        for index in 0...5 {
            let physicalSphere = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                             materials: [SimpleMaterial(color: colors[index],
                                             isMetallic: true)])
            physicalSphere.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                           material: .generate(),
                                                           mode: .dynamic)
             // .dynamic モードで物理ボディをつける

            physicalSphere.generateCollisionShapes(recursive: false)
            physicalSphere.position = SIMD3<Float>(x: 0, y: 0.5, z: 0)
            
            // 衝突形状をつける
            worldAnchor.addChild(physicalSphere)
        }
                
        arView.scene.anchors.append(worldAnchor)
    }
    
    // 更新
    func updateWall(anchor: ARPlaneAnchor) {
        
        let x = arView.scene.anchors
    
        let cha = x.first!.children
       
        print("^^^^^^^^^^^^^^^")
        print("x: \(x)")
        
        
        
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
    func shoot() {
        let newPosition = simd_make_float3(
            worldAnchor.transform.translation.x,
            worldAnchor.transform.translation.y,
            worldAnchor.transform.translation.z + 0.5
            )

        let controller = bulletModel.move(
            to: Transform(scale: simd_make_float3(1, 1, 1),
                          rotation: worldAnchor.orientation,
                          translation: newPosition),
            relativeTo: nil,
            duration: 5,
            timingFunction: .linear
            )


        print("----------------------")

    }
    
    func shoot3() {
        
        let bulletAnthor = AnchorEntity()

        // 大きさ
        let size: Float = 0.1
        // 色
        let color = UIColor.systemBlue.withAlphaComponent(0.8)
        
        let bulletModel = ModelEntity(mesh: .generateBox(size: size),
                                                     materials: [SimpleMaterial(color: .systemBlue,
                                                     isMetallic: true)])
        
        bulletModel.physicsBody = PhysicsBodyComponent(massProperties: .default, // 質量
                                                           material: .generate(friction: 0.1, // 摩擦係数
                                                                               restitution: 1), // 衝突の運動エネルギーの保存率
                                                           mode: .kinematic)
         // .kinematic モードで物理ボディをつける

        bulletModel.generateCollisionShapes(recursive: true)
        
        
        // 球体を生成
//        let bulletNode = MeshResource.generateBox(size: size)
//
//        // 3dコンテンツ
//        let bulletModel = ModelEntity(mesh: bulletNode)
//
        let unlitMaterial = UnlitMaterial(color: color)
        bulletModel.model?.materials = [unlitMaterial]

//        //　物理的挙動の追加
//        // 物理衝突設定
//        let massProperties = PhysicsMassProperties(mass: 100)
//        bulletModel.physicsBody = PhysicsBodyComponent(massProperties: massProperties, material: nil, mode: .kinematic)
////
//        bulletModel.generateCollisionShapes(recursive: true)
        
//        worldAnchor.addChild(bulletModel)
//
        worldAnchor.addChild(bulletAnthor)
        bulletAnthor.addChild(bulletModel)
        arView.scene.anchors.append(bulletAnthor)
    
    // 弾丸
        
        
        // カメラ座標mの三メートル先
        let infrontOfCamera = SIMD3<Float>(x: 0, y: 0, z: -3)
        
        // カメラ座標　-> アンカー座標
        let bulletPos = bulletAnthor.convert(position: infrontOfCamera, to: nil)
        
        // ３d座標を行列に変換
        let movePos = float4x4.init(translation: bulletPos)
        
        // 移動: アンカーを動かすともの全てが動く,モデルだけ動かすと二つに増える
        let animeMove = bulletAnthor.move(
            to: movePos,
            relativeTo: nil,
            duration: 3,
            timingFunction: .linear
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            bulletAnthor.removeFromParent()
                }
        
        print("------------------")
    }
    
    func shoot4() {
        
        let bulletAnthor = AnchorEntity()

        // 大きさ
        let size: Float = 0.1
        // 色
        let color = UIColor.systemBlue.withAlphaComponent(0.8)
        
        let bullet = ModelEntity(mesh: .generateBox(size: size),
                                                     materials: [SimpleMaterial(color: color,
                                                     isMetallic: false)])

        bullet.physicsBody = PhysicsBodyComponent(massProperties: .default, // 質量
                                                           material: .generate(friction: 0, // 摩擦係数
                                                                               restitution: 0.1), // 衝突の運動エネルギーの保存率
                                                  mode: .kinematic)
         // .kinematic モードで物理ボディをつける

        bullet.generateCollisionShapes(recursive: true)
         // 衝突形状をつける。子ノードまで recursive　につけることも可能

        worldAnchor.addChild(bullet)
    
    // 弾丸
        // カメラ座標mの三メートル先
        let infrontOfCamera = SIMD3<Float>(x: 0, y: 0, z: -3)
        // カメラ座標　-> アンカー座標
        let bulletPos = bulletAnthor.convert(position: infrontOfCamera, to: nil)
        
        let origen = SIMD3<Float>(x: 0, y: 0, z: 0)

        // かかる力
        let force = SIMD3<Float>(x: 300, y: 300, z: 300)
        
        bullet.addForce(force, relativeTo: nil)
//        bullet.addForce(origen, at: force, relativeTo: nil)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
//            bullet.removeFromParent()
//                }
        // 衝突形状をつける
//        worldAnchor.addChild(bullet)
    
            
//    arView.scene.anchors.append(worldAnchor)
        print("------------------")
    }
   
    
    // 座標取得
    func getPosition() {
        
    }

    @IBAction func tappedARButton(_ sender: Any) {
        makeSample()
//        makeBullet()
        
    }
    
    @IBAction func tappedARButton2(_ sender: Any) {
        makeWallModel3()
        
    }
    
    @IBAction func tappedARButton3(_ sender: Any) {
        
        shoot4()
//        lound()
        
    
    }
    
}

extension ARTestViewController: ARSessionDelegate {
    // 平面追加時の処理
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let planeAnchor = anchors as? [ARPlaneAnchor] {
            print("==================")
            print("平面発見")
            print("anchors: \(anchors)")
            
//            makeWallModel2(anchor: planeAnchor.first!)
        }
        
       
        
    }
    
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        if let planeAnchors = anchors as? [ARPlaneAnchor] {
//
//
//            print("平面上書き")
//            print("anchors: \(planeAnchors.first)")
//
//            for anchor in anchors {
//
//                for planeAnchor in arView.scene.anchors {
//                    if anchor.identifier == planeAnchor.anchorIdentifier {
//                        print("@@@@@@@@@@@@@@@@@@@")
//                        // エンティティ取り出し
//                        let name = planeAnchor.children.first
//                        let entity = planeAnchor.children.first as! ModelEntity
//
//
//
//                        // 壁を生成
//                        let wall = MeshResource.generatePlane(width: (planeAnchors.first?.extent.x)!, depth: (planeAnchors.first?.extent.z)!).contents
//
////                        makeWallModel2(anchor: anchor as! ARPlaneAnchor)
//                        let x = entity.model?.mesh.replaceAsync(with: wall)
//
//                        print("scale: \(entity.scale)")
//                        print("children: \(entity.children)")
//                        print("children: \(entity.transform)")
////                        print("x: \(x?.result)")
//                    } else {
//                        print("==================")
//                        print("anchor: \(planeAnchor.anchorIdentifier)")
//                }
//
//
//
//                }
//            }
//        }
//    }
}


extension float4x4 {
init(translation vector: SIMD3<Float>) {
    self.init(.init(1, 0, 0, 0),
              .init(0, 1, 0, 0),
              .init(0, 0, 1, 0),
              .init(vector.x, vector.y, vector.z, 1))
}
}
