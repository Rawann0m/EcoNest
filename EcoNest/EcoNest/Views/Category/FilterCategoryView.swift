//
//  FilterCategoryView.swift
//  EcoNest
//
//  Created by Mac on 10/11/1446 AH.
//

import SwiftUI

struct FilterCategoryView: View {
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        
        VStack{
            Button("Press to dismiss"){
                dismiss()
                    
            }.font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
        }
        
        
    }
}

#Preview {
    FilterCategoryView()
}
