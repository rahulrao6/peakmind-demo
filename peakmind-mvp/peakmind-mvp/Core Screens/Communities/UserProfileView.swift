import SwiftUI

struct UserProfileView: View {
    @State private var bioText = "This is a sample bio. Click here to edit and share more about yourself."
    @State private var isEditing = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(user.selectedAvatar) // Profile picture
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.leading, 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PeakMindPro") // Username
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
                                BioEditView(bioText: $bioText)
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: Array(repeating: .init(.fixed(160)), count: 2), spacing: 10) {
                            ForEach(0..<40) { index in
                                VStack {
                                    Image("post\(index % 10)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                    
                                    Text("Post #\(index + 1)")
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
        }
    }
}

struct BioEditView: View {
    @Binding var bioText: String

    var body: some View {
        VStack {
            TextEditor(text: $bioText)
                .padding()
            Button("Done") {
                UIApplication.shared.endEditing() // Hide keyboard
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
    }
}
