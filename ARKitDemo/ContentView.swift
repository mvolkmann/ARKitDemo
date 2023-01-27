import SwiftUI

struct ContentView: View {
    @State private var colors: [Color] = [.red, .green, .blue]
    private var stream = ARManager.shared.actionStream

    struct MyButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(width: 40, height: 40)
                .padding()
                .background(.regularMaterial) // provides a blur effect
                .cornerRadius(16)
        }
    }

    var buttonRow: some View {
        ScrollView(.horizontal) {
            HStack {
                Button("Place") {
                    stream.send(.placeFootball)
                }
                .modifier(MyButtonStyle())

                Button("Kick") {
                    stream.send(.playFootballAnimation)
                }
                .modifier(MyButtonStyle())

                Button {
                    stream.send(.removeAllAnchors)
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .modifier(MyButtonStyle())
                }

                ForEach(colors, id: \.self) { color in
                    Button {
                        stream.send(.placeBlock(color: color))
                    } label: {
                        color.modifier(MyButtonStyle())
                    }
                }
            }
            .padding()
        }
    }

    var body: some View {
        MyARViewRepresentable()
            .ignoresSafeArea() // so it can fill the entire screen
            .overlay(alignment: .bottom) {
                buttonRow
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
