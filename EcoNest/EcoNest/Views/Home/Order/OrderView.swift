//
//  OrderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 20/11/1446 AH.
//

import SwiftUI

/// A SwiftUI view that displays the user's orders, allowing filtering by status and canceling active orders.
struct OrderView: View {
    
    /// ViewModel responsible for fetching and managing order data.
    @StateObject private var viewModel = OrderViewModel()
    
    /// Namespace for matched geometry effect used in segmented control animation.
    @Namespace private var animation
    
    /// Allows dismissing the current view.
    @Environment(\.dismiss) var dismiss
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// The current language code used for localization.
    var currentLanguage: String
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                LazyVStack {
                    
                    // Segmented control for filtering orders by status
                    CustomSegmentedControl()
                        .padding(.vertical, 12)
                    
                    if viewModel.isLoading {
                        // Show loading indicator while fetching orders
                        ProgressView()
                        
                    } else {
                        // Filter orders based on the selected category
                        let filteredOrders = viewModel.orders.filter { $0.status == viewModel.selectedCategory }

                        if filteredOrders.isEmpty {
                            // Empty state UI
                            VStack(spacing: 10) {
                                
                                Image("Order")
                                    .resizable()
                                    .frame(width: 230, height: 230)
                                
                                if viewModel.selectedCategory == .awaitingPickup {
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
                            // Display each filtered order
                            ForEach(filteredOrders) { order in
                                OrderCardView(
                                    orderViewModel: viewModel,
                                    order: order,
                                    currentLanguage: currentLanguage
                                )
                            }
                        }
                    }
                }
            }
            .toolbar {
                // Custom back button placement and styling based on language direction
                ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                    CustomBackward(
                        title: "Order".localized(using: currentLanguage),
                        tapEvent: { dismiss() }
                    )
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
            .navigationBarBackButtonHidden(true) // Hide default back button
        }
        .onAppear {
            // Fetch orders when the view appears
            viewModel.fetchOrders()
        }
    }
    
    /// Custom segmented control used to switch between order categories
    func CustomSegmentedControl() -> some View {
        
        HStack {
            
            ForEach(OrderStatus.allCases, id: \.rawValue) { category in
                
                Text(category.rawValue.localized(using: currentLanguage))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .foregroundStyle(category == viewModel.selectedCategory ? .white : Color("LimeGreen"))
                    .background {
                        
                        if category == viewModel.selectedCategory {
                            Capsule()
                                .fill(Color("LimeGreen"))
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        
                        withAnimation(.snappy) {
                            viewModel.selectedCategory = category
                        }
                    }
            }
        }
        .background(.background, in: Capsule()) // Background for unselected state
        .overlay(
            Capsule()
                .stroke(Color("LimeGreen"), lineWidth: 1)
        )
        .padding()
    }
}
