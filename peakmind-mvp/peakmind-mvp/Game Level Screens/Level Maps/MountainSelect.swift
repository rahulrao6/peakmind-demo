//
//  MountainSelect.swift
//  peakmind-mvp
//
//  Created by James Wilson on 7/16/24.
//

import SwiftUI

struct Mountain: Hashable {
    var name: String
    var completedLevels: Int
}

struct MountainSelect: View {
    @State var currentMountain = 3
    @State var mountains = [
        Mountain(name: "Anxiety", completedLevels: 0),
        Mountain(name: "Emotion", completedLevels: 0),
        Mountain(name: "IDK", completedLevels: 0),
        Mountain(name: "Something", completedLevels: 0),
        Mountain(name: "Important", completedLevels: 0),
        Mountain(name: "OK", completedLevels: 0),
    ]
    var body: some View {
        ZStack {
            Color.init(hex: "40A3FF")
                            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image(systemName:"xmark.circle")
                        .foregroundStyle(.white)
                        .opacity(0.4)
                        .font(.system(size: 50))
                        .padding([.leading, .bottom])
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
                                            
                                            Text("Summit other mountains!")
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

#Preview {
    MountainSelect()
}
