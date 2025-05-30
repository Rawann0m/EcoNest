# 🌿 EcoNest iOS App 

EcoNest is a feature-rich SwiftUI application for eco-conscious plant lovers.
It combines **plant recognition**, **community collaboration**, **shopping & checkout**, , and order management—including filtering orders by status such as awaiting pickup or canceled—all powered by **Firebase** (Auth, Firestore, Storage) and **Core ML**.

---

## 🚀 Key Highlights

* **Plant Identifier**: Binary + multiclass Core ML models with top-5 predictions, 3D model preview, and SceneKit rendering.
* **Shopping Experience**: Product discovery, cart & secure checkout, location-based pickups, and real-time stock tracking.
* **Community & Messaging**: Join themed communities, create posts, reply with images, and chat 1-on-1 with live read receipts.
* **Localization & Theme**: Full Arabic / English support, RTL/LTR layouts, and automatic dark-mode adaptation.
* **Secure Auth**: Firebase Auth with Keychain storage. 

---

## 📂 Table of Contents

1. [Architecture & Tech Stack](#architecture--tech-stack)
2. [Major Modules](#major-modules)
3. [Core ViewModels](#core-viewmodels)
4. [Important Views & Components](#important-views--components)
5. [Localization & Accessibility](#localization--accessibility)
6. [Authentication](#authentication)
7. [Firestore Data Model](#firestore-data-model)
8. [Roadmap / TODO](#roadmap--todo)
9. [License](#license)

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

## Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

### 🌱 Happy coding, and welcome to EcoNest!
