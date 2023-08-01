import SwiftUI

public struct FullScreenCoverView<Content: View>: View {
  let onDismiss: (() -> Void)?
  let content: () -> Content
  
  public init(
    onDismiss: (() -> Void)? = nil,
    content: @escaping () -> Content
  ) {
    self.onDismiss = onDismiss
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()
      
      Button {
        onDismiss?()
      } label: {
        Image(systemName: "xmark")
          .foregroundColor(Color.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
          .padding(.horizontal, 16)
      }
      
      content()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 16)
    }
  }
}

struct FullScreenCoverViewPreviews: PreviewProvider {
  static var previews: some View {
    FullScreenCoverView {
      print("onDismiss")
    } content: {
      VStack(alignment: .center, spacing: 24) {
        Color.red
          .frame(width: 64, height: 64)
          .clipShape(Circle())
        
        Text("Share Profile on Instagram")
          .font(.title2)
          .bold()
        
        VStack(spacing: 0) {
          Text("Step 1")
            .font(.title3)
            .bold()
          
          Text("Copy your Gas link")
            .font(.title3)
        }
        
        Text("gasapp.co/@tomokisun")
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .foregroundColor(Color(uiColor: .darkGray))
          .background(Color(uiColor: .systemGray6))
          .clipShape(Capsule())
        
        Button(action: {}) {
          Text("Copy Link")
            .bold()
            .foregroundColor(.orange)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .overlay(
              RoundedRectangle(cornerRadius: 56 / 2)
                .stroke(Color.orange, lineWidth: 1)
            )
        }
        
        VStack(spacing:0) {
          Text("Step 1")
            .font(.title3)
            .bold()
          
          Text("Copy your Gas link")
            .font(.title3)
        }
        
        Button(action: {}) {
          Text("Share")
            .bold()
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .clipShape(Capsule())
        }
      }
      .padding(.all, 24)
    }
  }
}
