# DevLoop

<p align="center">
  <img src="assets/branding/appicon.png" width="140" alt="DevLoop App Icon">
</p>

<h3 align="center">Connect. Learn. Build.</h3>

<p align="center">
  A professional social networking application built for developers to share knowledge, projects, experiences, achievements, and career updates.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44.8-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Cloudinary-Images-3448C5?logo=cloudinary" alt="Cloudinary">
  <img src="https://img.shields.io/badge/Architecture-Simple%20Clean-4F46E5" alt="Architecture">
</p>

---

## About DevLoop

DevLoop is a developer-focused social networking application designed to create a dedicated space where developers can connect, learn from each other, share technical knowledge, showcase projects, discuss experiences, and build professional connections.

The application combines the familiar social interaction model of modern social platforms with features specifically designed around the developer community.

DevLoop focuses on:

- Developer networking
- Technical knowledge sharing
- Project publishing
- Career updates
- Professional profiles
- Developer discovery
- Social interactions
- Notifications
- Responsive mobile UI

The application is built with Flutter and Firebase while using Cloudinary for image hosting.

---

## The Idea

Developers often use multiple platforms to learn, showcase projects, communicate, and build their professional network.

DevLoop brings these activities together in one developer-oriented social environment.

Users can create professional profiles, publish different types of developer content, react to posts, comment and reply, follow other developers, search for developers, and receive notifications about relevant interactions.

The application is designed to be expandable, allowing additional developer-focused features to be introduced in future versions.

---

# Features

## 1. Splash Screen

The Splash Screen provides the first visual experience when the application starts.

It introduces the DevLoop branding while the application initializes its required services and prepares the initial navigation flow.

### Highlights

- DevLoop branding
- Clean startup experience
- Application initialization
- Smooth transition to the next screen

<p align="center">
  <img src="assets/README/01_splash.png" width="300" alt="DevLoop Splash Screen">
</p>

---

## 2. Onboarding

The onboarding experience introduces users to the main concept of DevLoop before they start using the application.

It explains the application's core purpose and guides new users toward the authentication flow.

### Highlights

- Developer-focused introduction
- Simple onboarding experience
- Clear application identity
- Easy transition to authentication

<p align="center">
  <img src="assets/README/02_onboarding.png" width="300" alt="DevLoop Onboarding">
</p>

---

## 3. Authentication

DevLoop uses Firebase Authentication to manage user accounts securely.

The authentication system provides the foundation for protected application features such as profiles, posts, following, comments, reactions, and notifications.

### Highlights

- Firebase Authentication
- User account management
- Secure login flow
- Registration flow
- Password recovery
- Authentication state handling

---

## 4. Login

The Login screen allows registered developers to access their DevLoop accounts.

Users can authenticate using their email address and password.

### Highlights

- Email authentication
- Password authentication
- Validation
- Error handling
- Navigation after successful authentication

<p align="center">
  <img src="assets/README/03_login.png" width="300" alt="DevLoop Login Screen">
</p>

---

## 5. Register

The Register screen allows new developers to create their DevLoop accounts.

During registration, the application creates the authentication account and prepares the user's developer profile.

### Highlights

- New account creation
- Email validation
- Password validation
- User information handling
- Firebase Authentication integration

<p align="center">
  <img src="assets/README/04_register.png" width="300" alt="DevLoop Register Screen">
</p>

---

## 6. Forgot Password

DevLoop provides a password recovery flow for users who forget their account password.

The application uses Firebase Authentication to send the password reset process to the user's registered email address.

### Highlights

- Password recovery
- Email-based reset flow
- Firebase Authentication integration
- Validation and error handling

<p align="center">
  <img src="assets/README/05_forgot_password.png" width="300" alt="DevLoop Forgot Password">
</p>

---

## 7. Home Feed

The Home Feed is the main social experience of DevLoop.

It displays developer posts in a scrolling feed where users can discover technical content, projects, questions, career updates, experiences, and achievements.

### Supported Post Types

- Knowledge
- Project
- Career
- Experience
- Question
- Achievement

### Highlights

- Dynamic developer feed
- Post cards
- Developer information
- Post categories
- Images
- Reactions
- Comments
- Replies
- Social interactions

<p align="center">
  <img src="assets/README/06_home.png" width="300" alt="DevLoop Home Feed">
</p>

---

## 8. Create Post

Developers can create new posts and share their content with the DevLoop community.

The Create Post experience allows the user to select the appropriate post type and provide the content that should appear on the feed.

### Supported Content

- Knowledge
- Projects
- Career updates
- Experiences
- Questions
- Achievements
- Images

