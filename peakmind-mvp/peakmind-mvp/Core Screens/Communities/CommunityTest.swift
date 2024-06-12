import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage
import Combine
import SwiftUI
import FirebaseStorage
import AVFoundation

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
    var fileUrl: String? // New field for file URL
    var fileType: String? // New field for file type
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
    private var storage = Storage.storage()

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

    
    func uploadFile(data: Data, fileName: String, fileType: String, completion: @escaping (URL?) -> Void) {
        let storageRef = storage.reference().child("files/\(fileName)")
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading file: \(error)")
                completion(nil)
                return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                    return
                }
                completion(url)
            }
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
    
    func uploadToFireBaseVideo(url: URL,
                               success: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void) {

        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsURL.appendingPathComponent(name)
        var ur = outputURL
        convertVideo(toMPEG4FormatForVideo: url, outputURL: outputURL) { (session) in
            ur = session.outputURL!
            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        guard let data = NSData(contentsOf: ur) else {
            return
        }

        do {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
            return
        }

        let storageRef = Storage.storage().reference().child("Videos").child(name)
        storageRef.putData(data as Data, metadata: nil) { (metadata, error) in
            if let error = error {
                failure(error)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        failure(error)
                    } else if let downloadURL = url {
                        success(downloadURL.absoluteString)
                    }
                }
            }
        }
    }

    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        try? FileManager.default.removeItem(at: outputURL)
        let asset = AVURLAsset(url: inputURL, options: nil)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
}

