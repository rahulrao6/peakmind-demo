import SwiftUI

struct CommunitiesMainView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HeaderView()
                    MyCommunitiesSection()
                    TopCommunitiesSection()
                        .padding(.top, 0)
                    RecommendedCommunitiesSection()
                }
            }
            .background(
                Image("MainBGDark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            NavigationLink(destination: UserProfileView()) {
                Image("Girl1Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            Spacer()

            SearchBar()
                .frame(height: 40)

            Spacer()

            Button(action: {
                // Action for notification
            }) {
                Image(systemName: "bell.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

struct MyCommunitiesSection: View {
    var body: some View {
        VStack(spacing: 5) {
            SectionTitle(title: "My Communities")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 10) {
                    // Iterating over community icons
                    ForEach(["anxiety", "gaming", "gardening", "sports", "ptsd", "art", "wellness", "movies"], id: \.self) { imageName in
                        if imageName == "anxiety" {
                            // Navigation Link for the Anxiety community
                            NavigationLink(destination: AnxietyCommunityView()) {
                                communityButton(imageName: imageName)
                            }
                        } else {
                            Button(action: {
                                // Action for other community buttons
                            }) {
                                communityButton(imageName: imageName)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            .frame(height: 220)
        }
    }
    
    @ViewBuilder
    private func communityButton(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
    }
}

struct TopCommunitiesSection: View {
    var body: some View {
        VStack(spacing: 5) {
            SectionTitle(title: "Top Communities")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ButtonView(buttonImage: "coping")
                    ButtonView(buttonImage: "family")
                    ButtonView(buttonImage: "movies")
                    ButtonView(buttonImage: "GYM")

                }
                
            }
            .padding()
        }
    }
}

struct RecommendedCommunitiesSection: View {
    var body: some View {
        VStack(spacing: 5) {
            SectionTitle(title: "Recommended Communities")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ButtonView(buttonImage: "wellness")
                    ButtonView(buttonImage: "meditation")
                    ButtonView(buttonImage: "GYM")
                    ButtonView(buttonImage: "family")
                }
            }
            .padding()
        }
    }
}

struct SectionTitle: View {
    var title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.leading)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct SearchBar: View {
    @State private var searchText = ""
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct GridButtonsView: View {
    var buttonImages: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(spacing: 5), GridItem(), GridItem(spacing: 5)], spacing: 15) {
            ForEach(buttonImages, id: \.self) { imageName in
                Button(action: {
                    // Action for button
                }) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }
                .padding(.horizontal, 50) // Adjust padding to move buttons closer
            }
        }
    }
}

struct ButtonView: View {
    var buttonImage: String
    var body: some View {
        Button(action: {
            // Action for button
        }) {
            Image(buttonImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }
}

// Preview for the CommunitiesMainView
struct CommunitiesMainView_Previews: PreviewProvider {
    static var previews: some View {
        CommunitiesMainView()
    }
}
