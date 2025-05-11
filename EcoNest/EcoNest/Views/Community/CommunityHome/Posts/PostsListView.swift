//
//  PostsListView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI

struct PostsListView: View {
    @State var showPostDetails: Bool = false
    @StateObject var viewModel = PostsViewModel()
    var communityId: String
    var body: some View {
        NavigationStack{
            if viewModel.posts.isEmpty {
                Text("No Posts found")
                    .frame(height: 300, alignment: .center)
            } else {
                LazyVStack {
                    //  ForEach(0..<20) { index in
                    Post(text: "🌱 Just repotted my monstera today! I noticed the roots were getting a bit cramped, so I upgraded to a bigger pot and added some fresh, well-draining soil. Fingers crossed she loves her new home! Any tips on how often I should water after repotting? 💧🪴")
                        .padding(.horizontal)
                        .onTapGesture {
                            showPostDetails.toggle()
                        }
                    // }
                }
            }
        }
        .onAppear{
            viewModel.getCommunityPosts(communityId: communityId)
        }
        .fullScreenCover(isPresented: $showPostDetails){
            PostDetailView(postText: "🌱 Just repotted my monstera today! I noticed the roots were getting a bit cramped, so I upgraded to a bigger pot and added some fresh, well-draining soil. Fingers crossed she loves her new home! Any tips on how often I should water after repotting? 💧🪴")
        }
    }
}

