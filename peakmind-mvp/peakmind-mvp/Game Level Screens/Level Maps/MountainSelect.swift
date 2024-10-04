//
//  MountainSelect.swift
//  peakmind-mvp
//
//  Created by James Wilson on 7/16/24.
//

import SwiftUI

struct Mountain2: Hashable {
    var name: String
    var completedLevels: Int
}

struct MountainSelect: View {
    var closeAction: () -> Void
    @State var currentMountain = 0
    @State var mountains = [
        Mountain2(name: "Anxiety", completedLevels: 0),
        Mountain2(name: "Emotion", completedLevels: 0),
        Mountain2(name: "IDK", completedLevels: 0),
        Mountain2(name: "Something", completedLevels: 0),
        Mountain2(name: "Important", completedLevels: 0),
        Mountain2(name: "OK", completedLevels: 0),
    ]
    var body: some View {
        ZStack {
            Color.init(hex: "40A3FF")
                            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        closeAction()
                    }) {
                        Image(systemName: "xmark.circle") // Button icon
                            .font(.system(size: 50)) // Icon size
                            .foregroundStyle(.black) // Icon color
                            .opacity(0.4) // Icon opacity
                            .frame(width: 60, height: 60) // Button size
                            .background(Color.white) // Button background color
                            .clipShape(Circle()) // Make button round
                            .shadow(radius: 4) // Add slight shadow
                            .padding([.leading, .bottom]) // Custom padding for leading and bottom
                    }
                    Spacer()
                }
                ScrollView {
                    VStack {
                        ForEach(mountains, id: \.self) { mountain in
                            if(mountain == mountains[currentMountain]){
                                HStack {
                                    Spacer()
                                    HStack{
                                        Text("⛰️")
                                            .font(.system(size: 78, weight: .bold))
                                            .padding(.bottom)
                                            .padding(.leading, 35)
                                        VStack {
                                            Text("Mount "+mountain.name)
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundStyle(Color.init(hex: "8BC7FF")!)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("Currently Selected")
                                                .multilineTextAlignment(.leading)
                                                .foregroundStyle(Color.init(hex: "77B5EF")!)
                                                .padding(.bottom, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    }
                                    
                                    Spacer()
                                }.background(Color.init(hex: "323232")?.opacity(0.27))
                            } else if (mountains.firstIndex(of: mountain) ?? 0 < currentMountain) {
                                HStack {
                                    Spacer()
                                    HStack{
                                        Text("⛰️")
                                            .font(.system(size: 78, weight: .bold))
                                            .padding(.bottom)
                                            .padding(.leading, 35)
                                        VStack {
                                            Text("Mount "+mountain.name)
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundStyle(Color.init(hex: "8BC7FF")!)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("Completed")
                                                .multilineTextAlignment(.leading)
                                                .foregroundStyle(Color.init(hex: "77B5EF")!)
                                                .padding(.bottom, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    }
                                    
                                    Spacer()
                                }
                            
                            } else {
                                HStack {
                                    Spacer()
                                    HStack{
                                        Text("🔒")
                                            .font(.system(size: 78, weight: .bold))
                                            .padding(.bottom)
                                            .padding(.leading, 35)
                                        VStack {
                                            Text("Locked")
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundStyle(Color.init(hex: "8BC7FF")!)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("Coming Soon!")
                                                .multilineTextAlignment(.leading)
                                                .foregroundStyle(Color.init(hex: "77B5EF")!)
                                                .padding(.bottom, 25)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }.padding(.top)
        }
    }
}
