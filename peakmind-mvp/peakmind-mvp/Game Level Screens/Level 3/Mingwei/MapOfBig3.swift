//
//  MapOfBig3.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/5/24.
//

import SwiftUI

struct MapOfBig3: View {
    @State private var isShowing = false;
    
    let sColor: Color = Color(hex: "6EADF0") ?? .white;
    let eColor: Color = Color(hex: "044F9E") ?? .white;
    let sColor3: Color = Color(hex: "B3DEF7") ?? .white;
    let eColor4: Color = Color(hex: "4CB9F8") ?? .white;
    
    @State private var tri1: String = ""
    @State private var tri2: String = ""
    @State private var tri3: String = ""
    
    @State private var eff1: String = ""
    @State private var eff2: String = ""
    @State private var eff3: String = ""
    
    let texts = ["Understanding what causes and effects\nof physical anxiety symptoms helps\nus immediately respond when any\nstressors comes up.", "First, let’s write out the cause or\ntrigger of three physical symptoms of\nanxiety that you experience. Click the\narrow when you finish!"]
    
    var body: some View {
        ZStack{
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            
            VStack{
                Text("—— Mt. Anxiety ——")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .glowBorder(color: .black, lineWidth: 2)
                
                Text("Level Three")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                VStack{
                    Text("Trigger Map")
                        .glowBorder(color: .black, lineWidth: 2)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "004FAC"))
                                .opacity(0.8)
                                .cornerRadius(11.1)
                                .overlay(RoundedRectangle(cornerRadius: 11.1)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 125, height: 27)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.bottom, 20)
                        .offset(y: -20)
                        .bold()
                    TabView{
                        ForEach(0..<texts.count, id: \.self) { index in
                            VStack {
                                Text(texts[index])
                                    .glowBorder(color: .black, lineWidth: 2)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .lineSpacing(8)
                                    .transition(.identity)
                                    .bold()
                            }
                        }
                    }
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "677072"))
                            .opacity(0.33)
                            .cornerRadius(20.0)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 253, height: 145)
                    )
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .offset(y: -43)
                    .padding(.bottom, -70)
                }
                .background(
                    LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 320, height: 194)
                        .opacity(0.8)
                )
                .padding(.top, 30)
                .padding(.bottom, 50)
                .offset(y: -35)
                

                
                if !isShowing{
                    ZStack{
                        VStack{
                            HStack{
                                TextField("Trigger", text: $tri1)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                                .background(
                                    EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                        .cornerRadius(23.61)
                                        .overlay(RoundedRectangle(cornerRadius: 23.61)
                                            .stroke(Color.black, lineWidth: 1))
                                        .frame(width: 119, height: 74)
                                )
                                .padding()
                                .offset(x:35)
                                
                                TextField("Trigger", text: $tri2)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                                .background(
                                    EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                        .cornerRadius(23.61)
                                        .overlay(RoundedRectangle(cornerRadius: 23.61)
                                            .stroke(Color.black, lineWidth: 1))
                                        .frame(width: 119, height: 74)
                                )
                                .padding()
                                .offset(x:-35)
                            }
                            .padding(.bottom, 40)
                            
                            TextField("Trigger", text: $tri3)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .bold()
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(23.61)
                                    .overlay(RoundedRectangle(cornerRadius: 23.61)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 119, height: 74)
                            )
                            .padding(.bottom, 30)
                            .offset(y:10)
                            
                            Button("Continue"){
                                withAnimation{
                                    isShowing.toggle()
                                }
                            }
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 1)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(13.58)
                                    .overlay(RoundedRectangle(cornerRadius: 13.58)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 204, height: 44)
                            )
                            .offset(y:10)
                            .padding()
                        }
                        .background(
                            LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                                .cornerRadius(12.64)
                                .overlay(RoundedRectangle(cornerRadius: 12.64)
                                    .stroke(Color.black, lineWidth: 1))
                                .frame(width: 320, height: 249)
                                .opacity(0.8)
                        )
                        .offset(y: -70)
                        Spacer()
                        Text("")
                            .multilineTextAlignment(.center)
                            .glowBorder(color: .black, lineWidth: 2)
                            .background(
                                EllipticalGradient(colors: [sColor, eColor], center: .center)
                                    .cornerRadius(15.0)
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 164, height: 88)
                            )
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .offset(x: 60, y:130)
                            .lineSpacing(10.0)
                    }
                    .transition(.slide)
                    .offset(y: 45)
                    Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 115)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding()
                        .offset(x: 40, y: -20)
                    
                } else {
                    ZStack{
                        VStack{
                            HStack{
                                ZStack {
                                    Text(tri1)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -215)
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 25, height: 20)
                                        .foregroundColor(Color("Ice Blue"))
                                        .offset(x: -125)
                                    
                                    TextField("Effect", text: $eff1)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -35)
                                }
                            }
                            .offset(x: 100)
                            .padding(.bottom, 60)
                            HStack{
                                ZStack{
                                    Text(tri2)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -215)
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 25, height: 20)
                                        .foregroundColor(Color("Ice Blue"))
                                        .offset(x: 70)
                                        .offset(x: -195)
                                    TextField("Effect", text: $eff2)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -35)
                                }
                            }
                            .offset(x: 125, y: 8)
                            .padding(.bottom, 60)
                            HStack{
                                ZStack{
                                    Text(tri3)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -215)
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 25, height: 20)
                                        .foregroundColor(Color("Ice Blue"))
                                        .offset(x: 70)
                                        .offset(x: -195)
                                    TextField("Effect", text: $eff3)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .background(
                                            EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                                .cornerRadius(23.61)
                                                .overlay(RoundedRectangle(cornerRadius: 23.61)
                                                    .stroke(Color.black, lineWidth: 1))
                                                .frame(width: 119, height: 74)
                                        )
                                        .offset(x: -35)
                                }
                            }
                            .offset(x: 150, y: 15)
                            .padding(.bottom, 60)
                            
                            Button("Continue"){
                                withAnimation{
                                    isShowing.toggle()
                                }
                            }
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 2)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(15)
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 204, height: 44)
                            )
                            .offset(y: -10)
                            .padding()
                            Spacer()
                        }
                    }
                    .background(
                        LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 367, height: 360)
                            .opacity(0.8)
                            .offset(y: -20)
                    )
                    .padding(.bottom, 100)
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

struct MapOfBig3_Previews: PreviewProvider {
    static var previews: some View {
        MapOfBig3()
    }
}
