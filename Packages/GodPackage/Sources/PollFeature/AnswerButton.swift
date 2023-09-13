import ButtonStyles
import Colors
import SwiftUI
import CoreHaptics

public struct AnswerButton: View {
  let title: String
  let progress: Double
  let action: () -> Void
  
  @State var engine: CHHapticEngine?
  let haptics = [
      Haptic(intensity: 0.5, sharpness: 0.5, interval: 0.0),
      Haptic(intensity: 0.5, sharpness: 0.5, interval: 0.1)
  ]

  public init(
    _ title: String,
    progress: Double,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.progress = progress
    self.action = action
  }
  
  struct Haptic: Hashable {
      var intensity: CGFloat
      var sharpness: CGFloat
      var interval: CGFloat
  }

  public var body: some View {
    Button {
      transientHaptic()
      action()
    } label: {
      Text(verbatim: title)
        .bold()
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundColor(.black)
        .background(
          GeometryReader { proxy in
            HStack(spacing: 0) {
              Color.godGreenLight
                .frame(width: proxy.size.width * progress)
              Color.white
            }
            .animation(.easeIn(duration: 0.2), value: progress)
          }
        )
        .cornerRadius(8)
    }
    .buttonStyle(HoldDownButtonStyle())
    .shadow(color: .black.opacity(0.2), radius: 25)
    .onAppear {
      prepare()
    }
  }
  
  func transientHaptic() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
      var events = [CHHapticEvent]()
      let hapticIntensity: [CGFloat] = haptics.map { $0.intensity }
      let hapticSharpness: [CGFloat] = haptics.map { $0.sharpness }
      let intervals: [CGFloat] = haptics.map({ $0.interval })
      
      for index in 0..<haptics.count {
          let relativeInterval: TimeInterval = TimeInterval(intervals[0...index].reduce(0, +))
          let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(hapticIntensity[index]))
          let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(hapticSharpness[index]))
          let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: relativeInterval)
          events.append(event)
      }
  
      do {
          let pattern = try CHHapticPattern(events: events, parameters: [])
          let player = try engine?.makePlayer(with: pattern)
          try player?.start(atTime: CHHapticTimeImmediate)
      } catch {
          print("Failed to play pattern: (error.localizedDescription).")
      }
  }
  
  func prepare() {
      guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
  
      do {
          self.engine = try CHHapticEngine()
          try engine?.start()
      } catch {
          print("Error creating the engine: (error.localizedDescription)")
      }
      
      engine?.resetHandler = {
          print("Restarting haptic engine")
          do {
              try self.engine?.start()
          } catch {
              fatalError("Failed to restart the engine: (error)")
          }
      }
  }
}

struct AnswerButtonPreviews: PreviewProvider {
  static var previews: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(spacing: 16), count: 2),
      spacing: 16,
      content: {
        AnswerButton("Ariana Duclos", progress: 0.1, action: {})
        AnswerButton("Allie Yarbrough", progress: 0.3, action: {})
        AnswerButton("Abby Arambula", progress: 0.5, action: {})
        AnswerButton("Ava Griego", progress: 0.9, action: {})
      }
    )
    .padding()
    .background(Color.godGreen)
    .previewLayout(.sizeThatFits)
  }
}
