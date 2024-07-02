//
//  ViewController.swift
//  AR Ruler
//
//  Created by Mohd Haris on 02/12/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

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
//        let touch = touches.first
        
        if dotNodes.count >= 2{
            for node in dotNodes{
                node.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTests = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitTestResult = hitTests.first{
                addDot(at : hitTestResult)
            }
        }
    }
    
    
    func addDot(at hitResult :ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor(.red)
        dotGeometry.materials = [sphereMaterial]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
                           x: hitResult.worldTransform.columns.3.x,
                           y: hitResult.worldTransform.columns.3.y,
                           z: hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
    }
    
    func calculate(){
      let start = dotNodes[0]
      let end = dotNodes[1]

//        print("the starting point is \(start)")
//        print("the ending point is \(end)")
        
        let a = start.position.x - end.position.x
        let b = start.position.y - end.position.y
        let c = start.position.z - end.position.z
        
        let Adistance = sqrt(pow(a,2) + pow(b,2) + pow(c,2)) * 100
        let distance = Float(String(format: "%.00f", Adistance))!
        
//        print(abs(distance))
        
        navigationBarTitle.title = "\(distance) cm"
        updateText("\(abs(distance)) cm" , end.position)
    }
    
    func updateText(_ text: String,_ atPosition : SCNVector3){
        
        textNode.removeFromParentNode() //remove the previous text if we selects new point on the screen
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: atPosition.x, y: atPosition.y + 0.01, z: atPosition.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}
