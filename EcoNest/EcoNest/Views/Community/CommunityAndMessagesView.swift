//
//  CommunityAndMessagesView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct CommunityAndMessagesView: View {
    @State var isCommunity: Bool = true
    var body: some View {
        NavigationStack{
            VStack{
                Text(isCommunity ? "Community" :"Direct Messages")
            }
        }
    }
}

#Preview {
    CommunityAndMessagesView()
}
