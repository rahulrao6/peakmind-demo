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
    var upvotes: Int = 0
    var downvotes: Int = 0
}

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userName: String
    var postId: String
    var content: String
    var timestamp: Timestamp
}

class CommunitiesViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []

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

    func upvotePost(_ post: Post) {
        guard let postId = post.id else { return }
        db.collection("posts").document(postId).updateData(["upvotes": post.upvotes + 1])
    }

    func downvotePost(_ post: Post) {
        guard let postId = post.id else { return }
        db.collection("posts").document(postId).updateData(["downvotes": post.downvotes + 1])
    }

    func loadComments(for postId: String) {
        db.collection("comments")
            .whereField("postId", isEqualTo: postId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    self?.comments = []
                    return
                }
                self?.comments = documents.compactMap { try? $0.data(as: Comment.self) }
            }
    }

    func addComment(_ comment: Comment) {
        do {
            let _ = try db.collection("comments").addDocument(from: comment)
        } catch {
            print("Error adding comment: \(error)")
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
    
    @State private var showCreatePostModal = false
    @State private var showTextPostModal = true

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
                        NavigationLink(destination: FullPostView(post: post).environmentObject(viewModel)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(post.content.components(separatedBy: "\n").first ?? "")
                                            .font(.headline)
                                            .bold()
                                        Text(post.content.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                    Text(post.userName)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.black.opacity(0.5))
            }

            Button(action: {
                showCreatePostModal = true
            }) {
                Text("Create a Post")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 10)
            .sheet(isPresented: $showCreatePostModal) {
                CreatePostModal(showTextPostModal: $showTextPostModal, communityId: community.id!)
                    .environmentObject(viewModel)
                    .environmentObject(AuthviewModel)
            }
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

struct CreatePostModal: View {
    @Binding var showTextPostModal: Bool
    var communityId: String

    var body: some View {
        VStack {
            Text("Choose Post Type")
                .font(.headline)
                .padding()
            HStack {
                Button(action: {
                    showTextPostModal = true
                }) {
                    VStack {
                        Image(systemName: "text.bubble")
                        Text("Text")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {}) {
                    VStack {
                        Image(systemName: "photo")
                        Text("Image")
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {}) {
                    VStack {
                        Image(systemName: "video")
                        Text("Video")
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {}) {
                    VStack {
                        Image(systemName: "chart.bar")
                        Text("Poll")
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()

            if showTextPostModal {
                TextPostModal(communityId: communityId, showTextPostModal: $showTextPostModal)
            }
            Spacer()
        }
        .padding()
    }
}

struct TextPostModal: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var communityId: String
    @Binding var showTextPostModal: Bool

    @State private var titleText: String = ""
    @State private var bodyText: String = ""

    var body: some View {
        VStack {
            Text("New Text Post")
                .font(.headline)
                .padding()
            TextField("Title", text: $titleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Body", text: $bodyText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                let post = Post(userId: AuthviewModel.userSession?.uid ?? "", userName: AuthviewModel.currentUser?.username ?? "", communityId: communityId, content: "\(titleText)\n\(bodyText)", timestamp: Timestamp())
                viewModel.addPost(post)
                showTextPostModal = false // Close the modal
            }) {
                Text("Post")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
        .padding()
        .onChange(of: showTextPostModal) { value in
            if !value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.loadPosts(for: communityId)
                }
            }
        }
    }
}

struct FullPostView: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel

    var post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(post.content.components(separatedBy: "\n").first ?? "")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text(post.content.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                .font(.body)
                .foregroundColor(.white)
                .padding(.top, 2)
            HStack {
                Button(action: {
                    viewModel.upvotePost(post)
                }) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.white)
                }
                Text("\(post.upvotes)")
                    .foregroundColor(.white)
                Button(action: {
                    viewModel.downvotePost(post)
                }) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.white)
                }
                Text("\(post.downvotes)")
                    .foregroundColor(.white)
            }
            .padding(.top)
            Divider()
                .background(Color.white)
            Text("Comments")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(viewModel.comments) { comment in
                VStack(alignment: .leading) {
                    Text(comment.userName)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    Text(comment.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                }
                .padding(.vertical, 5)
                Divider()
                    .background(Color.white)
            }
            Spacer()
        }
        .padding()
        .background(Image("MainBGDark")
            .resizable()
            .edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.loadComments(for: post.id ?? "")
        }
    }
}
