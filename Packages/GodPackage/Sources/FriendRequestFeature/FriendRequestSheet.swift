import BackgroundClearSheet
import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI

public struct FriendRequestSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case dismissButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
        
      case .dismissButtonTapped:
        return .run { _ in
          await self.dismiss()
        }
      }
    }
  }
}

public struct FriendRequestSheetView: View {
  let store: StoreOf<FriendRequestSheetLogic>

  public init(store: StoreOf<FriendRequestSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
          .onTapGesture {
            store.send(.dismissButtonTapped)
          }
        
        VStack(spacing: 18) {
          HStack {
            
            Spacer()
            
            Button {
              store.send(.dismissButtonTapped)
            } label: {
              Image(systemName: "chevron.down")
                .frame(width: 52, height: 52)
                .foregroundStyle(Color.secondary)
            }
          }
          Spacer()

          VStack(spacing: 4) {
            Text("Kevin Ding", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))

            Text("@coffeetoken", bundle: .module)
              .font(.system(.footnote, design: .rounded))
              .foregroundStyle(Color.secondary)
          }
          
          HStack(spacing: 0) {
            Image(ImageResource.star)
              .resizable()
              .frame(width: 24, height: 24)
            
            Text("1")
          }
          .foregroundStyle(Color.secondary)
          
          Button {
            
          } label: {
            Text("ADD", bundle: .module)
              .frame(width: 96, height: 34)
              .foregroundStyle(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
              .font(.system(.body, design: .rounded, weight: .bold))
          }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) {
          Color.blue
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay {
              RoundedRectangle(cornerRadius: 75)
                .stroke(Color.white, lineWidth: 4)
            }
            .offset(y: -75)
        }
      }
      .buttonStyle(HoldDownButtonStyle())
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  Color.red
    .ignoresSafeArea()
    .sheet(isPresented: .constant(true)) {
      FriendRequestSheetView(
        store: .init(
          initialState: FriendRequestSheetLogic.State(),
          reducer: { FriendRequestSheetLogic() }
        )
      )
      .presentationBackground(Color.clear)
    }
}
