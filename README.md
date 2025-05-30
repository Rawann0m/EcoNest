# 🌿 EcoNest iOS App 

EcoNest is a feature-rich SwiftUI application for eco-conscious plant lovers.
It combines **plant recognition**, **community collaboration**, **shopping & checkout**, , and order management—including filtering orders by status such as awaiting pickup or canceled—all powered by **Firebase** (Auth, Firestore, Storage) and **Core ML**.

---

## Demo & User Journey

- 📱 **[App Demo](https://drive.google.com/file/d/1UG76WbRLJg7LBb5oUjzaycftVdRRKygL/view?usp=drive_link)** 
- 🎥 **[User Journey Walkthrough](https://drive.google.com/file/d/1wO7a6RhrIMGlbA8CHcAKv5AhUmWXlROZ/view?usp=drive_link)** 

---

## 🚀 Key Highlights

* **Plant Identifier**: Binary + multiclass Core ML models with top-5 predictions, 3D model preview, and SceneKit rendering.
* **Shopping Experience**: Product discovery, cart & secure checkout, location-based pickups, and real-time stock tracking.
* **Community & Messaging**: Join themed communities, create posts, reply with images, and chat 1-on-1 with live read receipts.
* **Localization & Theme**: Full Arabic / English support, RTL/LTR layouts, and automatic dark-mode adaptation.
* **Secure Auth**: Firebase Auth with Keychain storage.

---

## 📂 Table of Contents

1. [Preview & Screenshots](#preview--screenshots)  
2. [Architecture & Tech Stack](#architecture--tech-stack)  
3. [Major Modules](#major-modules)  
4. [Core ViewModels](#core-viewmodels)  
5. [Important Views & Components](#important-views--components)  
6. [Localization & Accessibility](#localization--accessibility)  
7. [Authentication](#authentication)  
8. [Firestore Data Model](#firestore-data-model)  
9. [Upcoming Enhancements](#upcoming-enhancements)  
10. [Developers](#developers)  
11. [Contributions](#contributions)  

---

## Preview & Screenshots

| Demo | Description |
|------|-------------|
| **Video Preview** | <a href="https://drive.google.com/file/d/1wO7a6RhrIMGlbA8CHcAKv5AhUmWXlROZ/view?usp=sharing">Watch a 1-min walkthrough</a> (capture of identifier, cart, and community features). |
| **Demo** | [Watch the full demo video](https://drive.google.com/file/d/1UG76WbRLJg7LBb5oUjzaycftVdRRKygL/view?usp=sharing) |
| **App ScreensShots** | <img src="https://github.com/user-attachments/assets/2f89143d-2364-4184-b61b-18c3b5249298" width="196" height="426"> <img src="https://github.com/user-attachments/assets/d0d7b128-4f0b-4f6e-a428-8f53dadc3861" width="196" height="426"> <img src="https://github.com/user-attachments/assets/ae7cd2db-2b95-4952-8f99-9f5efe79aca5" width="196" height="426"> <img src="https://github.com/user-attachments/assets/dc56a755-e913-4f4f-8eaa-0b43fd629b6d" width="196" height="426"> <img src="https://github.com/user-attachments/assets/d09698b3-2506-47f7-bfbe-c64550ff7cd8" width="196" height="426"> <img src="https://github.com/user-attachments/assets/0ecf2944-3b84-4f51-9055-2788b55091a8" width="196" height="426"> <img src="https://github.com/user-attachments/assets/20274419-45df-41d1-9cea-5e28d7499d89" width="196" height="426"> <img src="https://github.com/user-attachments/assets/c29c2132-f460-4e6f-9db1-57e1fee213b9" width="196" height="426"> <img src="https://github.com/user-attachments/assets/21b55974-dcd6-49e7-b255-09ecd60a8f55" width="196" height="426"> <img src="https://github.com/user-attachments/assets/bdb84039-f21f-48b5-b221-bc8e8cb106b4" width="196" height="426"> <img src="https://github.com/user-attachments/assets/795c2bd7-a19b-42e0-8339-2bb2d063c822" width="196" height="426"> <img src="https://github.com/user-attachments/assets/de9dec9b-aefc-424e-91ed-c2900740137b" width="196" height="426"> <img src="https://github.com/user-attachments/assets/81a746cd-ae07-407c-af80-a4e21cab2052" width="196" height="426"> <img src="https://github.com/user-attachments/assets/ecfb7681-dab9-4f3b-bf8e-de36c33309b9" width="196" height="426"> <img src="https://github.com/user-attachments/assets/a37630a8-31ad-4c86-a5ae-4138d95378e4" width="196" height="426"> <img src="https://github.com/user-attachments/assets/8c874827-a3d2-4a60-80aa-2f4261b53919" width="196" height="426"> <img src="https://github.com/user-attachments/assets/ea4b9fd5-2c20-4e4d-a640-0fb5b1faa73f" width="196" height="426">|

---

## Architecture & Tech Stack

| Layer              | Technology / Library                           |
| ------------------ | ---------------------------------------------- |
| UI                 | **SwiftUI**, SceneKit, SDWebImageSwiftUI       |
| State / Logic      | ObservableObject view models, Combine          |
| ML Inference       | **Core ML**, Vision                            |
| Storage & Realtime | **Firebase** (Auth, Firestore, Storage)        |
| Secure Storage     | Apple **Keychain** via custom `KeychainHelper` |
| Maps               | MapKit (for pickup selection)                  |

---

## Major Modules

| #      | Module                        | Description                                                                             |
| ------ | ----------------------------- | --------------------------------------------------------------------------------------- |
| **1**  | **Home**                      | Auto-sliding low-stock carousel, product grid, search, add-to-cart.                     |
| **2**  | **Cart & Checkout**           | Edit quantities, choose pickup location/date, place orders with confirmation animation. |
| **3**  | **Location & Map**            | Full-screen map selector, preview card, integrated into checkout flow.                  |
| **4**  | **Order Management**          | Segmented control for active/cancelled orders; cancel awaiting orders.                  |
| **5**  | **Plant Identification**      | `PredictionView` pipeline → Core ML inference → 3D model viewer.                        |
| **6**  | **Plant Listing & Filtering** | `PlantsListView` with search + dynamic category filter sheet.                           |
| **7**  | **Products**                  | `AllProductsView`, `ProductDetailsView`, size variants, cart integration.               |
| **8**  | **Community**                 | Browse communities, join/leave, post feed, post details, member list.                   |
| **9**  | **Direct Messaging**          | Real-time 1-on-1 chat, image sending, unread tracking, last-seen markers.               |
| **10** | **Settings**                  | Profile editing, theme toggle, language picker, DM reception toggle, logout/delete, and a Customer Support button that opens our AI chatbot website for instant assistance.     |

---

## Core ViewModels

| File                            | Responsibility                                                    |
| ------------------------------- | ----------------------------------------------------------------- |
| `PlantViewModel.swift`          | Fetches `plantsDetails`, filters by categories & search text.     |
| `PredictionViewModel.swift`     | Two-step ML inference, alert handling, prediction results.        |
| `MLModelHandler.swift`          | Image preprocessing, Core ML & Vision requests, soft-max ranking. |
| `FavoritesViewModel.swift`      | Live Firestore listeners for favorite plants.                     |
| `ProductDetailsViewModel.swift` | Loads product info + size variants, add/remove cart logic.        |
| `CreatePostViewModel.swift`     | Uploads new community posts (text + max 4 images).                |
| `PostsListViewModel.swift`      | Real-time post & reply updates, like/delete actions.              |
| `ChatViewModel.swift`           | Sends/receives chat messages, marks read, updates recent threads. |
| `SettingsViewModel.swift`       | Reads/updates username, email, profile image, DM toggle.          |
| `DirectMessageViewModel.swift`  | Unread tracking & conversation deletion.                          |

---

## Important Views & Components

### Plant Identification

| View                                  | Purpose                                                      |
| ------------------------------------- | ------------------------------------------------------------ |
| `PredictionView`                      | Capture / pick photo → run detection → navigate to results.  |
| `PredictionResultView`                | Shows image + top-5 predictions with confidence bars.        |
| `SceneKitView` + `SceneKitLoaderView` | Download `.obj/.mtl/.png` assets and render 3D plant models. |

### Plant Listing & Filtering

| View             | Purpose                                      |
| ---------------- | -------------------------------------------- |
| `PlantsListView` | Search bar, filter button, list of plants.   |
| `FilterSheet`    | Modal sheet with dynamic category checklist. |

### Shopping

| View                                 | Purpose                                                 |
| ------------------------------------ | ------------------------------------------------------- |
| `AllProductsView`                    | Scrollable product list.                                |
| `ProductDetailsView`                 | Images, 3D view, size selector, price, add/remove cart. |
| `ProductRowCard` / `ProductSizeCard` | Reusable UI cells for product display.                  |

### Community & Messaging

| View                                 | Purpose                                     |
| ------------------------------------ | ------------------------------------------- |
| `CommunityAndMessagesView`           | Tab switcher between communities and chats. |
| `CommunityHomeView`                  | Posts vs. members tabs, join/leave button.  |
| `CreatePost` & `PostDetailView`      | Post creation and threaded replies.         |
| `DirectMessageListView` → `ChatView` | List of conversations → full chat UI.       |

### Miscellaneous

| Component                | Description                                        |
| ------------------------ | -------------------------------------------------- |
| `CustomRoundedRectangle` | Shape with individually-configurable corner radii. |
| `CameraManager`          | UIKit image picker wrapper.                        |
| `FireStoreUploader`      | One-off JSON importer for dev seeding.             |

---

## Localization & Accessibility

* **Languages**: Arabic & English (toggle saved in `@AppStorage("AppleLanguages")`).
* **Layout**: Automatic RTL/LTR for all views.
* **Strings**: `.localized(using:)` extension; sample keys: `SelectPhoto`, `Add`, `Remove`.
* **Themes**: Built-in dark/light colors (`DarkGreen`, `LimeGreen`, etc.) via `ThemeManager`.

---

## Authentication

* Firebase email/password sign-in.
* Credentials stored securely using `KeychainHelper`.
* Non-authenticated users are prompted with an alert when accessing favorites, cart, or checkout.

---

## Firestore Data Model

<details>
<summary>Cart Item</summary>

```json
// users/{userId}/cart/{cartItemId}
{
  "productId": "product123",
  "quantity": 2,
  "price": 35.0
}
```

</details>

<details>
<summary>Community Post</summary>

```json
// communities/{communityId}/posts/{postId}
{
  "userId": "user123",
  "content": "Which soil mix works best for succulents?",
  "images": ["posts/abc123.jpg"],
  "timestamp": 1716806400,
  "likes": ["user456", "user789"]
}
```

</details>

---

## Upcoming Enhancements

* [ ] **Offline Support**: Enable key features without internet.
* [ ] **Push Notifications**: Get notified of order updates and community interactions.
* [ ] **AI Model Improvements**: Retrain the plant classifier on larger and more diverse datasets for enhanced accuracy.

---

## Developers

| Name | Contact |
| ---- | ------- |
| **Abdullah Hafiz** | [GitHub](https://github.com/AbdullahHafiz30) · [LinkedIn](https://www.linkedin.com/in/abdullah-hafiz30/) |
| **Naif Almutairi** | [GitHub](https://github.com/NaifGhannam) · [LinkedIn](https://www.linkedin.com/in/naif-almutairi-5283121b2/) |
| **Rawan Majed** | [GitHub](https://github.com/Rawann0m) · [LinkedIn](https://www.linkedin.com/in/rawan-majed0/) |
| **Tahani Alhawsah** | [GitHub](https://github.com/Tahani50) · [LinkedIn](https://www.linkedin.com/in/tahani-alhawsah/) |
| **Rayaheen Mseri** | [GitHub](https://github.com/RayaheenMseri) · [LinkedIn](https://www.linkedin.com/in/rayaheenmseri/) |

---

## Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

## Team

Rawan Majed Alraddadi iOS Developer | AI | SwiftUI Enthusiast 📧 [https://github.com/Rawann0m]

Rayaheen Taofig Mseri IOS Developer | SwiftUI Enthusiast 📧 [https://github.com/RayaheenMseri]

Tahani Ayman IOS Developer | SwiftUI Enthusiast 📧 [https://github.com/Tahani50]

Naif Ghannam Saleh Almutairi iOS Developer | Data Scientist | SwiftUI Enthusiast 📧 [https://github.com/NaifGhannam]

Abdullah Mohammed Hafiz iOS Developer | Data Scientist | AI 📧 [https://github.com/AbdullahHafiz30]

---

### 🌱 Happy coding, and welcome to EcoNest!
