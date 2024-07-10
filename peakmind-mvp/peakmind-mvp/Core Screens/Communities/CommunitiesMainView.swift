import SwiftUI

struct CommunitiesMainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let avatarIcons = ["Raj": "IndianIcon", "Mikey": "AsianIcon", "Trevor": "WhiteIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]
    @Binding var search: String

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HeaderView(avatarIcons: avatarIcons, search: $search).environmentObject(viewModel)
                    Text("The communities hub is currently under construction. What is currently displayed to you is a sneak peek of how it will be once completed! Click the anxiety community for a preview.")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, -5)
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.center)
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
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var communitiesViewModel: CommunitiesViewModel

    let avatarIcons: [String: String]
    @Binding var search: String

    var body: some View {
        HStack {
            if let user = viewModel.currentUser {
                let avatarIcon = avatarIcons[user.selectedAvatar] ?? "DefaultIcon"
                
                NavigationLink(destination: UserProfileView().environmentObject(viewModel).environmentObject(communitiesViewModel)) {
                    Image(avatarIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.leading, 20)
                }
            } else {
                NavigationLink(destination: UserProfileView().environmentObject(viewModel).environmentObject(communitiesViewModel)) {
                    Image("DefaultIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }

            Spacer()

            SearchBar(searchText: $search)
                .frame(height: 40)
                .padding(.horizontal, 10)

            Spacer()

            NavigationLink(destination: MessageListView().environmentObject(viewModel)) {
                Image(systemName: "envelope.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            .padding(.trailing, 20)
        }
    }
}

struct MyCommunitiesSection: View {
    var body: some View {
        VStack(spacing: 5) {
            SectionTitle(title: "My Communities")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 10) {
                    ForEach(["anxiety", "gaming", "gardening", "sports", "ptsd", "art", "wellness", "movies"], id: \.self) { imageName in
                        if imageName == "anxiety" {
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
    @EnvironmentObject var viewModel: AuthViewModel

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
    @Binding var searchText: String

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