struct CommunitiesMainView2: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var CommunitiesViewModel: CommunitiesViewModel

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
                    MyCommunitiesSection2().environmentObject(CommunitiesViewModel).environmentObject(authViewModel)
                    TopCommunitiesSection().environmentObject(CommunitiesViewModel).environmentObject(authViewModel)
                        .padding(.top, 0)
                    RecommendedCommunitiesSection().environmentObject(CommunitiesViewModel)
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
            CommunitiesViewModel.loadCommunities()
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
    @State private var showImagePostModal = false
    @State private var showVideoPostModal = false
    @State private var showPdfPostModal = false

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
                CreatePostModal(showTextPostModal: $showTextPostModal,
                                                    showImagePostModal: $showImagePostModal,
                                                    showVideoPostModal: $showVideoPostModal,
                                                    showPdfPostModal: $showPdfPostModal,
                                                    communityId: community.id!)
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
    @Binding var showImagePostModal: Bool
    @Binding var showVideoPostModal: Bool
    @Binding var showPdfPostModal: Bool
    @Environment(\.presentationMode) var presentationMode // To dismiss the CreatePostModal
    var communityId: String

    var body: some View {
        VStack {
            Text("Choose Post Type")
                .font(.headline)
                .padding()
            HStack {
                Button(action: {
                    resetModals()
                    showTextPostModal = true
                }) {
                    VStack {
                        Image(systemName: "text.bubble")
                        Text("Text")
                    }
                    .padding()
                    .background(showTextPostModal ? Color.iceBlue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {
                    resetModals()
                    showImagePostModal = true
                }) {
                    VStack {
                        Image(systemName: "photo")
                        Text("Image")
                    }
                    .padding()
                    .background(showImagePostModal ? Color.iceBlue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {
                    resetModals()
                    showVideoPostModal = true
                }) {
                    VStack {
                        Image(systemName: "video")
                        Text("Video")
                    }
                    .padding()
                    .background(showVideoPostModal ? Color.iceBlue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Button(action: {
                    resetModals()
                    showPdfPostModal = true
                }) {
                    VStack {
                        Image(systemName: "doc.text")
                        Text("PDF")
                    }
                    .padding()
                    .background(showPdfPostModal ? Color.iceBlue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()

            if showTextPostModal {
                TextPostModal(communityId: communityId, onPost: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            } else if showImagePostModal {
                FilePostModal(communityId: communityId, fileType: "image", onPost: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            } else if showVideoPostModal {
                FilePostModal(communityId: communityId, fileType: "video", onPost: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            } else if showPdfPostModal {
                FilePostModal(communityId: communityId, fileType: "pdf", onPost: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
            Spacer()
        }
        .padding()
    }

    private func resetModals() {
        showTextPostModal = false
        showImagePostModal = false
        showVideoPostModal = false
        showPdfPostModal = false
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

import SwiftUI
import UIKit
import FirebaseStorage

import SwiftUI
import UIKit
import AVFoundation
import FirebaseStorage

import SwiftUI
import UIKit
import AVFoundation
import FirebaseStorage

struct FilePostModal: View {
    @EnvironmentObject var viewModel: CommunitiesViewModel
    @EnvironmentObject var AuthviewModel: AuthViewModel

    var communityId: String
    var fileType: String // "image", "video", or "pdf"
    var onPost: () -> Void // Callback to dismiss the CreatePostModal

    @State private var selectedFile: Data? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var contentText: String = ""
    @State private var showFilePicker = false
    @State private var filePickerType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            Text("New \(fileType.capitalized) Post")
                .font(.headline)
                .padding()
            TextField("Description", text: $contentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                selectFile()
            }) {
                Text("Select \(fileType.capitalized)")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if selectedFile != nil || selectedVideoURL != nil {
                Text("\(fileType.capitalized) selected")
                    .foregroundColor(.green)
                    .padding()
            }

            Button(action: {
                uploadFile()
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
        .sheet(isPresented: $showFilePicker) {
            ImagePicker(sourceType: self.filePickerType, selectedFile: self.$selectedFile, selectedVideoURL: self.$selectedVideoURL, fileType: self.fileType)
        }
    }

    private func selectFile() {
        if fileType == "pdf" {
            self.showFilePicker = true
        } else {
            self.filePickerType = .photoLibrary
            self.showFilePicker = true
        }
    }

    private func uploadFile() {
        if let fileData = selectedFile {
            let fileName = UUID().uuidString + "." + fileType
            viewModel.uploadFile(data: fileData, fileName: fileName, fileType: fileType) { url in
                guard let url = url else { return }
                let post = Post(
                    userId: AuthviewModel.userSession?.uid ?? "",
                    userName: AuthviewModel.currentUser?.username ?? "",
                    communityId: communityId,
                    content: contentText,
                    timestamp: Timestamp(), fileUrl: url.absoluteString,
                    fileType: fileType
                )
                viewModel.addPost(post)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.loadPosts(for: communityId)
                    onPost() // Call the callback to dismiss the CreatePostModal
                }
            }
        } else if let videoURL = selectedVideoURL {
            viewModel.uploadToFireBaseVideo(url: videoURL, success: { url in
                let post = Post(
                    userId: AuthviewModel.userSession?.uid ?? "",
                    userName: AuthviewModel.currentUser?.username ?? "",
                    communityId: communityId,
                    content: contentText,
                    timestamp: Timestamp(), fileUrl: url,
                    fileType: fileType
                )
                viewModel.addPost(post)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.loadPosts(for: communityId)
                    onPost() // Call the callback to dismiss the CreatePostModal
                }
            }, failure: { error in
                print("Failed to upload video: \(error)")
            })
        }
    }
}


import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if parent.fileType == "image", let image = info[.originalImage] as? UIImage {
                parent.selectedFile = image.jpegData(compressionQuality: 1.0)
            } else if parent.fileType == "video", let videoUrl = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoUrl
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else { return }
            if parent.fileType == "pdf" {
                do {
                    let data = try Data(contentsOf: selectedFileURL)
                    parent.selectedFile = data
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedFile: Data?
    @Binding var selectedVideoURL: URL?
    var fileType: String
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        if fileType == "pdf" {
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
            documentPicker.delegate = context.coordinator
            return documentPicker
        } else {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            picker.mediaTypes = fileType == "video" ? ["public.movie"] : ["public.image"]
            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



import SwiftUI
import PDFKit
import AVKit

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

            if let fileType = post.fileType, let fileUrlString = post.fileUrl, let fileUrl = URL(string: fileUrlString) {
                if fileType == "image" {
                    AsyncImage(url: fileUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                    }
                } else if fileType == "pdf" {
                    PDFKitView(url: fileUrl)
                        .frame(height: 300)
                } else if fileType == "video" {
                    VideoPlayerView(url: fileUrl)
                        .frame(height: 300)
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

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        } else {
            print("Failed to load PDF document")
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player?.play()
    }
}
