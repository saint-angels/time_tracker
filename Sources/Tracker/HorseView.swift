import SwiftUI
import SceneKit
import ModelIO
import SceneKit.ModelIO

struct HorseView: NSViewRepresentable {
    var wireColor: NSColor = NSColor(white: 0.6, alpha: 0.15)

    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false

        let scene = SCNScene()
        sceneView.scene = scene

        // Load horse model
        guard let url = Bundle.module.url(forResource: "WildHorse", withExtension: "obj", subdirectory: "Resources") else {
            return sceneView
        }
        let asset = MDLAsset(url: url)
        asset.loadTextures()
        let horseNode = SCNNode()
        for i in 0..<asset.count {
            let obj = asset.object(at: i)
            horseNode.addChildNode(SCNNode(mdlObject: obj))
        }

        // Wireframe material in light gray
        let material = SCNMaterial()
        material.diffuse.contents = wireColor
        material.lightingModel = .constant
        material.fillMode = .lines
        horseNode.enumerateChildNodes { node, _ in
            node.geometry?.materials = [material]
        }

        // Fit and center
        let (minVec, maxVec) = horseNode.boundingBox
        let size = SCNVector3(
            maxVec.x - minVec.x,
            maxVec.y - minVec.y,
            maxVec.z - minVec.z
        )
        let maxDim = max(size.x, max(size.y, size.z))
        let scale = 2.7 / maxDim
        horseNode.scale = SCNVector3(scale, scale, scale)
        let center = SCNVector3(
            (minVec.x + maxVec.x) / 2 * scale,
            (minVec.y + maxVec.y) / 2 * scale,
            (minVec.z + maxVec.z) / 2 * scale
        )
        horseNode.position = SCNVector3(-center.x, -center.y, -center.z)

        scene.rootNode.addChildNode(horseNode)

        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 20
        rotation.repeatCount = .infinity
        horseNode.addAnimation(rotation, forKey: "spin")

        // Camera
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 1.5
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.3, 5)
        cameraNode.look(at: SCNVector3(0, 0.3, 0))
        scene.rootNode.addChildNode(cameraNode)

        return sceneView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {}
}
