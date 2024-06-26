import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var communitiesViewModel: CommunitiesViewModel

    @State private var bioText = "This is a sample bio. Click here to edit and share more about yourself."
    @State private var isEditing = false
    let avatarIcons = ["Raj": "RajIcon", "Mikey": "MikeyIcon", "Trevor": "TrevorIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]

    var body: some View {
        if let user = viewModel.currentUser {
            let avatarIcon = avatarIcons[user.selectedAvatar] ?? "DefaultIcon"

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
                            
                            Text(bioText)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                            
                            Button("Edit") {
                                isEditing = true
                            }
                            .foregroundColor(.blue)
                            .sheet(isPresented: $isEditing) {
                                BioEditView(bioText: $bioText, isEditing: $isEditing)
                            }
                        }
                        .padding(.top, 30)
                    }
                    
                    HStack {
                        VStack {
                            Text("256")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                            
                            Text("Following")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding([.leading, .top, .bottom], 20)
                        
                        Spacer()
                        
                        VStack {
                            Text("1.2K")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                            
                            Text("Followers")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding([.trailing, .top, .bottom], 20)
                    }
                    .background(Color.blue.opacity(0.5))


                    Text("Your Posts")
                        .font(.title2)
                        .bold()
                        .padding(.leading, 20)
                        .foregroundColor(.white)
                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        LazyHGrid(rows: Array(repeating: .init(.fixed(160)), count: 2), spacing: 10) {
//                        ForEach(communitiesViewModel.userPosts, id: \.self) { post in
//                                VStack {
//                                    if let imageUrl = post.fileUrl {
//                                        AsyncImage(url: URL(string: imageUrl)) { image in
//                                            image.resizable()
//                                        } placeholder: {
//                                            ProgressView()
//                                        }
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 120, height: 120)
//                                        .clipped()
//                                    } else {
//                                        Image("defaultPostImage")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 120, height: 120)
//                                            .clipped()
//                                    }
//                                    
//                                    Text(post.title)
//                                        .font(.caption)
//                                        .foregroundColor(.white)
//                                }
//                                .frame(width: 120, height: 160)
//                                .background(Color.gray.opacity(0.5))
//                                .cornerRadius(8)
//                            }
//                        }
//                        .frame(height: 340) // Adjust height to contain two rows
//                        .padding(.horizontal, 20)
//                    }
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
            }
        }
        
    }
}

struct BioEditView: View {
    @Binding var bioText: String
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            TextEditor(text: $bioText)
                .padding()
            Button("Done") {
                UIApplication.shared.endEditing() // Hide keyboard
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
