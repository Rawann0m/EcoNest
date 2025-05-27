//
//  Posts.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A reusable SwiftUI view builder that renders a social media post with user details, post content, images, likes, and comments.
///
/// `Posts` displays a post and its associated user info, including text and images. It allows liking/unliking the post,
/// replying to it, and removing it (if the current user is the post author). The layout adapts to the number of images.
///
/// - Parameters:
///   - post: The `Post` model containing content, timestamp, likes, and replies.
///   - user: The `User` who created the post.
///   - communityId: The ID of the community where the post was published.
///   - viewModel: The `PostsListViewModel` used to manage state and handle actions.
///   - isReplay: A `Bool` indicating if the post is a reply (defaults to `false`).
///   - postId: Optional post ID used when handling replies.
struct Posts: View {
    let post: Post
    let user: User
    let communityId: String
    @ObservedObject var viewModel: PostsListViewModel
    let isReplay: Bool
    let postId: String?

    var body: some View {
    VStack(alignment: .leading) {
        HStack(spacing: 16){
            VStack {
                if user.profileImage.isEmpty {
                    // Display default profile image
                    Image("profile")
                        .resizable()
                } else if let imageURL = URL(string: user.profileImage){
                    // Load profile image from URL
                    WebImage(url: imageURL)
                        .resizable()
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(50)
            .background {
                // Profile image border
                Circle()
                    .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
            }

            VStack(alignment: .leading){
                Text(user.username)
                // Show relative timestamp (e.g., "2h ago")
                Text("\(post.timestamp.timeAgoDisplay())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }

        VStack(alignment: .leading, spacing: 10) {
            // Show text-only content (excluding links)
            ForEach(post.content.filter { !$0.lowercased().hasPrefix("http") }, id: \.self) { text in
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,5)
            }

            // Filter and display images from content
            let images = post.content.filter { $0.lowercased().hasPrefix("http") }

            HStack {
                if images.count == 1 {
                    // Single image display
                    if let url = URL(string: images[0]) {
                        WebImage(url: url){ image in
                            image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                            .contentShape(Rectangle())
                            .cornerRadius(10)
                            .onTapGesture {
                                viewModel.selectedPic = images[0]
                                viewModel.showPic.toggle()
                            }
                        } placeholder:{
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300, alignment: .center)
                        }
                    }
                } else if images.count == 2 {
                    // Display 2 images in a row
                    ForEach(images.chunked(into: 2), id: \.self) { rowItems in
                        HStack(alignment: .center, spacing: 5) {
                            ForEach(rowItems, id: \.self) { item in
                                if let url = URL(string: item) {
                                    WebImage(url: url){ image in
                                        image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minHeight: 200, maxHeight: 250)
                                        .frame(width: (UIScreen.main.bounds.width - 25)/2)
                                        .clipped()
                                        .contentShape(Rectangle())
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            viewModel.selectedPic = item
                                            viewModel.showPic.toggle()
                                        }
                                } placeholder:{
                                       ProgressView()
                                        .frame(minHeight: 200, maxHeight: 250, alignment: .center)
                                        .frame(width: (UIScreen.main.bounds.width - 25)/2)
                                   }
                                }
                            }
                        }
                    }
                } else {
                    // Display multiple images in grid format
                    ForEach(images.chunked(into: 2), id: \.self) { rowItems in
                        VStack(alignment: .center, spacing: 5) {
                            ForEach(rowItems, id: \.self) { item in
                                if let url = URL(string: item) {
                                    WebImage(url: url){ image in
                                        image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minHeight: 100, maxHeight: 250)
                                        .frame(width: (UIScreen.main.bounds.width - 25)/2)
                                        .clipped()
                                        .contentShape(Rectangle())
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            viewModel.selectedPic = item
                                            viewModel.showPic.toggle()
                                        }
                                } placeholder:{
                                       ProgressView()
                                        .frame(minHeight: 100, maxHeight: 250, alignment: .center)
                                        .frame(width: (UIScreen.main.bounds.width - 25)/2)
                                   }
                                }
                            }
                        }
                    }
                }
            }
        }

        HStack(alignment: .center) {
            Group {
                if post.likedByCurrentUser {
                    // Filled heart if liked
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.callout)
                        .onTapGesture {
                            if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                viewModel.removeUserIDFromFavorite(
                                    communityId: communityId,
                                    userId: userId,
                                    postId: postId ?? "",
                                    replayId: post.id ?? "",
                                    isReply: isReplay
                                )
                            }
                        }
                } else {
                    // Empty heart if not liked
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .font(.body)
                        .onTapGesture {
                            if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                viewModel.addUserIDToFavorite(
                                    communityId: communityId,
                                    userId: userId,
                                    postId: postId ?? "",
                                    replayId: post.id ?? "",
                                    isReply: isReplay
                                )
                            }
                        }
                }

                // Like count
                Text(post.likes.count == 0 ? "" : "\(post.likes.count)")
                    .font(.callout)
            }
            .frame(width: 10)

            Spacer()

            // Message icon and reply count
            Group {
                Image(systemName: "message")
                    .foregroundColor(.gray)
                    .font(.callout)

                Text(post.numberOfReplies == 0 ? "" : "\(post.numberOfReplies)")
                    .font(.callout)
            }
            .frame(width: 10)

            Spacer()

            // Show menu for post owner
            if post.userId == FirebaseManager.shared.auth.currentUser?.uid {
                Menu {
                    Button("Remove Post", role: .destructive) {
                        if isReplay {
                            viewModel.removeReplay(
                                communityId: communityId,
                                postId: postId ?? "",
                                replay: post
                            )
                        } else {
                            viewModel.removePost(
                                communityId: communityId,
                                post: post
                            )
                        }
                        print("remove it")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .font(.callout)
                }
            }
        }
        .frame(maxWidth: 500)
        .padding(10)

     }
     .padding(.horizontal,10)
     .padding(.top, 10)
     .padding(.bottom, 0)

     Divider()
 }
}