### Highlights

- Post type selection
- Text content
- Image selection
- Cloudinary image upload
- Firestore post creation
- Form validation

<p align="center">
  <img src="assets/README/07_create_post.png" width="300" alt="DevLoop Create Post">
</p>

---

## 9. Edit Post

Developers can edit their existing posts after publishing them.

The editing process allows users to update their post content while keeping the existing post data and social interactions connected to the post.

### Highlights

- Edit existing content
- Update post information
- Preserve post identity
- Firestore integration
- Validation

---

## 10. Post Images

DevLoop supports image attachments inside posts.

Instead of storing large image files directly inside Firestore, images are uploaded to Cloudinary and the resulting image information is stored with the post.

### Image Flow

    Flutter Application
            |
            v
      Select Image
            |
            v
        Cloudinary
            |
            v
      Image URL + Public ID
            |
            v
        Firestore
            |
            v
       Display Image

### Stored Information

A post can store information such as:

- Image URL
- Cloudinary Public ID
- Post metadata

This approach keeps Firestore focused on application data while Cloudinary handles image hosting.

---

## 11. Post Reactions

Users can interact with posts using different reaction types.

DevLoop supports multiple reactions to make social interaction more expressive than a simple like system.

### Available Reactions

- Like ❤️
- Support 👍
- Haha 😂
- Wow 😮
- Angry 😡

### Highlights

- Reaction selection
- Reaction updates
- Reaction removal
- Reaction counts
- Firebase Firestore integration
- Real-time social interaction

<p align="center">
  <img src="assets/README/08_post_reactions.png" width="300" alt="DevLoop Post Reactions">
</p>

---

## 12. Comments

Users can comment on posts and participate in technical discussions.

Comments are stored as part of the post's data structure and are connected directly to the original post.

### Highlights

- Add comments
- Display comments
- Delete own comments
- Comment interaction
- Firestore integration

<p align="center">
  <img src="assets/README/09_comments.png" width="300" alt="DevLoop Comments">
</p>

---

## 13. Replies

DevLoop supports replies to comments to make discussions more organized.

Instead of keeping every response at the same level, users can directly respond to another user's comment.

### Highlights

- Reply to comments
- Nested discussion flow
- Developer interaction
- Firestore subcollections
- Organized conversations

---

## 14. Comment Reactions

Comments can also receive reactions.

This allows developers to react directly to useful answers, opinions, explanations, and other discussion content.

### Available Reactions

- Like ❤️
- Support 👍
- Haha 😂
- Wow 😮
- Angry 😡

### Highlights

- React to comments
- Change reactions
- Remove reactions
- Reaction counts
- Firestore integration

---

## 15. Follow / Unfollow

Developers can follow other developers to build their professional network.

Following a developer allows users to create connections around the people and content they are interested in.

### Highlights

- Follow developers
- Unfollow developers
- Follow state management
- Firestore integration
- Connection tracking

The follow system is designed to support future networking features.

---

## 16. Followers / Following

Developer profiles can represent social connections through followers and following relationships.

The system keeps track of:

- Developers a user follows
- Developers following the user
- Following state
- Connection relationships

This structure provides the foundation for future networking and personalized content features.

---

## 17. Developer Search

DevLoop includes developer discovery functionality that allows users to search for other developers.

The search experience is designed specifically around developer profiles rather than general social content.

### Highlights

- Developer search
- Search by user information
- Developer profile discovery
- Quick navigation to profiles
- Firestore integration

<p align="center">
  <img src="assets/README/10_search.png" width="300" alt="DevLoop Developer Search">
</p>

---

## 18. Notifications

DevLoop provides a notification system to keep users informed about relevant activity.

Notifications can represent important interactions related to the user's social activity.

### Notification Examples

- New followers
- Post interactions
- Comment interactions
- Reply interactions
- Other social events

The notification system is connected to Firestore and provides a centralized place for user activity updates.

<p align="center">
  <img src="assets/README/11_notifications.png" width="300" alt="DevLoop Notifications">
</p>

---

## 19. Developer Profiles

Each developer has a dedicated professional profile.

The profile is designed to provide a clear overview of the developer and their activity within DevLoop.

### Profile Information

Depending on the available profile data, developers can present information such as:

- Profile image
- Name
- Bio
- Professional information
- Developer activity
- Followers
- Following
- Posts

### Highlights

- Professional developer identity
- User posts
- Social connections
- Profile information
- Developer-focused presentation

<p align="center">
  <img src="assets/README/12_profile.png" width="300" alt="DevLoop Developer Profile">
</p>

---

## 20. Edit Profile

