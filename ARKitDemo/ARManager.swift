import Combine

// The purpose of this class is to forward actions
// from a SwiftUI view (such as ContentView)
// to our custom ARView (MyARView) using Combine framework streams.
class ARManager {
    // This class is a singleton.
    static let shared = ARManager()
    private init() {}

    // ARAction is the type of the values that will be passed.
    // Never is the kind of errors that will be thrown (none in this case).
    var actionStream = PassthroughSubject<ARAction, Never>()
}
