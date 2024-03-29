//
//  VCPopup.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 3/29/24.
//

import Foundation
import SwiftUI

struct VCPopup: View {
    @Binding var shown: Bool
    @Binding var storeShown: Bool
    var isSuccess: Bool
    var amount: Int
    var bonus: Int
    
    
    var body: some View {
        VStack {
            Text("Congrats, you have earned VC!").foregroundColor(.white)
                .font(.title)
                .multilineTextAlignment(.center)
                .bold()
                .padding()
                .shadow(color: .black, radius: 10)
            HStack {
                // TODO: Update this to the coin icon
                // Image("ProfileButton").resizable().frame(width: 50, height: 50).padding(.top, 10)
               
                VStack {
                    Text("\(amount) VC")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                    Text("+\(bonus) bonus from staff")
                        .foregroundColor(.white)
                        .bold()
                }
            }.frame(width: UIScreen.main.bounds.width-120, height: 100)
                .background(Color.blue)
                .cornerRadius(16)
                .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 2)
                            .shadow(color: .black, radius: 5)
                    )
                .padding(.bottom, 10)
            Divider()
            HStack {
                 Button("Store") {
                     storeShown.toggle()
                     shown.toggle()
                 }.frame(width: UIScreen.main.bounds.width/2-30, height: 40)
                 .foregroundColor(.white)
                 
                 Button("Exit") {
                     shown.toggle()
                 }.frame(width: UIScreen.main.bounds.width/2-30, height: 40)
                 .foregroundColor(.white)
                 
             }
            
        }
        .frame(width: UIScreen.main.bounds.width-50, height: 300)
        .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.blue]), center:UnitPoint(x: 0.5, y: 0.5), startRadius: 20, endRadius: 200))
        .cornerRadius(25)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .yellow, radius: 7)
        
    }
}


struct CustomAlert_Previews: PreviewProvider {
    
    static var previews: some View {
        VCPopup(shown: .constant(false), storeShown: .constant(false), isSuccess: false, amount: 200, bonus: 50)
    }
}