Developers can update their profile information from the Edit Profile screen.

This allows users to keep their professional information current.

### Highlights

- Update profile information
- Update profile image
- Edit bio
- Manage personal information
- Cloudinary image integration
- Firestore profile updates

<p align="center">
  <img src="assets/README/13_edit_profile.png" width="300" alt="DevLoop Edit Profile">
</p>

---

## 21. Logout

Users can securely sign out from their DevLoop accounts.

The logout process clears the current authentication session and returns the user to the authentication flow.

### Highlights

- Firebase sign-out
- Authentication state update
- Session termination
- Navigation to authentication screens

---

## 22. Responsive UI

DevLoop is designed with responsive layouts to provide a consistent experience across different mobile screen sizes.

Flutter ScreenUtil is used with a design reference of:

    Width: 390
    Height: 844

The interface uses responsive sizing for:

- Padding
- Margins
- Font sizes
- Icons
- Component dimensions
- Spacing

The goal is to maintain a consistent visual hierarchy across supported devices.

---

## 23. Bottom Navigation

DevLoop uses bottom navigation as the primary way to move between the application's main sections.

The navigation structure provides quick access to the most important areas of the application while keeping the interface simple and familiar.

### Highlights

- Fast navigation
- Persistent navigation experience
- Clean mobile layout
- Main application sections
- Consistent UI behavior

---

# Application Walkthrough

DevLoop follows a simple user journey:

    Splash Screen
          |
          v
      Onboarding
          |
          v
    Authentication
       /       \
      /         \
Login       Register
\         /
\       /
Home Feed
|
+------+------+----------------+
|      |      |                |
Posts  Search Profile       Notifications
|
+----------------+
|                |
Create            Edit
|
v
Social Interaction
|
+---------+----------+
|         |          |
Reactions Comments   Follow
|
Replies

The application is structured so that authentication leads into the main developer social experience, while the individual features remain separated and maintainable.

---

# Architecture

DevLoop follows a **Simple Clean Architecture** approach.

The project intentionally avoids an unnecessary Domain Layer and focuses on two primary layers:

- Data
- Presentation

The main responsibility flow is:

    UI
     |
     v
Cubit
|
v
Repository
|
v
Data Source
|
v
Firebase / Cloudinary

This structure keeps the application organized without introducing unnecessary abstraction for the current project scope.

---

## Presentation Layer

The Presentation Layer contains the application's user interface and state management.

It includes:

- Screens
- Widgets
- Cubits
- States
- UI models where required

Cubit handles application state and coordinates actions between the UI and repositories.

The UI does not directly communicate with Firebase or Cloudinary.

---

## Data Layer

The Data Layer handles external data operations.

It contains:

- Repository contracts
- Repository implementations
- Data sources
- Models
- Firebase operations
- Cloudinary operations

This keeps infrastructure-specific code outside the UI.

---

## Repository Pattern

Repositories provide an abstraction between the Presentation Layer and the Data Layer.

The general flow is:

    Screen
       |
       v
     Cubit
       |
       v
Repository
|
v
Data Source
|
v
Firebase / Cloudinary

This makes the code easier to maintain and allows data-related logic to remain separated from UI logic.

---

# Data Flow

A typical DevLoop operation follows this structure:

    User Interaction
          |
          v
       Flutter UI
          |
          v
        Cubit
          |
          v
      Repository
          |
          v
      Data Source
          |
          v
Firebase / Cloudinary
|
v
Result
|
v
Cubit
|
v
Updated State
|
v
Flutter UI

For example, creating a post follows:

    Create Post Screen
            |
            v
        CreatePostCubit
            |
            v
      Post Repository
            |
            v
       Post Data Source
            |
            +------------------+
            |                  |
            v                  v
        Cloudinary          Firestore
            |                  |
            +--------+---------+
                     |
                     v
                Post Created
                     |
                     v
                Updated UI

---

# Firebase Integration

Firebase provides the backend services required by DevLoop.

The application uses Firebase for:

- Authentication
- Cloud Firestore
- User data
- Posts
- Comments
- Replies
- Reactions
- Followers
- Following
- Notifications

Firebase allows the application to provide backend functionality without requiring a separate custom server for the current application scope.

---

# Firestore Structure

The application uses Cloud Firestore as its primary database.

The conceptual structure includes:

    users
      └── userId

    posts
      └── postId
          ├── comments
          │     └── commentId
          │           └── reactions
          │
          └── reactions

    notifications
      └── notificationId

    follows
      └── followId

The exact implementation can evolve as the application grows.

---

## Users

The users collection contains developer profile information.

Typical information can include:

