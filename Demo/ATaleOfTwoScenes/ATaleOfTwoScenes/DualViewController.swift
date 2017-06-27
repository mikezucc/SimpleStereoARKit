//
//  DualViewController.swift
//  ATaleOfTwoScenes
//
//  Created by Michael Zuccarino on 6/20/17.
//  Copyright © 2017 Michael Zuccarino. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class DualViewController: UIViewController {

    var cameraLeftView: UIImageView?
    var cameraRightView: UIImageView?
    var stereoView: StereoscopicSceneViewMaker?
    var tracker: SLAMRunner?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let cameraLeftBackground = UIImageView()
        cameraLeftBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraLeftBackground)
        cameraLeftView = cameraLeftBackground
        cameraLeftView?.contentMode = .scaleAspectFit

        let cameraRightBackground = UIImageView()
        cameraRightBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraRightBackground)
        cameraRightView = cameraRightBackground
        cameraRightView?.contentMode = .scaleAspectFit

        let width = view.frame.size.width/2
        _ = constraints(withViewPair: (cameraLeftView, view), features: [(.top, .top, 0), (.left, .left, 0), (.bottom, .bottom, 0)])
        _ = constraints(withViewPair: (cameraRightView, view), features: [(.top, .top, 0), (.right, .right, 0), (.bottom, .bottom, 0)])
        _ = constraints(withViewPair: (cameraLeftView, cameraRightView), features: [(.right, .left, 0)])
        _ = constraints(withViewPair: (cameraLeftView, nil), features: [(.width, .notAnAttribute, width)])
        view.layoutIfNeeded()

        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        stereoView = StereoscopicSceneViewMaker()
        stereoView?.attachStereoView(on: view, with: scene)

        tracker = SLAMRunner()
        tracker?.delegate = self
    }

}

extension DualViewController: SLAMRunnerDelegate {

    func updatedTransform(_ transform: matrix_float4x4, imagePixelBuffer: CVPixelBuffer) {
        stereoView?.updatedTransform(transform, imagePixelBuffer: imagePixelBuffer)
        let cameraImage = stereoView?.pixelBufferToUIImage(imagePixelBuffer, options: nil)
        // TODO: barrel transform
        cameraLeftView?.image = cameraImage
        cameraRightView?.image = cameraImage
    }

    func trackingBadState(_ status: SLAMRunnerStatus, trackingState: ARCamera.TrackingState, error: Error?) {}

}

extension DualViewController {

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
