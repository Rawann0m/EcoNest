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
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    else if viewModel.orders.isEmpty {
                        VStack(spacing: 10) {
                            
                            // Display cart image
                            Image("Cart")
                                .resizable()
                                .frame(width: 230, height: 230)
                            
                            // Localized message when the cart is empty
                            Text("Your Order List is Empty")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            // Localized instruction to add products
                            Text("Add Order Here")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                        }
                        .padding()
                    } else {
                        ForEach(viewModel.orders.filter({$0.status.rawValue == selectedCategory.rawValue})) { order in
                            OrderCardView(order: order, viewModel: viewModel)
                        }
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