- User ID
- Name
- Email
- Profile image
- Bio
- Professional information
- Followers information
- Following information

---

## Posts

Posts contain the main developer-generated content.

A post can include:

- Author ID
- Author information
- Content
- Post type
- Image URL
- Image Public ID
- Creation timestamp
- Updated timestamp
- Reaction information
- Comment information

---

## Comments

Comments are associated with their parent posts.

Comments can contain:

- Comment ID
- User ID
- Content
- Creation timestamp
- Parent post ID
- Reaction information

Replies can be associated with the relevant comment.

---

## Notifications

Notifications provide a centralized activity feed for users.

A notification can contain:

- Notification ID
- Receiver ID
- Actor ID
- Notification type
- Related content ID
- Read state
- Timestamp

---

# Cloudinary Integration

Cloudinary is used for image hosting.

The application does not store image files directly inside Firestore.

The image flow is:

    Select Image
         |
         v
    Flutter App
         |
         v
     Cloudinary
         |
         +------------------+
         |                  |
         v                  v
     Image URL          Public ID
         |                  |
         +--------+---------+
                  |
                  v
              Firestore

Firestore stores the references required to display and manage the image.

### Benefits

- Dedicated image hosting
- Smaller Firestore documents
- CDN-based image delivery
- Easy image URL retrieval
- Public ID support for image management

Sensitive Cloudinary credentials must remain outside the Flutter client.

---

# State Management

DevLoop uses **flutter_bloc / Cubit** for state management.

Cubit is responsible for handling application state and coordinating user actions.

Examples of Cubit responsibilities include:

- Authentication state
- Login
- Registration
- Password recovery
- Posts
- Creating posts
- Editing posts
- Reactions
- Comments
- Replies
- Following
- Search
- Notifications
- Profile updates

The UI reacts to Cubit states instead of directly controlling backend operations.

---

# Dependency Injection

DevLoop uses dependency injection to manage application dependencies.

The project uses:

- GetIt
- Injectable
- Injectable Generator
- Build Runner

Dependency injection helps avoid creating backend services and repositories directly inside screens.

The general dependency flow is:

    Data Source
        |
        v
    Repository
        |
        v
      Cubit
        |
        v
        UI

Dependencies can be registered and resolved through the application's dependency injection setup.

---

# Responsive Design

The application uses **Flutter ScreenUtil** for responsive sizing.

The main design reference is:

    390 × 844

ScreenUtil is used to adapt dimensions across different screen sizes while keeping the original design proportions consistent.

Responsive behavior is considered for:

- Screen padding
- Card dimensions
- Text sizes
- Icons
- Spacing
- Images
- Buttons
- Navigation elements

---

# Design System

DevLoop uses a clean professional visual identity designed around a modern developer-oriented interface.

## Color Palette

    Primary Indigo     #4F46E5
    Primary Dark       #3730A3
    Violet             #8B5CF6
    Background         #F7F8FC
    Surface            #FFFFFF
    Text Primary       #0F172A
    Text Secondary     #64748B
    Muted              #94A3B8
    Border             #E2E8F0
    Success            #16A34A
    Error              #DC2626
    Warning            #F59E0B

The visual system focuses on:

- Clear hierarchy
- Comfortable spacing
- Readability
- Consistent cards
- Consistent buttons
- Developer-oriented aesthetics
- Responsive layouts

---

# Project Structure

DevLoop follows a feature-oriented project structure.

    lib/
    │
    ├── core/
    │   ├── constants/
    │   ├── errors/
    │   ├── network/
    │   ├── services/
    │   ├── theme/
    │   └── utils/
    │
    ├── features/
    │   │
    │   ├── auth/
    │   │   ├── data/
    │   │   └── presentation/
    │   │
    │   ├── posts/
    │   │   ├── data/
    │   │   └── presentation/
    │   │
    │   ├── comments/
    │   │   ├── data/
    │   │   └── presentation/
    │   │
    │   ├── search/
    │   │   ├── data/
    │   │   └── presentation/
    │   │
    │   ├── notifications/
    │   │   ├── data/
    │   │   └── presentation/
    │   │
    │   └── profile/
    │       ├── data/
    │       └── presentation/
    │
    ├── firebase_options.dart
    └── main.dart

Each feature is organized around its own responsibilities to keep the codebase maintainable as the application grows.

---

# Tech Stack

## Frontend

- Flutter
- Dart
- Material Design
- Flutter ScreenUtil

## State Management

- flutter_bloc
- Cubit
- Equatable

## Backend

- Firebase Authentication
- Cloud Firestore

## Image Hosting

