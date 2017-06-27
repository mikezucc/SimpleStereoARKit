//
//  SLAMRunner.swift
//  ATaleOfTwoScenes
//
//  Created by Michael Zuccarino on 6/21/17.
//  Copyright © 2017 Michael Zuccarino. All rights reserved.
//

import UIKit
import ARKit

enum SLAMRunnerStatus {
    case none, error, interrupted, notSLAM
}

protocol SLAMRunnerDelegate {
    func updatedTransform(_ transform: matrix_float4x4, imagePixelBuffer: CVPixelBuffer) // plz lock up your buffers necessarily
    func trackingBadState(_ status: SLAMRunnerStatus, trackingState: ARCamera.TrackingState, error: Error?)
}

class SLAMRunner: NSObject {

    var slamSession: ARSession?
    var delegate: SLAMRunnerDelegate?

    override init() {
        super.init()

        let configuration = ARWorldTrackingSessionConfiguration()

        slamSession = ARSession()
        slamSession?.delegate = self
        slamSession?.run(configuration)
    }

}

extension SLAMRunner: ARSessionDelegate {

    func sessionWasInterrupted(_ session: ARSession) {
        delegate?.trackingBadState(.interrupted, trackingState: ARCamera.TrackingState.notAvailable, error: nil)
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if case ARCamera.TrackingState.normal = frame.camera.trackingState {
            CVPixelBufferLockBaseAddress(frame.capturedImage, CVPixelBufferLockFlags.readOnly)
            delegate?.updatedTransform(frame.camera.transform, imagePixelBuffer: frame.capturedImage)
            CVPixelBufferUnlockBaseAddress(frame.capturedImage, CVPixelBufferLockFlags.readOnly)
        } else {
            delegate?.trackingBadState(.notSLAM, trackingState: frame.camera.trackingState, error: nil)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        delegate?.trackingBadState(.error, trackingState: ARCamera.TrackingState.notAvailable, error: error)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        delegate?.trackingBadState(.none, trackingState: camera.trackingState, error: nil)
    }

}
