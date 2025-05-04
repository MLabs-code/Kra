# Kra

Swift package for interacting with the KRA.sk cloud storage API.

## Features

* User Authentication (login/logout)
* User Information retrieval
* File operations (list, download, and more)
* Folder operations (create, delete)

## Requirements

- iOS 12.0+ / macOS 10.13+
- Swift 5.5+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/MLabs-code/Kra.git", from: "1.0.0")
]
```

## Usage

### Initialization

```swift
let kra = Kra()
```

### Login

```swift
kra.login(username: "your_username", password: "your_password") { result in
    switch result {
    case .success(let sessionId):
        print("Successfully logged in with session ID: \(sessionId)")
    case .failure(let error):
        print("Login failed: \(error.localizedDescription)")
    }
}
```

### Get User Info

```swift
kra.getUserInfo(sessionId: sessionId) { result in
    switch result {
    case .success(let userInfo):
        print("User: \(userInfo.data.username)")
        print("Email: \(userInfo.data.email)")
    case .failure(let error):
        print("Getting user info failed: \(error.localizedDescription)")
    }
}
```

### List Files

```swift
kra.listFiles(sessionId: sessionId, folderIdent: nil) { result in
    switch result {
    case .success(let files):
        for file in files {
            print("File: \(file.data?.link ?? "")")
        }
    case .failure(let error):
        print("Listing files failed: \(error.localizedDescription)")
    }
}
```

### Download File

```swift
kra.fileLink(sessionId: sessionId, fileIdent: "file_id") { result in
    switch result {
    case .success(let filePath):
        if let url = filePath.urlLink {
            // Download the file from the URL
            print("File URL: \(url)")
        }
    case .failure(let error):
        print("Getting file link failed: \(error.localizedDescription)")
    }
}
```

### Logout

```swift
kra.logout(sessionId: sessionId) { result in
    switch result {
    case .success(_):
        print("Successfully logged out")
    case .failure(let error):
        print("Logout failed: \(error.localizedDescription)")
    }
}
```

## License

This package is available under the MIT license. See the LICENSE file for more info. 
