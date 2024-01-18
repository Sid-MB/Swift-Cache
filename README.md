# Swift Cache
A lightweight data model that loads content asyncronously while efficently handling concurrent duplicative requests.

### Example Usage

```swift
struct CollaboratorsList: View {

  var collaboratorIDs: [User.Identifier]

  // No separate Data Model file needed.
  @StateObject private var userModel = Cache { userID in
    return try await API.getUser(id: userID)
  }

  var body: some View {
    ForEach(collaboratorIDs, id: \.self) { userID in
      VStack {
        // Retrieve user data from the cache.
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

### Use Swift Cache
Option A: Use Swift Package Manager. The library is available at:

```md
https://github.com/Sid-MB/Swift-Cache
```

Option B: Copy-and-paste [the file](https://github.com/Sid-MB/Swift-Cache/raw/main/Sources/Cache/Cache.swift) into your project.
