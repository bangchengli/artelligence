import SwiftUI
import UIKit

enum UserAction {
    case none, liked, disliked
}

struct Post: Identifiable {
    let id = UUID()
    let userID = UUID()
    var text: String
    var image: UIImage?
    var likes: Int = 0
    var dislikes: Int = 0
    var userActions: [UUID: UserAction] = [:]
}

struct Comment: Identifiable {
    let id = UUID()
    var text: String
    var replies: [Comment] = []
    var likes: Int = 0
    var dislikes: Int = 0
    var userActions: [UUID: UserAction] = [:]
    @State var showReplyField = false 
}

struct PostDetailView: View {
    @Binding var post: Post
    @State private var currentUserID = UUID()
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""

    var body: some View {
        VStack {
            Text("User ID: \(post.userID.uuidString)")
                .font(.caption)
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 10) {
                if let image = post.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                Text(post.text)
            }

            Divider()

            HStack {
                Button(action: {
                    updateUserAction(action: .liked, for: &post)
                }) {
                    HStack {
                        Image(systemName: currentAction(for: post) == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(currentAction(for: post) == .liked ? .blue : .gray)
                        Text("\(post.likes)")
                    }
                }

                Spacer().frame(width: 10)

                Button(action: {
                    updateUserAction(action: .disliked, for: &post)
                }) {
                    HStack {
                        Image(systemName: currentAction(for: post) == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(currentAction(for: post) == .disliked ? .red : .gray)
                        Text("\(post.dislikes)")
                    }
                }

                Spacer().frame(width: 10)

                Button(action: {
                    sharePost()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Comments")
                    .fontWeight(.bold)

                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        if !newComment.isEmpty {
                            comments.append(Comment(text: newComment))
                            newComment = ""
                        }
                    }) {
                        Text("Comment")
                            .foregroundColor(.blue)
                    }
                }

                ForEach(comments) { comment in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ID: \(comment.id.uuidString)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text(comment.text)

                        HStack {
                            Button(action: {
                                updateCommentAction(action: .liked, for: comment)
                            }) {
                                Image(systemName: currentAction(for: comment) == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundColor(currentAction(for: comment) == .liked ? .blue : .gray)
                                Text("\(comment.likes)")
                            }

                            Spacer().frame(width: 10)

                            Button(action: {
                                updateCommentAction(action: .disliked, for: comment)
                            }) {
                                Image(systemName: currentAction(for: comment) == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundColor(currentAction(for: comment) == .disliked ? .red : .gray)
                                Text("\(comment.dislikes)")
                            }

                            Spacer().frame(width: 10)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    private func currentAction(for item: any Identifiable) -> UserAction {
        if let comment = item as? Comment {
            return comment.userActions[currentUserID] ?? .none
        } else if let post = item as? Post {
            return post.userActions[currentUserID] ?? .none
        } else {
            return .none
        }
    }

    private func updateCommentAction(action: UserAction, for comment: Comment) {
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            switch currentAction(for: comment) {
            case .none:
                if action == .liked {
                    comments[index].likes += 1
                } else {
                    comments[index].dislikes += 1
                }
            case .liked:
                comments[index].likes -= 1
                if action == .disliked {
                    comments[index].dislikes += 1
                }
            case .disliked:
                comments[index].dislikes -= 1
                if action == .liked {
                    comments[index].likes += 1
                }
            }

            if currentAction(for: comment) == action {
                comments[index].userActions[currentUserID] = .none
            } else {
                comments[index].userActions[currentUserID] = action
            }
        }
    }

    private func updateUserAction(action: UserAction, for post: inout Post) {
        switch currentAction(for: post) {
        case .none:
            if action == .liked {
                post.likes += 1
            } else {
                post.dislikes += 1
            }
        case .liked:
            post.likes -= 1
            if action == .disliked {
                post.dislikes += 1
            }
        case .disliked:
            post.dislikes -= 1
            if action == .liked {
                post.likes += 1
            }
        }

        if currentAction(for: post) == action {
            post.userActions[currentUserID] = .none
        } else {
            post.userActions[currentUserID] = action
        }
    }
    private func sharePost() {
        var itemsToShare: [Any] = [post.text]

        if let image = post.image, let imageData = image.pngData() {
            itemsToShare.append(imageData)
        }

        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )

        UIApplication.shared.windows.first?.rootViewController?.present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }
}

struct ForumView: View {
    @State private var posts: [Post] = [
        Post(text: "This is a sample post.", image: nil),
        Post(text: "Here's another one.", image: nil)
    ]

    @State private var showingImagePicker = false
    @State private var previewImage: UIImage?
    @State private var textInput: String = ""

    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: binding(for: post))) {
                            VStack(alignment: .leading) {
                                Text("UID: \(post.userID.uuidString)")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                if let image = post.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                Text(post.text)
                            }
                        }
                    }
                }
                .navigationBarTitle("Forum")

                HStack {
                    if let previewImage = previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    TextField("Type your post here...", text: $textInput)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo")
                            .padding()
                    }

                    Button("Post") {
                        if !textInput.isEmpty || previewImage != nil {
                            posts.append(Post(text: textInput, image: previewImage))
                            textInput = ""
                            previewImage = nil // Clear the preview image after posting
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: {}) {
                ImagePicker(image: $previewImage)
            }
        }
    }

    private func binding(for post: Post) -> Binding<Post> {
        guard let postIndex = posts.firstIndex(where: { $0.id == post.id }) else {
            fatalError("Can't find post in array")
        }
        return $posts[postIndex]
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var mode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Not needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.mode.wrappedValue.dismiss()
        }
    }
}
