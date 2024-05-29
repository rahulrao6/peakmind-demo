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
    
    var netVotes: Int {
        return upvotes - downvotes
    }
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

    func timeElapsedSince(_ timestamp: Timestamp) -> String {
        let now = Date()
        let elapsed = now.timeIntervalSince(timestamp.dateValue())
        let minutes = Int(elapsed / 60)
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
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
    @State private var showTextPostModal = false

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
                        NavigationLink(destination: FullPostView(post: post).environmentObject(viewModel).environmentObject(AuthviewModel)) {
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
                                    VStack(alignment: .trailing) {
                                        Image(viewModel.getAvatarIcon(for: post.userId))
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                        Text(post.userName)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        Text(viewModel.timeElapsedSince(post.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                                Divider()
                                    .background(Color.white)
                                    .frame(height: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.black.opacity(0.5))
            }

            Button(action: {
                showCreatePostModal = true
            }) {
                Text("Create a Post")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iceBlue)
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
        .onAppear {
            viewModel.loadPosts(for: community.id!)
        }
    }
}

extension CommunitiesViewModel {
    func getAvatarIcon(for userId: String) -> String {
        // RAJ plz fix this and make it so it uses the right icon
        return "Girl1Icon"
    }
}

struct CreatePostModal: View {
    @Binding var showTextPostModal: Bool
    @Environment(\.presentationMode) var presentationMode // To dismiss the CreatePostModal
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
                    .background(Color.iceBlue)
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
                TextPostModal(communityId: communityId, onPost: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
            Spacer()
        }
        .padding()
        .onAppear {
            showTextPostModal = true // Automatically select the Text option
        }
    }
}

struct TextPostModal: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var communityId: String
    var onPost: () -> Void // Callback to dismiss the CreatePostModal

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.loadPosts(for: communityId)
                    onPost() // Call the callback to dismiss the CreatePostModal
                }
            }) {
                Text("Post")
                    .padding()
                    .background(Color.mediumBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}

struct FullPostView: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var post: Post
    
    @State private var commentText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(post.content.components(separatedBy: "\n").first ?? "")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text(post.content.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Image(viewModel.getAvatarIcon(for: post.userId))
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Text(post.userName)
                        .font(.footnote)
                        .foregroundColor(.white)
                    Text(viewModel.timeElapsedSince(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            HStack {
                Button(action: {
                    viewModel.upvotePost(post)
                }) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.white)
                }
                Text("\(post.netVotes)")
                    .foregroundColor(.white)
                Button(action: {
                    viewModel.downvotePost(post)
                }) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.white)
                }
            }
            .padding(.top)
            Divider()
                .background(Color.white)
                .frame(height: 2)
            Text("Comments")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(viewModel.comments) { comment in
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(comment.content)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.top, 2)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Image(viewModel.getAvatarIcon(for: comment.userId))
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            Text(comment.userName)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                            Text(viewModel.timeElapsedSince(comment.timestamp))
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.vertical, 5)
                Divider()
                    .background(Color.white)
                    .frame(height: 2)
            }
            Spacer()
            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                Button(action: {
                    let comment = Comment(userId: AuthviewModel.userSession?.uid ?? "", userName: AuthviewModel.currentUser?.username ?? "", postId: post.id ?? "", content: commentText, timestamp: Timestamp())
                    viewModel.addComment(comment)
                    commentText = ""
                }) {
                    Text("Post")
                        .padding()
                        .background(Color.mediumBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
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
