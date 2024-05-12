import SwiftUI

struct AnxietyCommunityView: View {
    // Properties for managing the selected subcategory
    @State private var selectedSubcategory = "Featured"

    var body: some View {
        VStack {
            HStack {
                // Community profile picture
                Image("anxiety")
                    .resizable()
                    .frame(width: 130, height: 130)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)

                VStack(alignment: .leading) {
                    // Community title
                    Text("Anxiety")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 0) // More padding below the title
                        .foregroundColor(.white)

                    // Community description
                    Text("Welcome to the anxiety community, where you can find a supportive group of people that share similar struggles.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 10)

            // Subcategories panel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["Featured", "Latest", "Polls", "Multimedia", "Following feed"], id: \.self) { category in
                        Button(action: {
                            self.selectedSubcategory = category
                        }) {
                            Text(category)
                                .padding()
                                .background(self.selectedSubcategory == category ? Color.iceBlue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }

            // Scrollable feed based on selected subcategory
            ScrollView {
                VStack {
                    ForEach(0..<10) { item in
                        Text("\(selectedSubcategory) Post \(item + 1)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .background(
            Image("MainBGDark") // Using an image as a background
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Community", displayMode: .inline)
    }
}

struct AnxietyCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        AnxietyCommunityView()
    }
}
