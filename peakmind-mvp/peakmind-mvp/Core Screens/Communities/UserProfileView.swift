import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var communitiesViewModel: CommunitiesViewModel
    @State private var showFollowers = false
    @State private var showFollowing = false
    @State private var bioText = "This is a sample bio. Click here to edit and share more about yourself."
    @State private var isEditing = false
    let avatarIcons = ["Raj": "RajIcon", "Mikey": "MikeyIcon", "Trevor": "TrevorIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]
    @State private var followerCount = 0 // State variable for follower count

    var body: some View {
        if let user = viewModel.currentUser {
            let avatarIcon = avatarIcons[user.selectedAvatar] ?? "DefaultIcon"
            let bioText = user.bio // Initialize bioText with the current bio
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(avatarIcon) // Profile picture
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.leading, 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username) // Username
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(user.bio)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                            
                            Button("Edit") {
                                isEditing = true
                            }
                            .foregroundColor(.blue)
                            .sheet(isPresented: $isEditing) {
                                BioEditView(bioText: $bioText, isEditing: $isEditing)
                                    .environmentObject(viewModel) // Pass the viewModel to the BioEditView
                            }
                            
                            }
                            .padding(.top, 30)
                        }
                        
                        HStack {
                            VStack {
                                Text("\(user.friends.count)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                                
                                Text("Following")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        showFollowing = true
                                    }
                                    .sheet(isPresented: $showFollowing) {
                                        FollowingView()
                                            .environmentObject(viewModel)
                                    }
                            }
                            .padding([.leading, .top, .bottom], 20)
                            
                            Spacer()
                            
                            VStack {
                                Text("\(followerCount)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                                
                                Text("Followers")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        showFollowers = true
                                    }
                                    .sheet(isPresented: $showFollowers) {
                                        FollowersView()
                                            .environmentObject(viewModel)
                                    }
                            }
                            .padding([.trailing, .top, .bottom], 20)
                        }
                        .background(Color.blue.opacity(0.5))
                        
                        
                        Text("Your Posts")
                            .font(.title2)
                            .bold()
                            .padding(.leading, 20)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: Array(repeating: .init(.fixed(160)), count: 2), spacing: 10) {
                                ForEach(communitiesViewModel.userPosts) { post in
                                    VStack {
                                        if let fileType = post.fileType, let fileUrlString = post.fileUrl, let fileUrl = URL(string: fileUrlString) {
                                            AsyncImage(url: fileUrl) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                        
                                        
                                        Text(post.content ?? "")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 120, height: 160)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                            .frame(height: 340) // Adjust height to contain two rows
                            .padding(.horizontal, 20)
                        }
                        
                    }
                }
                .background(Image("MainBGDark")) // Adjust according to actual asset name if it's different
                .navigationBarTitle("Profile", displayMode: .inline)
                .onAppear {
                    communitiesViewModel.loadUserPosts(userId: user.id) // Load the user's posts on appear
                    // Fetch the followers count
                    viewModel.fetchFollowers { followers in
                        followerCount = followers.count // Update the follower count
                    }
                }
            }
            
        }
    }
    
    struct BioEditView: View {
        @Binding var bioText: String
        @Binding var isEditing: Bool
        @EnvironmentObject var viewModel: AuthViewModel // Add this line
        
        
        var body: some View {
            VStack {
                TextEditor(text: $bioText)
                    .padding()
                Button("Done") {
                    UIApplication.shared.endEditing() // Hide keyboard
                    viewModel.updateBio(newBio: bioText) // Update bio in Firebase
                    isEditing = false // Dismiss the sheet
                }
            }
            .padding()
        }
    }
    

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(AuthViewModel())
    }
}

struct FollowersView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var followers: [UserData] = []
    let avatarIcons = ["Raj": "RajIcon", "Mikey": "MikeyIcon", "Trevor": "TrevorIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]
    var body: some View {

        List(followers) { user in
            HStack {
                Image(avatarIcons[user.selectedAvatar] ?? "DefaultIcon") // Profile picture // Profile picture
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.headline)
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            viewModel.fetchFollowers { fetchedFollowers in
                followers = fetchedFollowers
            }
        }
        .navigationTitle("Followers")
    }
}

struct FollowingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var following: [UserData] = []
    let avatarIcons = ["Raj": "RajIcon", "Mikey": "MikeyIcon", "Trevor": "TrevorIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]
    var body: some View {
        List(following) { user in
            HStack {
                Image(avatarIcons[user.selectedAvatar] ?? "DefaultIcon") // Profile picture
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.headline)
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            viewModel.fetchFollowing { fetchedFollowing in
                following = fetchedFollowing
            }
        }
        .navigationTitle("Following")
    }
}
