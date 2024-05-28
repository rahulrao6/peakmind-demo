
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import Combine
import SwiftUI

struct Community: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var image: String
}

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userName: String
    var communityId: String
    var content: String
    var timestamp: Timestamp
}

class CommunitiesViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var posts: [Post] = []

    private var db = Firestore.firestore()
    private var postsListener: ListenerRegistration?

    func loadCommunities() {
        db.collection("communities").getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                self?.communities = []
                return
            }
            self?.communities = documents.compactMap { try? $0.data(as: Community.self) }
        }
    }

    func loadPosts(for communityId: String) {
        // Remove existing listener if any
        postsListener?.remove()

        postsListener = db.collection("posts")
            .whereField("communityId", isEqualTo: communityId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    self?.posts = []
                    return
                }
                self?.posts = documents.compactMap { try? $0.data(as: Post.self) }
            }
    }

    func addPost(_ post: Post) {
        do {
            let _ = try db.collection("posts").addDocument(from: post)
        } catch {
            print("Error adding post: \(error)")
        }
    }
}

struct CommunitiesMainView2: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let avatarIcons = ["Raj": "IndianIcon", "Mikey": "AsianIcon", "Trevor": "WhiteIcon", "Girl1": "Girl1Icon", "Girl2": "Girl2Icon", "Girl3": "Girl3Icon"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HeaderView(avatarIcons: avatarIcons).environmentObject(authViewModel)
                    Text("The communities hub is currently under construction. What is currently displayed to you is a sneak peek of how it will be once completed! Click the anxiety community for a preview.")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, -5)
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.center)
                    MyCommunitiesSection2().environmentObject(authViewModel.communitiesViewModel).environmentObject(authViewModel)
                    TopCommunitiesSection().environmentObject(authViewModel.communitiesViewModel).environmentObject(authViewModel)
                        .padding(.top, 0)
                    RecommendedCommunitiesSection().environmentObject(authViewModel.communitiesViewModel)
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
        .onAppear {
            authViewModel.communitiesViewModel.loadCommunities()
        }
    }
}

struct MyCommunitiesSection2: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 5) {
            SectionTitle(title: "My Communities")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 10) {
                    ForEach(viewModel.communities) { community in
                        NavigationLink(destination: CommunityDetailView(community: community).environmentObject(viewModel).environmentObject(AuthviewModel)) {
                            communityButton(imageName: community.image)
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

struct CommunityDetailView: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var community: Community
    
    @State private var newPostContent = ""

    var body: some View {
        VStack {
            HStack {
                Image(community.image)
                    .resizable()
                    .frame(width: 130, height: 130)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                VStack(alignment: .leading) {
                    Text(community.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(community.description)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 10)

            ScrollView {
                VStack {
                    ForEach(viewModel.posts) { post in
                        VStack(alignment: .leading) {
                            Text("\(post.content) by \(post.userName)")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                        }
                        .padding(.horizontal)
                    }
                }
            }

            HStack {
                TextField("Write a post...", text: $newPostContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 44)
                Button(action: {
                    let post = Post(userId: AuthviewModel.userSession?.uid ?? "", userName: AuthviewModel.currentUser?.username ?? "", communityId: community.id!, content: newPostContent, timestamp: Timestamp())
                    viewModel.addPost(post)
                    newPostContent = ""
                }) {
                    Text("Post")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(
            Image("MainBGDark")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Community", displayMode: .inline)
        .onAppear {
            viewModel.loadPosts(for: community.id!)
        }
    }
}

