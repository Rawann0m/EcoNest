//
//  PostDetailView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI

struct PostDetailView: View {
    let postText: String // Assuming you pass the post text
    @State private var replies: [String] = ["Reply 1", "Another reply", "A longer reply to test the layout"] // Replace with actual data
    @State private var newReply: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Display the main post
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
                                Text("username") // Replace with actual username
                                Text("date") // Replace with actual date
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
                            .stroke(.gray.opacity(0.3), lineWidth: 2)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
                            .frame(maxWidth: .infinity)
                    }

                    // Display Replies
                    if !replies.isEmpty {
                        Text("Replies")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(replies, id: \.self) { reply in
                            HStack(spacing: 16) {
                                Image("profile") // You might want different profiles for replies
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(20)

                                Text(reply)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No replies yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.bottom, 80) // Make space for the text field
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Write a reply...", text: $newReply)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button("Reply") {
                        if !newReply.isEmpty {
                            replies.append(newReply)
                            newReply = "" // Clear the text field
                            // In a real app, you would send this reply to your data source
                        }
                    }
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.white) // Ensure the input area has a background
            }
        }
    }
}

#Preview {
    PostDetailView(postText: "This is a sample post text that could be quite long and span multiple lines to demonstrate how the layout adapts to the content.")
}