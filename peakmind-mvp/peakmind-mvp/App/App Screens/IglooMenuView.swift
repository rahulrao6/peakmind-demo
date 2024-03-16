//
//  IglooMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI

struct IglooMenuView: View {
    let iglooIcons = ["BlueIcon", "PinkIcon", "OrangeIcon"]
    let iglooImages = ["Blue Igloo", "Pink Igloo", "Orange Igloo"]
    @State private var selectedIglooIndex = 0
    @State private var isIglooSelection = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView{
            ZStack {
                Image("ChatBG2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Igloo")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            HStack {
                                ForEach(0..<iglooIcons.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIglooIndex = index
                                    }) {
                                        Image(iglooIcons[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 95, height: 85)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: selectedIglooIndex == index ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            Image(iglooImages[selectedIglooIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Back") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    // Confirm action: FIREBASE CONNECTION PLZ and make it navigate to the avatar screen after selected
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// Preview
struct IglooMenuView_Previews: PreviewProvider {
    static var previews: some View {
        IglooMenuView()
    }
}
