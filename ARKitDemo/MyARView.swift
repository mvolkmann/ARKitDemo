import ARKit
import Combine
import RealityKit
import SwiftUI

class MyARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    // We must implement this initializer, but we will not call it directly.
    @available(*, unavailable)
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This is the init that we will actually use.
    convenience init() {
        // We want to fill the entire screen.
        self.init(frame: UIScreen.main.bounds)

        subscribeToActionStream()
    }

    private var cancellables: Set<AnyCancellable> = []
    private var football: MyFirst.Scene?

    func anchorExamples() {
        // Attach anchors at specific coordinates in the iPhone-centered coordinate system
        let coordinateAnchor = AnchorEntity(world: .zero)

        // Attach anchors to detected planes (this works best on devices with a LIDAR sensor)
        _ = AnchorEntity(plane: .horizontal)
        _ = AnchorEntity(plane: .vertical)

        // Attach anchors to tracked body parts, such as the face
        _ = AnchorEntity(.face)

        // Attach anchors to tracked images, such as markers or visual codes
        _ = AnchorEntity(.image(group: "group", name: "name"))

        // Add an anchor to the scene
        scene.addAnchor(coordinateAnchor)
    }

    // This is not currently called and is only here to provide example code.
    func configurationExamples() {
        // Tracks the device relative to it's environment (default)
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)

        // Not supported in all regions, tracks w.r.t. global coordinates
        // This relies on look-around data in Apple Maps.
        _ = ARGeoTrackingConfiguration()

        // Tracks faces in the scene
        _ = ARFaceTrackingConfiguration()

        // Tracks bodies in the scene
        _ = ARBodyTrackingConfiguration()
    }

    // This is not currently called and is only here to provide example code.
    // This is not currently called and is only here to provide example code.
    func entityExamples() {
        // Load an entity from a usdz file
        _ = try? Entity.load(named: "usdzFileName")

        // Load an entity from a reality file
        _ = try? Entity.load(named: "realityFileName")

        // Generate an entity with code
        let box = MeshResource.generateBox(size: 1)
        let entity = ModelEntity(mesh: box)

        // Add entity to an anchor, so it's placed in the scene
        let anchor = AnchorEntity()
        anchor.addChild(entity)
    }

    func placeBlock(ofColor color: Color) {
        let block = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        let entity = ModelEntity(mesh: block, materials: [material])

        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)

        scene.addAnchor(anchor)
    }

    func placeFootball() {
        do {
            // TODO: Can you load a single shape instead of the entire scene?
            let football = try MyFirst.loadScene()
            scene.addAnchor(football)
            self.football = football
        } catch {
            print("MyARView.placeSkateboard:", error)
        }
    }

    func subscribeToActionStream() {
        let stream = ARManager.shared.actionStream
        // The closure passed to the `sink` method is called
        // every time a new message is received.
        stream.sink { [weak self] action in
            switch action {
            case let .placeBlock(color):
                self?.placeBlock(ofColor: color)

            case .placeFootball:
                self?.placeFootball()

            case .playFootballAnimation:
                // kickFootball is the only "Notification" behavior.
                // moveFootball and jiggleFootball use other notification types.
                self?.football?.notifications.kickFootball.post()

            case .removeAllAnchors:
                self?.scene.anchors.removeAll()
            }
        }
        .store(in: &cancellables)
    }
}
