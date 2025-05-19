//
//  OrderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 20/11/1446 AH.
//

import SwiftUI

struct OrderView: View {
    
    @State private var selectedCategory: Category2 = .income
    @Namespace private var animation
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    CustomSegmentedControl()
                        .padding(.vertical, 12)
                    
                    HStack(spacing: 12){
                        
                        VStack {
                            Text("Scheduled :")
                            Text("5 May 2025")
                        }
                        .padding()
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 130)
                        .background(Color("LimeGreen"))
                        
                        VStack(alignment: .leading, spacing: 8, content: {
                            Text("Plant: Sansevieria, Snake plan, Cactus Trio, Peace Lily")
                                .foregroundStyle(.primary)
                            
                            HStack {
                                Text("Total: 300.00")
                                    .foregroundStyle(.primary)
                                    .bold()
                                
                                Image("RiyalB")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text("Cancel")
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.trailing)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("LimeGreen"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackward(title: "Order", tapEvent: {dismiss()})
                }
            }
            .navigationBarBackButtonHidden(true)
        }

    }
    
    @ViewBuilder
    func CustomSegmentedControl() -> some View {
        HStack {
            ForEach(Category2.allCases, id: \.rawValue){ category in
                Text(category.rawValue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .foregroundStyle(category == selectedCategory ? .white : Color("DarkGreen"))
                    .background{
                        if category == selectedCategory {
                            Capsule()
                                .fill(Color("DarkGreen"))
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy){
                            selectedCategory = category
                        }
                    }
            }
        }
        .background(Color.white, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color("DarkGreen"), lineWidth: 1)
        )
        .padding()
    }

}

#Preview {
    OrderView()
}

enum Category2: String, CaseIterable{
    case income = "Upcoming"
    case expense = "Previous"
    
}
