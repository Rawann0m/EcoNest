//
//  CategoryRowView.swift
//  EcoNest
//
//  Created by Mac on 08/11/1446 AH.
//

import SwiftUI

struct CategoryRowView: View {
    let category: Category

    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: UIImage(named: category.imageName) ?? UIImage(systemName: "photo")!)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

            Text(category.name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color("LightGreen"))
        .cornerRadius(15)
        .padding(.horizontal, 10)
    }
}
