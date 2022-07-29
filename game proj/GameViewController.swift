//
//  GameViewController.swift
//  game proj
//
//  Created by sofia on 27.07.2022.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var finalScore: UILabel!
    

    
////    Make gameOverLabel transparent until game is over
//    func setLabelTransperency()
//    {
//        gameOverLabel.alpha = 0
//    }
    
//    Create the score variable
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
//    property observers  are always in the main thread, such case can be useful when we will need to modify the variable from different places (here: main storyboard (scoreLabel) and the code (score counter))
    
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
//    the ship object
    var starship: SCNNode!
    
//    ! is used to "promise" to compiler that we will use and initialize this object
    
//    Gesture recognizer
    var tapGesture: UITapGestureRecognizer!
    
//    computed property
    var getShip: SCNNode?
     {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
//    added "?" above to define that returnable value is optional (could return value or to return no value (nil ))
    
    //        Set animation duration (in other words the speed of ship movement)
            var duration: TimeInterval = 5
    
    func removeShip()
    {
        getShip?.removeFromParentNode()
    }
//    added "?" to define that if we don't find the value we need rhis line of code just will be passed
    
    func spawnShip()
    {
        starship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
//        add ship to the scene
        scene.rootNode.addChildNode(starship)
        
//        position the ship
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -88
        let position = SCNVector3(x, y, z)
        starship.position = position
//        the ship flies from position 0 0 -88 to 0 0 0
        
//        Look at position
        let lookAtPosition = SCNVector3(2 * x, 2 * y, 2 * z)
        starship.look(at: lookAtPosition)
        

        
//        Move the ship
        starship.runAction(.move(to: SCNVector3(), duration: duration))
        {
            print(#line, #function, "Animation stopped.")
//            #line and #function are a key parts of code used to write in console on what line function stopped execution and what fucntion
            self.removeShip()
            
//            Add removeGestureRecognizer to main thread from background thread (important!)
            DispatchQueue.main.async {
                self.scnView.removeGestureRecognizer(self.tapGesture)
                self.gameOverLabel.alpha = 1
                self.scoreLabel.alpha = 0
                self.finalScore.text = "SCORE: \(self.score)"
                self.finalScore.alpha = 1
            }
             
        }
         
    }
     
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameOverLabel.numberOfLines = 2
        
//        remove the ship
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//          let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
//        3scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
        spawnShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {

        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.15
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.starship.removeAllActions()
                self.removeShip()
                self.score += 15
                
//                Increase the movement duration (speed)
                self.duration *= 0.9
                

                
//                Spawn a new ship
                self.spawnShip()
                
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = UIColor.black
//
//                SCNTransaction.commit()
            }
            
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
