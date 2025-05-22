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
    var currentLanguage: String
    
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
                            Image("Order")
                                .resizable()
                                .frame(width: 230, height: 230)
                            
                            // Localized message when the cart is empty
                            if selectedCategory == .awaitingPickup {
                                Text("NoOrdersYet".localized(using: currentLanguage))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("NoCancelledOrders".localized(using: currentLanguage))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    } else {
                        ForEach(viewModel.orders.filter({$0.status.rawValue == selectedCategory.rawValue})) { order in
                            OrderCardView(order: order, viewModel: viewModel, currentLanguage: currentLanguage)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                    CustomBackward(title: "Order".localized(using: currentLanguage), tapEvent: {dismiss()})
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
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
                Text(category.rawValue.localized(using: currentLanguage))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .foregroundStyle(category == selectedCategory ? .white : Color("LimeGreen"))
                    .background{
                        if category == selectedCategory {
                            Capsule()
                                .fill(Color("LimeGreen"))
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
        .background(.background, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color("LimeGreen"), lineWidth: 1)
        )
        .padding()
    }
    
}
