import SwiftUI

struct WaterCounterView: View {
    @State private var cupsOfWater: Int = 0
    @State private var inputText: String = "0"
    @State private var hasChanged: Bool = false // State variable to track if a change has been made
    @State private var showDeleteConfirmation = false // State to show the delete confirmation

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Add a trash can icon in the top-right corner
                HStack {
                    Spacer()
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)

                //Spacer() // Add spacer to push content down

                VStack(alignment: .leading) {
                    // Title: Water Intake
                    Text("Water Intake")
                        .font(.custom("SFProText-Heavy", size: 40))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the text horizontally

                    // Circle with "Cups of Water" text
                    HStack {
                        ZStack {
                            Circle()
                                  .fill(Color.black.opacity(0.3)) // Black fill with 0.3 opacity inside the circle
                                  .frame(width: 300, height: 300) // Increased size

                            Circle()
                                .stroke(Color(hex: "b0e8ff")!, lineWidth: 5) // Blue outline and transparent inside
                                .frame(width: 300, height: 300) // Increased size

                            VStack {
                                Text("Cups of Water")
                                    .font(.custom("SFProText-Heavy", size: 28)) // Slightly increased font size
                                    .foregroundColor(.white) // Set text color to white
                                    .padding(.top, 5) // Reduce spacing below the text
                                    .padding(.bottom, -5) // Reduce spacing below the text
                                
                                // Minus, text field, and plus buttons in HStack
                                HStack {
                                    Button(action: {
                                        if cupsOfWater > 0 {
                                            cupsOfWater -= 1
                                            inputText = "\(cupsOfWater)"
                                            hasChanged = true // Mark as changed
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .resizable()
                                            .frame(width: 33, height: 33) // Button size
                                            .foregroundColor(.red)
                                    }
                                    
                                    TextField("", text: $inputText, onCommit: {
                                        if let value = Int(inputText) {
                                            cupsOfWater = value
                                            hasChanged = true // Mark as changed
                                        }
                                    })
                                    .font(.custom("SFProText-Heavy", size: 80)) // Set the initial font to SFProText-Heavy
                                    .foregroundColor(.white) // Set text color to white
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120) // Adjusted size for better appearance
                                    .keyboardType(.numberPad)
                                    .minimumScaleFactor(0.5) // Set the minimum scale factor to allow shrinking
                                    .lineLimit(1) // Make sure the text stays on one line and shrinks
                                    .onChange(of: inputText) { newValue in
                                        if let value = Int(newValue) {
                                            cupsOfWater = value
                                            hasChanged = true // Mark as changed
                                        }
                                    }

                                    Button(action: {
                                        cupsOfWater += 1
                                        inputText = "\(cupsOfWater)"
                                        hasChanged = true // Mark as changed
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .frame(width: 33, height: 33) // Button size
                                            .foregroundColor(.green)
                                    }
                                }

                            }
                        }
                        .padding(.top, 20) // Optional: Adjust to center vertically
                    }
                    .frame(maxWidth: .infinity) // Center the circle horizontally

                    // Conditionally display Save button based on hasChanged state
                    if hasChanged {
                        Button(action: {
                                print("Saved: \(cupsOfWater) cups of water")
                                hasChanged = false // Reset the change state after saving
                            }) {
                                Text("Save")
                                    .font(.custom("SFProText-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 120, height: 50) // Make the button wider
                                    .background(Color(hex: "161331")!)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10) // Move Save button closer to the circle
                            .frame(maxWidth: .infinity) // Center the button horizontally
                    }

                    // Buttons for Edit Habit and View Analytics
                    VStack(spacing: 20) {
                        Button(action: {
                            print("Edit Habit pressed")
                        }) {
                            Text("Edit Habit")
                                .font(.custom("SFProText-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 300, height: 70) // Make the button wider
                                .background(Color(hex: "b0e8ff")!)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            print("View Analytics pressed")
                        }) {
                            Text("View Analytics")
                                .font(.custom("SFProText-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 300, height: 70) // Make the button wider
                                .background(Color(hex: "b0e8ff")!)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity) // Center the buttons horizontally
                    .padding(.top, 20) // Space between Save and the new buttons
                }

                Spacer() // Add spacer to push content up and down for vertical centering
            }
        }
        // Confirmation dialog for deleting habit
        .confirmationDialog("Are you sure you want to delete this habit?", isPresented: $showDeleteConfirmation) {
            Button("Yes", role: .destructive) {
                print("Habit deleted")
            }
            Button("No", role: .cancel) {}
        }
    }
}

struct WaterCounterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterCounterView()
    }
}
