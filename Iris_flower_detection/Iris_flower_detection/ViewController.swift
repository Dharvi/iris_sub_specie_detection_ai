//
//  ViewController.swift
//  Iris_flower_detection
//
//  Created by Vikas Kumra on 28/12/19.
//  Copyright © 2019 Vikas Kumra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Alamofire
import SwiftyJSON
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var flower_dimensions = [Float]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitTestResult = hitTestResults.first{
                addDot(at:hitTestResult)
            }
        }
        
    }
    func addDot(at hitResult:ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.0008)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            if dotNodes.count == 2{
//                print("2")
                calculate()
//             sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
//                node.removeFromParentNode()
//            }
            dotNodes.removeAll()
            }
        }
    }
    
    func calculate(){
//        print("calculate")
        let start = dotNodes[0]
        let end = dotNodes[1]
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        let distance = (sqrt(pow(a, 2)+pow(b,2)+pow(c,2)))*100
        flower_dimensions.append(distance)

        if flower_dimensions.count == 4{
                    let parameters = ["petal_length":flower_dimensions[0],"petal_width":flower_dimensions[1],"sepal_length":flower_dimensions[2],"sepal_width":flower_dimensions[3]]
            
            //  CREATE THE API using PYTHON either in Flask or Django
            let URLis = "http://0.0.0.0:0000/API/iris"
            Alamofire.request(URLis, method: .get , parameters: parameters).responseJSON(completionHandler: { (response) in
                if response.result.isSuccess{
                    let specie: JSON = JSON(response.result.value!)
                    print(specie["prediction"][0])
                    let alert = UIAlertController(title: "Alert", message: specie["prediction"][0].string, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                                    node.removeFromParentNode()
                                }
                    
                }
            })
//            print(flower_dimensions)
            flower_dimensions.removeAll()
        }
    }
}
