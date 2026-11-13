# Firebase Todo List (iOS)

A simple todo list app for iOS built with **SwiftUI** and **Firebase**.
Mobile Computing Lab assignment.

## Features

- Sign up, log in and log out with **Firebase Authentication** (email & password)
- Each task has a **title** and a **description**
- Full **CRUD**:
  - **Create** a task with the `+` button
  - **Read** your tasks in a live-updating list
  - **Update** a task by tapping on it, or mark it done with the circle button
  - **Delete** a task by swiping left
- Tasks are stored in **Cloud Firestore** per user, so every user only sees their own tasks

## Tech Stack

- Swift / SwiftUI (MVVM)
- Firebase iOS SDK (added with Swift Package Manager)
  - FirebaseAuth
  - FirebaseFirestore
- Minimum iOS 16, Xcode 16 or newer

## Project Structure

```
FirebaseTodo/
├── FirebaseTodoApp.swift        # App entry, configures Firebase
├── Models/
│   └── TodoTask.swift           # Task model (title, description, isDone, createdAt)
├── ViewModels/
│   ├── AuthViewModel.swift      # Sign up / log in / log out
│   └── TaskViewModel.swift      # Firestore CRUD + realtime listener
└── Views/
    ├── ContentView.swift        # Shows login or task list depending on auth state
    ├── LoginView.swift
    ├── SignUpView.swift
    ├── TaskListView.swift
    └── TaskFormView.swift       # Used for both add and edit
firestore.rules                  # Firestore security rules
```

## Firestore Data Structure

```
users (collection)
 └── {uid} (document)
      └── tasks (collection)
           └── {taskId} (document)
                ├── title: string
                ├── description: string
                ├── isDone: bool
                └── createdAt: timestamp
```

## Setup

`GoogleService-Info.plist` is not included in this repo (it is in `.gitignore`), so you need to connect the app to your own Firebase project first.

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add an **iOS app** to the project. Use the bundle ID `com.shadowfax505.FirebaseTodo`
   (or change the bundle ID in Xcode to match whatever you register).
3. Download `GoogleService-Info.plist` and put it inside the `FirebaseTodo/` folder
   (the same folder as `FirebaseTodoApp.swift`). Xcode picks it up automatically.
4. In the Firebase Console:
   - **Authentication → Sign-in method** → enable **Email/Password**
   - **Firestore Database** → **Create database**
   - **Firestore Database → Rules** → paste the contents of [`firestore.rules`](firestore.rules) and click **Publish**
5. Open `FirebaseTodo.xcodeproj` in Xcode. Wait for Swift Package Manager to finish downloading the Firebase packages.
6. Select a simulator (e.g. iPhone 16) and press **Run** (⌘R).

If you want to run it on a real iPhone, select your Apple ID team under
**Signing & Capabilities**.

## Security Rules

The rules in `firestore.rules` make sure that a logged in user can only read and write
documents under `users/{their uid}/tasks`. Everything else is denied.

Or deploy them with the Firebase CLI: `firebase deploy --only firestore:rules`

## Troubleshooting

- **"Missing or insufficient permissions"**: the Firestore rules were not published, or you are not logged in.
- **App crashes on launch with a FirebaseApp error**: `GoogleService-Info.plist` is missing from the `FirebaseTodo/` folder.
- **"No such module FirebaseAuth"**: wait for the packages to resolve, or use **File → Packages → Reset Package Caches**.
