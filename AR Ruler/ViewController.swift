//
//  ViewController.swift
//  AR Ruler
//
//  Created by wenlong qiu on 7/23/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //clear dots and start new measuremenrt
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint) //A point on a surface detected by ARKit, but not part of any detected planes, its in 3d, can measure their distance regardless of plane
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    //add dot in screen and to array to show where we tapped
    func addDot(at hitResult : ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005) //half a centimeter
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red //diffuse is spread of lighting
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        
        //hitresult is a point, world transform is The position and orientation of the hit test result relative to the world coordinate system
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)//x is left to right, z to away or toward us
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(pow(end.position.x - start.position.x, 2) + pow(end.position.y - start.position.y, 2) + pow(end.position.z - start.position.z, 2))
        
        updateText(text: "\(distance)" , atPosition: end.position)
    }
    
    func updateText(text: String, atPosition: SCNVector3) {
        
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(atPosition.x, atPosition.y + 0.01, atPosition.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01) //size scale down to 1 %
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
   
}
