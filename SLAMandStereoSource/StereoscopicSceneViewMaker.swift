//
//  StereoscopicSceneViewMaker.swift
//  ATaleOfTwoScenes
//
//  Created by Michael Zuccarino on 6/23/17.
//  Copyright © 2017 Michael Zuccarino. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreImage

enum StereoEye {
    case left, right
}

class StereoscopicSceneViewMaker: NSObject {

    var leftView: SCNView?
    var rightView: SCNView?
    var cameraLeftNode: SCNNode?
    var cameraRightNode: SCNNode?
    var headNode: SCNNode?

    var imageContext = CIContext(options: nil)

    override init() {
        super.init()
    }

    func attachStereoView(on view: UIView, with scene: SCNScene) {
        let width = view.frame.size.width/2

        leftView = SCNView()
        rightView = SCNView()

        leftView?.backgroundColor = .clear
        rightView?.backgroundColor = .clear

        view.addSubview(leftView!)
        view.addSubview(rightView!)

        leftView?.translatesAutoresizingMaskIntoConstraints = false
        rightView?.translatesAutoresizingMaskIntoConstraints = false

        _ = constraints(withViewPair: (leftView, view), features: [(.top, .top, 0), (.left, .left, 0), (.bottom, .bottom, 0)])
        _ = constraints(withViewPair: (rightView, view), features: [(.top, .top, 0), (.right, .right, 0), (.bottom, .bottom, 0)])
        _ = constraints(withViewPair: (leftView, rightView), features: [(.right, .left, 0)])
        _ = constraints(withViewPair: (leftView, nil), features: [(.width, .notAnAttribute, width)])
        view.layoutIfNeeded()

        leftView?.scene = scene
        rightView?.scene = scene

        attachStereoCamera(to: scene.rootNode)

        leftView?.pointOfView = cameraLeftNode
        rightView?.pointOfView = cameraRightNode

        leftView?.play(nil)
        rightView?.play(nil)

    }

    func attachStereoCamera(to node: SCNNode) {
        let head = SCNNode()
        let nodeLeft = camera(for: .left)
        self.cameraLeftNode = nodeLeft

        let nodeRight = camera(for: .right)
        self.cameraRightNode = nodeRight

        head.addChildNode(nodeLeft)
        head.addChildNode(nodeRight)
        headNode = head

        node.addChildNode(head)
    }

}

extension StereoscopicSceneViewMaker: SLAMRunnerDelegate {

    func updatedTransform(_ transform: matrix_float4x4, imagePixelBuffer: CVPixelBuffer) {
        headNode?.simdTransform = transform
    }

    func trackingBadState(_ status: SLAMRunnerStatus, trackingState: ARCamera.TrackingState, error: Error?) {}

}

extension StereoscopicSceneViewMaker {

    func pixelBufferToUIImage(_ buffer: CVPixelBuffer, options: [String: Any]? = nil) -> UIImage {
        let image = CIImage(cvPixelBuffer: buffer, options: options)
        return UIImage(ciImage: image)
    }

}

extension StereoscopicSceneViewMaker {

    func camera(for eye: StereoEye) -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.name = eye == .left ? "stereoLeft" : "stereoRight"
        cameraNode.position = SCNVector3(eye == .left ? -0.1 : 0.1, 0, 0)
        let camera = SCNCamera()
        camera.zNear = 1
        camera.zFar = 1000
        cameraNode.camera = camera
        return cameraNode
    }

}

extension StereoscopicSceneViewMaker {

    fileprivate func constraints(withViewPair viewPair: (UIView?, UIView?), features: [(NSLayoutAttribute, NSLayoutAttribute, CGFloat)]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for feature in features {
            let constraint = NSLayoutConstraint(item: viewPair.0,
                                                attribute: feature.0,
                                                relatedBy: .equal,
                                                toItem: viewPair.1,
                                                attribute: feature.1,
                                                multiplier: 1,
                                                constant: feature.2)
            constraint.priority = UILayoutPriority.required
            constraint.isActive = true
            constraints.append(constraint)
        }
        return constraints
    }

}
