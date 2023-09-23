import SwiftUI

public struct ImagePickerView: UIViewControllerRepresentable {
  public var sourceType: UIImagePickerController.SourceType
  
  public init(sourceType: UIImagePickerController.SourceType) {
    self.sourceType = sourceType
  }
  
  public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = sourceType
    return imagePicker
  }
  
  public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
  }
}
