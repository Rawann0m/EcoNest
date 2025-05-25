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
                            TextField("Search".localized(using: currentLanguage), text: $viewModel.searchText)
                                .padding(12)
                                .background(.gray.opacity(0.1), in: .rect(cornerRadius: 25))
                                .foregroundColor(.gray)
                                .frame(height: 25)
                                .padding()
                                .disableAutocorrection(true) // Prevent autocorrect suggestions
                                .textInputAutocapitalization(.none) // Disable auto-capitalization for accurate search matching
                            ForEach(getPosts()) { post in
                                if let user = post.user {
                                    Posts(post: post, user: user, communityId: communityId, viewModel: viewModel, isReplay: false, postId: post.id)
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
    
    func getPosts() -> [Post]{
        let text = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return viewModel.posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
        } else {
            return viewModel.posts.filter { post in
                let contentMatches = post.content.contains {
                    $0.lowercased().contains(text.lowercased())
                }
                
                let usernameMatches = post.user?.username.lowercased().contains(text.lowercased()) ?? false
                
                return contentMatches || usernameMatches
            }
        }
    }
}

