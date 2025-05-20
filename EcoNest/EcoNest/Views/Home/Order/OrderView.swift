//
//  OrderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 20/11/1446 AH.
//

import SwiftUI

struct OrderView: View {
    
    @State private var selectedCategory: OrderStatus = .awaitingPickup
    @Namespace private var animation
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel = OrderViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                LazyVStack {
                    CustomSegmentedControl()
                        .padding(.vertical, 12)
                    
                    ForEach(viewModel.orders.filter({$0.status.rawValue == selectedCategory.rawValue})) { order in
                        OrderCardView(order: order, viewModel: viewModel)
                    }
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackward(title: "Order", tapEvent: {dismiss()})
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            viewModel.fetchOrders()
        }
    }
    
    @ViewBuilder
    func CustomSegmentedControl() -> some View {
        HStack {
            ForEach(OrderStatus.allCases, id: \.rawValue){ category in
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
