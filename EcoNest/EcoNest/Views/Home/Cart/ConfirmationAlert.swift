//
//  ConfirmationAlert.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI

struct ConfirmationAlert: View {

    @State var animationCircle = false
    var gridentColor: Color = Color("LimeGreen")
    var circleColor: Color = Color("LimeGreen")
    var cornerRadius: CGFloat = 30
    var width: CGFloat = 220
    var height: CGFloat = 220
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(circleColor)
                        .frame(width: width, height: height)
                        .scaleEffect(animationCircle ? 1.3 : 0.9)
                        .opacity(animationCircle ? 0 : 1)
                        .animation(.easeInOut(duration: 2).delay(1).repeatForever(autoreverses: true), value: animationCircle)
                    
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(circleColor)
                        .frame(width: width, height: height)
                        .scaleEffect(animationCircle ? 1.3 : 0.9)
                        .opacity(animationCircle ? 0 : 1)
                        .animation(.easeInOut(duration: 2).delay(1.5).repeatForever(autoreverses: true), value: animationCircle)
                        .onAppear {
                            animationCircle.toggle()
                        }
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 230)
                        .foregroundStyle(circleColor)
                }
               
                Text("OrderSuccessfuly".localized(using: currentLanguage))
                    .foregroundStyle(themeManager.isDarkMode ? .white : Color("DarkGreen"))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20){
                    Button(action: {dismiss()}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("LimeGreen"))
                            Text("GoBack".localized(using: currentLanguage))
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                    .frame(width: 160, height: 60)
                    
                }
            }
        }.navigationBarBackButtonHidden(true)
        // Set layout direction based on language
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}



