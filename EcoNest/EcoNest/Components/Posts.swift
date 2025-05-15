//
//  Posts.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

@ViewBuilder
func Posts(post: Post, user: User, communityId: String, viewModel: PostsListViewModel, isReplay: Bool = false, postId: String? = nil) -> some View {
    @EnvironmentObject var themeManager: ThemeManager
    VStack(alignment: .leading) {
        HStack(spacing: 16){
            VStack{
                if user.profileImage.isEmpty {
                    Image("profile")
                        .resizable()
                }  else if let imageURL = URL(string: user.profileImage){
                    WebImage(url: imageURL)
                        .resizable()
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(50)
            .background{
                Circle()
                    .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
            }
            
            VStack(alignment: .leading){
                Text(user.username)
                Text("\(post.timestamp.timeAgoDisplay())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
        VStack(alignment: .leading, spacing: 10) {
            
            ForEach(post.content.filter { !$0.lowercased().hasPrefix("http") }, id: \.self) { text in
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,5)
            }

            let images = post.content.filter { $0.lowercased().hasPrefix("http") }
            
            HStack {
                if images.count == 1 {
                    if let url = URL(string: images[0]) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipped()
                            .cornerRadius(10)
                    }
                } else if images.count == 2 {
                    ForEach(images.chunked(into: 2), id: \.self) {
                        rowItems in
                        HStack(alignment: .center, spacing: 5) {
                            ForEach(rowItems, id: \.self) { item in
                                if let url = URL(string: item) {
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 188, minHeight: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                } else {
                    ForEach(images.chunked(into: 2), id: \.self) {
                        rowItems in
                        VStack(alignment: .center, spacing: 5) {
                            ForEach(rowItems, id: \.self) { item in
                                if let url = URL(string: item) {
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 185, minHeight: 100)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        HStack(alignment: .center){
            
            Group{
                if post.likedByCurrentUser {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.callout)
                        .onTapGesture {
                            if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                viewModel.removeUserIDToFavorite(communityId: communityId, userId: userId, postId: post.id ?? "")
                            }
                            
                        }
                    
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .font(.body)
                        .onTapGesture {
                            if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                viewModel.addUserIDToFavorite(communityId: communityId, userId: userId, postId: post.id ?? "")
                            }
                        }
                }
                
                Text(post.likes.count == 0 ? "" : "\(post.likes.count)")
                    .font(.callout)
            }
            .frame(width: 10)
            
            Spacer()
            
            Group{
                Image(systemName: "message")
                    .foregroundColor(.gray)
                    .font(.callout)
                
                Text(post.numberOfReplies == 0 ? "" : "\(post.numberOfReplies)")
                    .font(.callout)
            }
            .frame(width: 10)
            
            Spacer()
            
            if post.userId == FirebaseManager.shared.auth.currentUser?.uid {
                Menu {
                    Button("Remove Post", role: .destructive) {
                        if isReplay {
                            viewModel.removeReplay(communityId: communityId, postId: postId ?? "", replayId: post.id ?? "")
                        } else {
                            viewModel.removePost(communityId: communityId, postId: post.id ?? "")
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
    //    .background{
    //        RoundedRectangle(cornerRadius: 10)
    //            .fill(.white)
    //            .stroke(.gray.opacity(0.3), lineWidth: 1)
    //            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
    //            .frame(maxWidth: .infinity)
    //    }
}
