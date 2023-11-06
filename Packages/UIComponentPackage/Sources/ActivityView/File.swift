import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {
  public typealias UIViewControllerType = UIActivityViewController
  
  let activityViewController: UIActivityViewController
  
  public init(
    activityItemsConfiguration: UIActivityItemsConfigurationReading,
    completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
  ) {
    let activityViewController = UIActivityViewController(activityItemsConfiguration: activityItemsConfiguration)
    activityViewController.completionWithItemsHandler = completionWithItemsHandler
    self.activityViewController = activityViewController
  }
  
  public init(
    activityItems: [Any],
    applicationActivities: [UIActivity]?,
    completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
  ) {
    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    activityViewController.completionWithItemsHandler = completionWithItemsHandler
    self.activityViewController = activityViewController
  }
  
  public func makeUIViewController(context: Context) -> UIActivityViewController {
    return activityViewController
  }
  
  public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
  }
}

#Preview {
  Color.clear
    .sheet(isPresented: .constant(true)) {
      ActivityView(
        activityItems: [
          "tomokisun"
        ],
        applicationActivities: nil
      ) { activityType, result, _, error in
        print(activityType)
      }
      .presentationDetents([.medium, .large])
    }
}
