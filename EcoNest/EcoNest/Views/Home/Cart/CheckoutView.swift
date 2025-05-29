//
//  CheckoutView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 25/11/1446 AH.
//

import SwiftUI
import MapKit

/// A view that displays the checkout process including cart summary, pickup details, and order confirmation.
struct CheckoutView: View {
    
    /// Theme manager for handling light/dark mode
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Cart view model containing cart items and total calculation logic
    @ObservedObject var viewModel: CartViewModel
    
    /// Current app language
    var currentLanguage: String
    
    /// Dismiss action for the view
    @Environment(\.dismiss) var dismiss
    
    /// Indicates whether the order has been successfully placed
    @State private var isOrderPlaced = false

    /// Region displayed in the map
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    /// Location view model containing selected map location
    @EnvironmentObject var locViewModel: LocationViewModel
    
    /// Toggles the display of confirmation alert
    @State var show = false
    
    /// Binding to control cart view visibility
    @Binding var openCart: Bool
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            // Interactive map with location selection
                            Map(coordinateRegion: $mapRegion)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("DarkGreen"), lineWidth: 2)
                                )
                                .onTapGesture {
                                    locViewModel.showMap.toggle()
                                }
                                .padding(.top)
                            
                            Divider()
                            
                            // List of cart products with quantity and price
                            VStack {
                                ForEach(viewModel.cartProducts) { cart in
                                    HStack(spacing: 15) {
                                        
                                        // Product name
                                        Text(cart.product.name ?? "")
                                            .layoutPriority(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        // Quantity text
                                        Text(String(format: "qty".localized(using: currentLanguage), "\(cart.quantity)"))
                                            .frame(width: 60, alignment: .leading)

                                        // Price and currency
                                        HStack {
                                            Text("\(cart.price, specifier: "%.2f")")
                                            Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                        }
                                        .frame(width: 75, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                }
                            }
                            .padding(.bottom)
                            
                            // Pickup location, date, and total price section
                            VStack {
                                HStack(spacing: 30) {
                                    Text("PickupLocation".localized(using: currentLanguage))
                                        .frame(width: geometry.size.width * 0.45, alignment: .leading)
                                    
                                    Text("\(locViewModel.mapLocation.name)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 30) {
                                    Text("PickupDate".localized(using: currentLanguage))
                                        .frame(width: geometry.size.width * 0.45, alignment: .leading)
                                    
                                    DatePicker("", selection: $viewModel.selectedDate, in: Date()..., displayedComponents: [.date])
                                        .labelsHidden()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 30) {
                                    Text("Total".localized(using: currentLanguage))
                                        .frame(width: geometry.size.width * 0.45, alignment: .leading)
                                    
                                    HStack {
                                        Text("\(viewModel.calculateTotal(), specifier: "%.2f")")
                                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    
                    // Confirm order button
                    Button {
                        viewModel.addOrder(locationId: locViewModel.mapLocation.id) { success in
                            if success {
                                isOrderPlaced = true
                                
                                // Schedule pickup day reminder
                                NotificationManager.shared.requestPermission { granted in
                                    if granted {
                                        NotificationManager.shared.scheduleNotification(
                                            title: "It's Pickup Day! ✨",
                                            body: "Just a reminder that your order is ready for pickup today. We look forward to seeing you!",
                                            date: viewModel.selectedDate
                                        )
                                    }
                                }
                                show.toggle()
                            }
                        }
                    } label: {
                        
                        Text("Confirm".localized(using: currentLanguage))
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isOrderPlaced ? Color.gray : Color("LimeGreen"))
                            .cornerRadius(8)
                    }
                    .disabled(isOrderPlaced)
                    .padding([.top, .bottom], 10)
                }
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            
            // Full-screen confirmation alert after placing order
            .fullScreenCover(isPresented: $show) {
                ConfirmationAlert(openCart: $openCart)
            }
            
            // Full-screen map view for location selection
            .fullScreenCover(isPresented: $locViewModel.showMap) {
                MapView()
            }
            
            // Custom back button with localized title
            .toolbar {
                ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                    CustomBackward(title: "ReviewConfirm".localized(using: currentLanguage), tapEvent: { dismiss() })
                }
            }
            
            // Reset pickup date on appear
            .onAppear {
                viewModel.selectedDate = Date()
            }
            
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        }
    }
}
