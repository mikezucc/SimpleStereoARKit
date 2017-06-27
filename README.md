# SimpleStereoARKit
Simple reference guide on using ARKit without ARScene and a simple convenience class for attaching stereoscopic camera nodes

![sample](http://i.imgur.com/3u2l43w.png)

## SLAMRunner.swift
Bare simple object to run the underlying ARKit SLAM. This will provide updates to a delegate in the form of a `matrix_float4x4` which is a type alias for `simd_float4x4`.
You can update the position of a SCNode with this value like `headNode?.simdTransform = transform`

Attach like so:
```
tracker = SLAMRunner()
tracker?.delegate = self
```

Receive updates like so:
```
protocol SLAMRunnerDelegate {
    func updatedTransform(_ transform: matrix_float4x4, imagePixelBuffer: CVPixelBuffer) // plz lock up your buffers necessarily
    func trackingBadState(_ status: SLAMRunnerStatus, trackingState: ARCamera.TrackingState, error: Error?)
}
```

Compare tracking states like so:
```
if case ARCamera.TrackingState.notAvailable = frame.camera.trackingState { . . .
```

Convert pixel buffer to UIImage with ( you may need to lock and release pixel buffer manually ):
```
func pixelBufferToUIImage(_ buffer: CVPixelBuffer, options: [String: Any]? = nil) -> UIImage {
    let image = CIImage(cvPixelBuffer: buffer, options: options)
    return UIImage(ciImage: image)
}
```

## StereoscopicViewController
This is meant for as a template for reference. It creates to SCNViews side-by-side. It attaches *a single scene* to each of those views.
It then creates a node with a camera for each eye, and attaches that to a "head node". Each scene sets the *point of view* to the respective camera.

![dualcameras](http://i.imgur.com/xcfC66E.png)

```
enum StereoEye {
    case left, right
}
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
```

You can attach this to a view like so:
```
let scene = SCNScene(named: "art.scnassets/ship.scn")!
stereoView = StereoscopicSceneViewMaker()
stereoView?.attachStereoView(on: view, with: scene)
```

