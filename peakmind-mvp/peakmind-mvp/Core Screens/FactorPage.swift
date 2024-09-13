import SwiftUI

struct FactorPage: View {
    var category: Category // Pass the category for contextual use
    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    // State to track whether to show the FactorDetailView
    @State private var showFactorDetail = false
    @State private var selectedNodeIndex: Int? = nil // To track the selected node

    // Static positions for the nodes, adjusted for centering and longer lines
    @State private var nodePositions: [CGSize] = [
        CGSize(width: -80, height: -50), // Top-left
        CGSize(width: 80, height: -50),  // Top-right
        CGSize(width: -80, height: 50),  // Bottom-left
        CGSize(width: 80, height: 50)    // Bottom-right
    ]

    var body: some View {
        ZStack {
            // Set the background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 40)

                // Top label
                Text("\(category.rawValue) Factors")
                    .font(.custom("SFProText-Heavy", size: 36))
                    .foregroundColor(.white)

                // Node graph background rectangle
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "180b53")!)
                        .frame(height: 250)
                        .padding(.horizontal, 20)
                        .padding(.top, 25)
                        .padding(.bottom, 0)

                    // Draw line connecting nodes
                    Path { path in
                        let nodeCenters = getNodeCenters()
                        path.move(to: nodeCenters[0])
                        for center in nodeCenters.dropFirst() {
                            path.addLine(to: center)
                        }
                    }
                    .stroke(Color.white, lineWidth: 2)

                    // Node graph with 4 static nodes, drawn over the path
                    ForEach(0..<4, id: \.self) { index in
                        let nodeCenter = getNodeCenters()[index]
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: getIconName(for: index))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(hex: "180b53")!)
                            )
                            .position(nodeCenter) // Position node exactly at the path point
                            .onTapGesture {
                                selectedNodeIndex = index
                                showFactorDetail = true // Trigger navigation
                            }
                    }
                }

                // Label above the percentage tiles
                Text("Your Analytics")
                    .font(.custom("SFProText-Heavy", size: 28))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                // 2x2 grid of percentage tiles
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(0..<4) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "180b53")!)
                                .frame(height: 100)
                            
                            Text(getPercentageChange(for: index))
                                .font(.custom("SFProText-Heavy", size: 24))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // "Add Factor" button at the bottom right
                HStack {
                    Spacer()
                    Button(action: {
                        // No action currently
                    }) {
                        Text("Add Factor")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "180b53")!)
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 20)
                }
            }
            // Present FactorDetailView when a node is tapped
            .fullScreenCover(isPresented: $showFactorDetail) {
                FactorDetailView() // Present detail view when node is tapped
            }
        }
    }

    // Helper function to return the icon name for each node
    private func getIconName(for index: Int) -> String {
        let icons = ["heart.fill", "brain.head.profile", "bolt.fill", "person.fill"]
        return icons[index]
    }

    // Helper function to return the percentage change for each tile
    private func getPercentageChange(for index: Int) -> String {
        let changes = ["+5%", "-10%", "+8%", "-3%"]
        return changes[index]
    }

    // Helper function to get the centers of each node based on current positions
    private func getNodeCenters() -> [CGPoint] {
        let startX: CGFloat = UIScreen.main.bounds.width / 2 // Center of the screen
        let startY: CGFloat = 150 // Adjusted Y point within the rectangle for centering
        
        return nodePositions.map { position in
            CGPoint(x: startX + position.width, y: startY + position.height)
        }
    }
}



// Detail view for the selected factor (Mood Detail)
struct FactorDetailView: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    
    var sampleData: [Double] = [0.4, 0.6, 0.5, 0.8, 0.75, 0.6, 0.85] // Example data

    var body: some View {
        ZStack {
            // Set the same background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Progress circle for the factor's score
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75) // Example progress of 75%
                        .stroke(Color.white, lineWidth: 20)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90)) // Start from top
                    Text("75") // Example score
                        .font(.custom("SFProText-Heavy", size: 36))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // Line graph for score history
                VStack {
                    Text("Score Over the Last Month")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.white)
                    LineGraph(data: sampleData) // Custom LineGraph view
                        .stroke(Color.white, lineWidth: 2)
                        .frame(height: 200)
                }
                .padding(.top, 20)
                
                // Placeholder for scoring details
                VStack(alignment: .leading) {
                    Text("Scoring Details")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.white)
                    Text("Placeholder text for scoring details. This will include more detailed explanations and insights about the score.")
                        .font(.custom("SFProText-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the detail view
                }) {
                    Text("Back")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "180b53")!)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// Line graph shape
struct LineGraph: Shape {
    var data: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard data.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(data.count - 1)
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index) * stepX, y: rect.height * (1 - CGFloat(value)))
        }

        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
}

// Preview for testing
struct FactorPage_Previews: PreviewProvider {
    static var previews: some View {
        FactorPage(category: .emotional)
    }
}
