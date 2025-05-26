//
//  LocationPreviewView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

struct LocationPreviewView: View {
    
    let location: Location
    @EnvironmentObject private var viewModel: LocationViewModel
    var currentLanguage: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    
                    WebImage(url: URL(string: location.image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                }
                .padding(6)
                .background(.white)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(location.description)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack {
                Button {
                    viewModel.nextButtonPressed()
                } label: {
                    Text("Next".localized(using: currentLanguage))
                        .font(.headline)
                        .frame(width: 125, height: 35)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("LimeGreen"))
            }
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
    }
}

