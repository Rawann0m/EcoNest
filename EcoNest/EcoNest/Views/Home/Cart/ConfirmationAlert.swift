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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(circleColor)
                        .frame(width: 220, height: 220)
                        .scaleEffect(animationCircle ? 1.3 : 0.9)
                        .opacity(animationCircle ? 0 : 1)
                        .animation(.easeInOut(duration: 2).delay(1).repeatForever(autoreverses: true), value: animationCircle)
                    
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(circleColor)
                        .frame(width: 220, height: 220)
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
               
                Text("Order confirmed Successfuly")
                    .foregroundStyle(Color("DarkGreen"))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20){
                    NavigationLink(destination: MainTabView()){
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("LimeGreen"))
                            Text("Home")
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                    .frame(width: 160, height: 60)
                    
                    NavigationLink(destination: Text("Order List")){
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("LimeGreen"), lineWidth: 2)
                            Text("Order")
                                .foregroundStyle(Color("LimeGreen"))
                                .bold()
                        }
                    }
                    .frame(width: 160, height: 60)
                }
            }
        }
    }
}



