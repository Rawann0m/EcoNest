//
//  PicView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 17/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

struct PicView: View {
    var pic: String
    @Binding var showPic: Bool
    var body: some View {
        ZStack{
            Color.black.opacity(0.6).ignoresSafeArea(edges: .all)
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: pic) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onTapGesture {
            showPic.toggle()
        }
    }
}
