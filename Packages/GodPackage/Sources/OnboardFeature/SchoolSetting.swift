import Colors
import ComposableArchitecture
import God
import GodClient
import Kingfisher
import RoundedCorner
import SwiftUI

public struct SchoolSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var schools: [God.SchoolsQuery.Data.Schools.Edge.Node] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case schoolButtonTapped(id: String)
    case schoolsResponse(TaskResult<God.SchoolsQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(id: String?)
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.schools() {
            await send(.schoolsResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.schoolsResponse(.failure(error)))
        }

      case let .schoolButtonTapped(id):
        return .send(.delegate(.nextScreen(id: id)))

      case let .schoolsResponse(.success(data)):
        state.schools = data.schools.edges.map(\.node)
        return .none

      case .schoolsResponse(.failure):
        state.schools = []
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct SchoolSettingView: View {
  let store: StoreOf<SchoolSettingLogic>

  public init(store: StoreOf<SchoolSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godService

        List(viewStore.schools, id: \.self) { school in
          Button {
            viewStore.send(.schoolButtonTapped(id: school.id))
          } label: {
            HStack(alignment: .center, spacing: 16) {
              KFImage
                .url(URL(string: school.profileImageURL))
                .placeholder {
                  ProgressView()
                }
                .onFailureImage(
                  Image(ImageResource.school)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .scaledToFit()
                    .clipped() as? KFCrossPlatformImage
                )
                .resizable()
                .frame(width: 40, height: 40)
                .scaledToFit()
                .clipped()

              VStack(alignment: .leading) {
                Text(school.name)
                  .bold()
                  .lineLimit(1)

                Text(school.shortName)
                  .foregroundColor(Color.godTextSecondaryLight)
              }
              .font(.footnote)
              .frame(maxWidth: .infinity, alignment: .leading)

              VStack(spacing: 0) {
                Text(school.usersCount.description)
                  .bold()
                  .foregroundColor(Color.godService)
                Text("MEMBERS")
                  .foregroundColor(Color.godTextSecondaryLight)
              }
              .font(.footnote)
            }
          }
        }
        .listStyle(.plain)
        .foregroundColor(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
      }
      .task { await viewStore.send(.onTask).finish() }
      .navigationTitle(Text("Pick your school", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
}

struct SchoolSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SchoolSettingView(
        store: .init(
          initialState: SchoolSettingLogic.State(),
          reducer: { SchoolSettingLogic() }
        )
      )
    }
  }
}
