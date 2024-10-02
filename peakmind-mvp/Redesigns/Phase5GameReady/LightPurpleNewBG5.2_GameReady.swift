//
//  LightPurpleNewBG5.2.swift
//  peakmind-mvp
//
//  Created by ZA on 10/1/24.
//

import SwiftUI

struct P5_5_2: View {
    var closeAction: (String) -> Void
    var firstText: String
    var secondText: String
    var thirdText: String
    var supportNames: [String] // Accept support names as a parameter
        
    // Store the challenge being dragged
    @State private var draggedChallenge: String? = nil
    @State private var sourceSupportIndex: Int? = nil // Track which support the challenge was dragged from
    
    // Store the connections between challenges and support names
    @State private var connections: [Int: [String]] = [:] // Store multiple challenges per support
    
    // Store unlinked challenges
    @State private var unlinkedChallenges: [String]
    
    @State private var navigateToNextScreen = false
    

    
    init(closeAction: @escaping (String) -> Void, firstText: String, secondText: String, thirdText: String, supportNames: [String]) {
        self.closeAction = closeAction
        self.firstText = firstText
        self.secondText = secondText
        self.thirdText = thirdText
        self.supportNames = supportNames
        self._unlinkedChallenges = State(initialValue: [firstText, secondText, thirdText])
    }
    
    // Check if all challenges have been linked to any support
    var allChallengesMatched: Bool {
        return unlinkedChallenges.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("LightPurpleNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 36) {
                    Spacer().frame(height: 10)
                    
                    // Title section
                    Text("Link Challenges to Support")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("LightPurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Left and right columns
                    HStack(spacing: 36) {
                        // Challenges (left side)
                        VStack(spacing: 20) {
                            ForEach(unlinkedChallenges, id: \.self) { challenge in
                                Text(challenge)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("LightPurpleTextColor"))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("LightPurpleBoxGradientColor1"), Color("LightPurpleBoxGradientColor2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .onDrag {
                                        draggedChallenge = challenge
                                        return NSItemProvider(object: NSString(string: challenge))
                                    }
                            }
                        }
                        
                        // Support Names (right side)
                        VStack(spacing: 20) {
                            ForEach(supportNames.indices, id: \.self) { index in
                                ZStack {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(supportNames[index])
                                            .font(.custom("SFProText-Medium", size: 16))
                                            .foregroundColor(Color("LightPurpleTextColor"))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color("LightPurpleBoxGradientColor1"), Color("LightPurpleBoxGradientColor2")]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                        
                                        // Display all challenges linked to this support
                                        ForEach(connections[index] ?? [], id: \.self) { connection in
                                            Text(connection)
                                                .font(.custom("SFProText-Medium", size: 14))
                                                .foregroundColor(Color("LightPurpleTextColor"))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(5)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color("LightPurpleBoxGradientColor1"), Color("LightPurpleBoxGradientColor2")]),
                                                        startPoint: .center,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .cornerRadius(10)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                                .onDrag {
                                                    // Allow dragging challenges already placed under a support
                                                    draggedChallenge = connection
                                                    sourceSupportIndex = index
                                                    return NSItemProvider(object: NSString(string: connection))
                                                }
                                        }
                                    }
                                }
                                .onDrop(of: [.text], isTargeted: nil) { providers in
                                    if let draggedChallenge = draggedChallenge {
                                        // Remove the challenge from the original support if it was dragged from there
                                        if let sourceIndex = sourceSupportIndex, let indexOfDraggedChallenge = connections[sourceIndex]?.firstIndex(of: draggedChallenge) {
                                            connections[sourceIndex]?.remove(at: indexOfDraggedChallenge)
                                        }
                                        
                                        // Add the dragged challenge to the new support name's stack
                                        if connections[index] != nil {
                                            connections[index]?.append(draggedChallenge)
                                        } else {
                                            connections[index] = [draggedChallenge]
                                        }
                                        
                                        // If the challenge was unlinked, remove it from unlinkedChallenges
                                        unlinkedChallenges.removeAll { $0 == draggedChallenge }
                                        
                                        // Reset drag state
                                        self.draggedChallenge = nil
                                        self.sourceSupportIndex = nil
                                        return true
                                    }
                                    return false
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Continue button for next screen
                    Button(action: {
                        closeAction("")
                    }) {
                        Text("Continue")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("LightPurpleButtonGradientColor1"), Color("LightPurpleButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: allChallengesMatched ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                    }
                    .disabled(!allChallengesMatched) // Disable if not all challenges matched
                    .background(
                        NavigationLink(destination: P5MentalHealthFeatureView2(), isActive: $navigateToNextScreen) {
                            EmptyView()
                        }
                    )
                    .padding(.bottom, 50)
                }
                .padding(.horizontal)
            }
        }
    }
}







