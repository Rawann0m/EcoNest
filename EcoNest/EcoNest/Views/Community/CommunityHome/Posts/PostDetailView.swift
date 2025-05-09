//
//  PostDetailView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

struct PostDetailView: View {
    let postText: String
    @State private var replies: [String] = []
    @State private var newReply: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 16){
                            Image("profile")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(50)
                                .background{
                                    Circle()
                                        .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                                }

                            VStack(alignment: .leading){
                                Text("username")
                                Text("date")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        Text(postText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                    }
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()

                    if !replies.isEmpty {
                        Text("Replies")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(replies, id: \.self) { reply in
                            Post(text: reply)
                                .padding(.horizontal)
                        }
                    } else {
                        Text("No replies yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.bottom, 80)
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.primary)
                        .onTapGesture {
                           dismiss()
                        }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    ZStack{
                        Text("Type a replay...")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        TextEditor(text: $newReply)
                            .frame(height: 25)
                            .opacity(newReply.isEmpty ? 0.5 : 1)
                    }

                    Button("Reply") {
                      
                    }
                    .padding(10)
                    .foregroundColor(.white)
                    .background{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color("LimeGreen"))
                    }
                }
                .padding()
                .background(.white)
            }
        }
    }
}
