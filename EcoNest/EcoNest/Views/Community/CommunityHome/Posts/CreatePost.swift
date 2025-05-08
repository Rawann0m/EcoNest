//
//  CreatePost.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

struct CreatePost: View {
    @State var message: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Image("profile")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(50)
                        .background{
                            Circle()
                                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                        }
                    
                    Text("username")
                    
                    Spacer()
                }
                
                TextEditor(text: $message)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Cancel")
                        .onTapGesture {
                            dismiss()
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Post")
                        .bold()
                        .foregroundColor(Color("MidGreen"))
                        .onTapGesture {
                            // save post to core data after checking that is not empty
                            dismiss()
                        }
                }
            }
            .padding()
        }
    }
}

