# Swift Cache
A lightweight data model that loads content asyncronously while efficently handling concurrent duplicative requests.

### Use Swift Cache in your Project
Option A (simple, easy, no dependencies): Copy-and-paste [the file](https://github.com/Sid-MB/Swift-Cache/raw/main/Sources/Cache/Cache.swift) into your project.

Option B (auto-updating): Use Swift Package Manager. The library is available at:

```md
https://github.com/Sid-MB/Swift-Cache
```



### Example Usage

In a data model:
```swift
class DocumentsModel {

  // Set up the cache with the loading method.
  private var songsByArtist = Cache { artist in
    try await API.getSongs(for: artist)
  }


  // On the first request for an artist, songs are loaded from the server.
  // On subsequent requests, data is pulled instantly from the cache.
  func getSongs(for artist: Artist) async throws -> [Song] {
    return try await songsByArtist[artist]
  }
}
```

In a SwiftUI View:
```swift
struct CollaboratorsList: View {

  var collaboratorIDs: [User.Identifier]

  // No separate data model file needed.
  @StateObject private var userModel = Cache { userID in
    return try await API.getUser(id: userID)
  }

  var body: some View {
    ForEach(collaboratorIDs, id: \.self) { userID in
      VStack {
        // Retrieve user data from the cache.
        // When the data finishes loading in the background, the view will automatically update.
        if let user = userModel.retrieveIfAvailable(userID) {
          Text(user.name)
          Text(user.email)
        } else {
          ProgressView()
        }
      }
      .task {
        // Loads the user's data.
        try? await userModel[userID]
      }
    }
  }
}

```