- Cloudinary

## Dependency Injection

- GetIt
- Injectable
- Injectable Generator

## Code Generation

- Build Runner

## Navigation and UI

- Flutter navigation
- Google Nav Bar
- Responsive UI components

---

# Getting Started

## Prerequisites

Make sure Flutter and Dart are installed and configured correctly on your development machine.

Recommended environment:

    Flutter 3.44.8
    Dart 3.12.2

## Installation

Clone the project and move into the project directory.

Then install Flutter dependencies:

    flutter pub get

Run code generation:

    dart run build_runner build --delete-conflicting-outputs

Run the application:

    flutter run

The project also requires the Firebase configuration used by the application.

---

# Security

Security is an important part of the application's architecture.

The Flutter application should never contain private server-side credentials or secrets.

Important principles include:

- Firebase Authentication handles user authentication.
- Firestore Security Rules should control database access.
- Cloudinary credentials must be configured safely.
- Sensitive API secrets should never be exposed in Flutter client code.
- Users should only be allowed to modify resources they are authorized to modify.
- Authentication state should be checked before accessing protected features.

Production deployment should include a complete review of Firebase Security Rules and Cloudinary configuration.

---

# Development Workflow

DevLoop is developed using a feature-based workflow.

A typical feature implementation follows:

    Requirement
        |
        v
    UI Design
        |
        v
    Model
        |
        v
    Data Source
        |
        v
    Repository
        |
        v
    Cubit / State
        |
        v
    UI Integration
        |
        v
    Testing
        |
        v
    Git Commit
        |
        v
    GitHub

This workflow keeps each feature separated and makes collaboration easier.

---

# GitHub Workflow

The project is designed to work with Git and GitHub for version control.

A typical workflow is:

    git pull
        |
        v
    Develop Feature
        |
        v
    Test Application
        |
        v
    git add .
        |
        v
    git commit
        |
        v
    git push

Feature development should be isolated whenever possible to reduce conflicts between team members.

---

# Project Status

## Completed

- Splash Screen
- Onboarding
- Authentication
- Login
- Registration
- Forgot Password
- Profile
- Edit Profile
- Developer Search
- Follow / Unfollow
- Posts
- Create Post
- Edit Post
- Post Images
- Post Reactions
- Comments
- Replies
- Comment Reactions
- Notifications
- Bottom Navigation
- Cloudinary Integration
- Firebase Integration
- Responsive UI

The current version provides the core foundation of a developer-focused social networking application.

---

# Future Vision

DevLoop is designed to grow beyond its current feature set.

Future development may include:

## Developer Jobs

A dedicated space for developers to discover relevant job opportunities and career-related content.

## Project Showcases

A more advanced project showcase system where developers can present their applications, technologies, GitHub repositories, demos, and project descriptions.

## Saved Posts

Users could save useful technical posts and return to them later.

## Direct Messaging

Private developer-to-developer communication could be introduced in a future version.

## Developer Communities

Specialized communities could allow developers with similar interests or technologies to interact in focused spaces.

Examples could include:

- Flutter
- AI
- Backend
- Frontend
- DevOps
- Cybersecurity
- Data Science

## Technical Events

Future versions could include developer events, workshops, conferences, and technical meetups.

## AI-Powered Developer Tools

AI capabilities could eventually be introduced to assist developers with technical content, productivity, learning, and career-related workflows.

## Career Features

Future career functionality could include:

- Developer portfolios
- Skills
- Certifications
- Experience
- Career progress
- Professional opportunities

## Advanced Developer Networking

The long-term vision is to create a more complete professional networking environment specifically designed around developers and technology professionals.

---

# Why DevLoop?

DevLoop is built around a simple idea:

    Connect.
    Learn.
    Build.

The application provides developers with a dedicated environment for sharing technical knowledge, showcasing work, discovering other developers, and building professional connections.

The architecture is intentionally structured so that new features can be added without requiring a complete rewrite of the existing application.

---

# Developer

<p align="center">
  <strong>Eng Mohamed Waleed</strong>
</p>

<p align="center">
  Flutter Developer • AI Student • Software Developer
</p>

<p align="center">
  Building mobile applications with Flutter and exploring AI, software engineering, and modern application architecture.
</p>

---

# License

This project is developed as a software project by Eng Mohamed Waleed.

The repository and its contents should be used according to the project's applicable license and repository permissions.

---

<p align="center">
  <strong>DevLoop</strong>
</p>

<p align="center">
  Connect. Learn. Build.
</p>

<p align="center">
  Built with Flutter, Firebase, Cloudinary, and a developer-first mindset.
</p>