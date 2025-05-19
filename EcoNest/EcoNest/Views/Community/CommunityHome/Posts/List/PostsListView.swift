//
//  PostsListView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI

struct PostsListView: View {
    @State var showPostDetails: Bool = false
    @ObservedObject var viewModel: PostsListViewModel
    var communityId: String
    @State private var savedId: String?
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            if viewModel.isLoading{
                ProgressView()
                    .frame(height: 300, alignment: .center)
            } else {
                if viewModel.posts.isEmpty {
                    Text("NoPostsfound".localized(using: currentLanguage))
                        .frame(height: 300, alignment: .center)
                } else {
                    ScrollViewReader{ scrollProxy in
                        LazyVStack {
                            ForEach(viewModel.posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })) { post in
                                if let user = post.user {
                                    Posts(post: post, user: user, communityId: communityId, viewModel: viewModel)
                                        .onTapGesture {
                                            viewModel.selectedPost = post
                                            showPostDetails.toggle()
                                        }
                                        .id(post.id)
                                        .onAppear {
                                            savedId = post.id
                                        }
                                }
                            }
                        }
                        .onAppear {
                            if let id = savedId {
                                scrollProxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPostDetails){
            if let post = viewModel.selectedPost {
                PostDetailView(post: post, communityId: communityId, viewModel: viewModel)
            }
        }
    }
}

