//
//  GreenNewBG7.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/18/24.
//


import SwiftUI

struct P2Factor2: View {
    @State var factors: [String] // The factors passed from the previous screen
    @State private var controllableFactors: [String] = []
    @State private var uncontrollableFactors: [String] = []
    @State private var showSubmitButton = false // To control the visibility of the Submit button
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Title Text
                    Text("External Factors")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Intro Text
                    Text("Divide the five external factors you identified into elements you can control and those you cannot.")
                        .font(.custom("SFProText-Medium", size: 16))
                        .foregroundColor(Color("GreenTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Current factor box with dragging functionality
                    if !factors.isEmpty {
                        FactorBox(factor: factors.first!)
                            .onDrag {
                                NSItemProvider(object: factors.first! as NSString)
                            } preview: {
                                DragPreview(factor: factors.first!) // Show drag preview
                            }
                    }
                    
                    Spacer()
                    
                    // Bottom two boxes for controllable and uncontrollable factors
                    HStack(spacing: 16) {
                        // Controllable Factors Box
                        VStack {
                            Text("Controllable")
                                .font(.custom("SFProText-Bold", size: 18))
                                .foregroundColor(Color("GreenTitleColor"))
                                .padding(.bottom, 5)
                            
                            FactorDropBox(
                                factors: controllableFactors,
                                onDrop: { factor in
                                    self.moveFactor(factor, to: &controllableFactors)
                                },
                                onDragOut: { factor in
                                    self.removeFactor(factor, from: &controllableFactors)
                                }
                            )
                        }
                        
                        // Uncontrollable Factors Box
                        VStack {
                            Text("Uncontrollable")
                                .font(.custom("SFProText-Bold", size: 18))
                                .foregroundColor(Color("GreenTitleColor"))
                                .padding(.bottom, 5)
                            
                            FactorDropBox(
                                factors: uncontrollableFactors,
                                onDrop: { factor in
                                    self.moveFactor(factor, to: &uncontrollableFactors)
                                },
                                onDragOut: { factor in
                                    self.removeFactor(factor, from: &uncontrollableFactors)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Submit Button (only shown if all factors are placed)
                    if showSubmitButton {
                        NavigationLink(destination: P2Wheel()) {
                            Text("Submit")
                                .font(.custom("SFProText-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onChange(of: factors) { _ in
            checkAllFactorsPlaced()
        }
        .onChange(of: controllableFactors) { _ in
            checkAllFactorsPlaced()
        }
        .onChange(of: uncontrollableFactors) { _ in
            checkAllFactorsPlaced()
        }
    }
    
    // Function to move a factor to a specific list
    private func moveFactor(_ factor: String, to list: inout [String]) {
        list.append(factor)
        factors.removeAll { $0 == factor } // Remove from the original list
    }
    
    // Function to remove a factor from a specific list
    private func removeFactor(_ factor: String, from list: inout [String]) {
        list.removeAll { $0 == factor }
        factors.append(factor) // Return the factor back to the top
    }
    
    // Check if all factors are placed and enable the submit button
    private func checkAllFactorsPlaced() {
        if factors.isEmpty && (controllableFactors.count + uncontrollableFactors.count == 5) {
            showSubmitButton = true
        } else {
            showSubmitButton = false
        }
    }
}

// Component for displaying current factor
struct FactorBox: View {
    var factor: String
    
    var body: some View {
        Text(factor)
            .font(.custom("SFProText-Bold", size: 18))
            .foregroundColor(Color("GreenTextColor"))
            .frame(width: 250, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("GreenBorderColor"), lineWidth: 2.5)
            )
    }
}

// Component for displaying drop zones with scrollable drop functionality
struct FactorDropBox: View {
    var factors: [String]
    var onDrop: (String) -> Void
    var onDragOut: (String) -> Void // Handle dragging the factor out
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient background for the box
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 250) // Fixed size for the drop zone
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("GreenBorderColor"), lineWidth: 2.5)
                )
            
            // Scrollable list of factors inside the gradient box
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(factors, id: \.self) { factor in
                        Text(factor)
                            .font(.custom("SFProText-Medium", size: 16))
                            .foregroundColor(Color("GreenTextColor"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .onDrag {
                                onDragOut(factor) // Remove the factor from this box when dragged out
                                return NSItemProvider(object: factor as NSString)
                            } preview: {
                                DragPreview(factor: factor) // Show drag preview
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            }
            .frame(height: 230) // Ensure the factors stay within the box's boundaries
            .clipped() // Prevent overflow outside of the box
            .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                providers.first?.loadObject(ofClass: NSString.self) { object, _ in
                    if let factor = object as? String {
                        onDrop(factor)
                    }
                }
                return true
            }
        }
        .padding(.horizontal)
        .clipped() // Ensure factors stay inside the entire box
    }
}

// Drag Preview View to display while dragging a factor
struct DragPreview: View {
    var factor: String
    
    var body: some View {
        Text(factor)
            .font(.custom("SFProText-Bold", size: 18))
            .foregroundColor(.white)
            .padding()
            .background(Color("GreenTextColor"))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

struct P2Factor2_Previews: PreviewProvider {
    static var previews: some View {
        P2Factor2(factors: ["Factor1", "Factor2", "Factor3", "Factor4", "Factor5"])
    }
}
