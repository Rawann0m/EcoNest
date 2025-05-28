//
//  CheckoutView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 25/11/1446 AH.
//

import SwiftUI
import MapKit

struct CheckoutView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CartViewModel
    var currentLanguage: String
    @Environment(\.dismiss) var dismiss
    
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @EnvironmentObject var locViewModel: LocationViewModel
    @State var show = false
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    ScrollView {
                        VStack(spacing: 16) {
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
                            
                            VStack {
                                ForEach(viewModel.cartProducts) { cart in
                                    HStack(spacing: 15) {
                                        Text(cart.product.name ?? "")
                                            .layoutPriority(1) // Let this expand
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Text(String(format: "qty".localized(using: currentLanguage), "\(cart.quantity)"))
                                            .frame(width: 60, alignment: .leading) // Narrower fixed width

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
                    
                    Button {
                        viewModel.addOrder(locationId: locViewModel.mapLocation.id)
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
                    } label: {
                        Text("Confirm".localized(using: currentLanguage))
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("LimeGreen"))
                            .cornerRadius(8)
                    }
                    .padding([.top, .bottom], 10)
                }
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $show) {
                ConfirmationAlert()
            }
            .fullScreenCover(isPresented: $locViewModel.showMap) {
                MapView()
            }
            .toolbar {
                ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                    CustomBackward(title: "ReviewConfirm".localized(using: currentLanguage), tapEvent: { dismiss() })
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        }
    }
}

