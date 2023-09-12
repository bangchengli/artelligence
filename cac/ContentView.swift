import SwiftUI
import OpenAIKit
import Photos

struct ContentView: View {
    @ObservedObject private var imageGenerator = OpenAIImageGenerator()
    @State private var generatedImage: UIImage?
    @State private var selectedFontName: String = "System"
    @State private var textColor: Color = .black
    @State private var textXString: String = ""
    @State private var textYString: String = ""
    @State private var isFontPickerVisible = false
    @State private var isShareSheetPresented = false
    @State private var isImageGenerated = false
    @State private var fontColor: Color = .black
    @State private var imageStyle: String = ""
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var showDownloadSuccessMessage: Bool = false
    @State private var isImagePreviewPresented = false
    @State private var baseImage: UIImage?
    @State private var previousFontColor: Color = .black
    @State private var previousTextPosition: CGPoint?
    private let positionAdjustmentValue: CGFloat = 20.0
    @State private var didFontChange: Bool = false
    @State private var didColorChange: Bool = false
    @State private var didPositionChange: Bool = false
    @State private var originalImage: UIImage?






    private var availableFonts: [String] {
        UIFont.familyNames.sorted().flatMap { UIFont.fontNames(forFamilyName: $0) }
    }

    var body: some View {
        TabView {
            NavigationView {
                VStack(spacing: 5) {
                    Text("Describe the picture you want...")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    TextField("Enter message", text: $viewModel.contentChatText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Describe the image style...")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    TextField("Leave black if default", text: $imageStyle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    HStack(spacing: 5) {
                        Button("Top Left") {
                            print(viewModel.contentChatText.count)
                            setPosition(x: 10, y: 25)
                        }
                        .frame(width: 80, height: 45)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .font(.system(size: 15))

                        Button("Top Right") {
                            if viewModel.contentChatText.count < 45 && viewModel.contentChatText.count > 30
                            {
                                setPosition(x: 280, y: 25)
                            }
                            else if viewModel.contentChatText.count < 30
                            {
                                setPosition(x: 550, y: 25)
                            }
                            else if viewModel.contentChatText.count > 45
                            {
                                setPosition(x: 300, y: 25)
                            }
                        }
                        .frame(width: 80, height: 45)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .font(.system(size: 15))
                        
                        Button("Bottom Left") {
                            setPosition(x: 10, y: 890)
                        }
                        .frame(width: 80, height: 45)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .font(.system(size: 15))
                        
                        Button("Bottom Right") {
                            if viewModel.contentChatText.count < 45 && viewModel.contentChatText.count > 30
                            {
                                setPosition(x: 280, y: 900)
                            }
                            else if viewModel.contentChatText.count < 30
                            {
                                setPosition(x: 550, y: 900)
                            }
                            else if viewModel.contentChatText.count > 45
                            {
                                setPosition(x: 300, y: 900)
                            }
                        }
                        .frame(width: 80, height: 45)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .font(.system(size: 15))
                    }
                    .padding(.bottom, 10)
                    HStack {
                        Button(action: {
                            adjustTextPosition(x: -positionAdjustmentValue, y: 0)
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button(action: {
                            adjustTextPosition(x: 0, y: -positionAdjustmentValue)
                        }) {
                            Image(systemName: "arrow.up")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button(action: {
                            adjustTextPosition(x: 0, y: positionAdjustmentValue)
                        }) {
                            Image(systemName: "arrow.down")
                        }
                        
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button(action: {
                            adjustTextPosition(x: positionAdjustmentValue, y: 0)
                        }) {
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    ZStack {
                        if let image = generatedImage {
                            Image(uiImage: image)
                                .resizable()
                                .padding()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    isImagePreviewPresented = true
                                }
                        }

                        if imageGenerator.isGeneratingImage {
                            Text("Generating image...")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                    }
                    VStack(spacing: 2) {
                        if showDownloadSuccessMessage {
                            Text("Download success!")
                                .font(.footnote)
                                .foregroundColor(.green)
                                .animation(.easeIn(duration: 1.0), value: showDownloadSuccessMessage)
                        }
                        Button(action: {
                            isFontPickerVisible = true
                            didFontChange = true
                        }) {
                            Text("Select Font")
                        }
                    }
                    .padding()
                    VStack(spacing: 2) {
                        ColorPicker("Font Color", selection: $fontColor)
                            .onChange(of: fontColor, perform: { _ in
                                didColorChange = true
                            })
                            .padding(.horizontal)
                    }
                    .padding()
                    HStack {
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            generateImage()
                        }) {
                            Text("Generate")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(imageGenerator.isGeneratingImage)

                        if isImageGenerated {
                            Button(action: {
                                saveImage()
                            }) {
                                Text("Download")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                shareImage()
                            }) {
                                Text("Share")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Generate")
                .offset(y: -50)
                .sheet(isPresented: $isImagePreviewPresented) {
                    if let image = generatedImage {
                        ImagePreviewView(image: image)
                    }
                }

            }
            .tabItem {
                Image(systemName: "camera.viewfinder")
                Text("Generate Image")
            }
            .sheet(isPresented: $isFontPickerVisible) {
                FontPicker(selectedFontName: $selectedFontName)
            }
            .onAppear {
                loadFonts()
            }

            NavigationView {
                ChatView()
            }
            .tabItem {
                Image(systemName: "message")
                Text("Chat")
            }
            ForumView()
                .tabItem{
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Forum")
                }
        }
        .sheet(isPresented: $isShareSheetPresented, onDismiss: {
            
        }) {
            if let image = generatedImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    private func adjustTextPosition(x: CGFloat, y: CGFloat) {
        let currentX = CGFloat(Double(textXString) ?? 0.0)
        let currentY = CGFloat(Double(textYString) ?? 0.0)
        
        textXString = String(format: "%.2f", currentX + x)
        textYString = String(format: "%.2f", currentY + y)
        didPositionChange = true
    }

    private func setPosition(x: CGFloat, y: CGFloat) {
        self.textXString = String(format: "%.2f", x)
        self.textYString = String(format: "%.2f", y)
        didPositionChange = true
    }
    
    private func loadFonts() {
        for font in availableFonts {
            UIFont(name: font, size: 14)
        }
    }

    private func generateImage() {
        Task {
            if didFontChange || didColorChange || didPositionChange {
                renderTextOntoImage()
            } else {
                do {
                    imageGenerator.isGeneratingImage = true
                    
                    let combinedPrompt = "\(imageStyle), \(viewModel.contentChatText)"
                    
                    await imageGenerator.generateImage(prompt: combinedPrompt)
                    if let generatedImage = imageGenerator.generatedImage {
                        self.originalImage = generatedImage
                        renderTextOntoImage()
                        
                    }
                } catch {
                    print("Failed to generate image: \(error)")
                }
                imageGenerator.isGeneratingImage = false
            }
            
            didFontChange = false
            didColorChange = false
            didPositionChange = false
        }
    }
    private func renderTextOntoImage() {
        guard let currentOriginalImage = self.originalImage else { return }
        
        currentOriginalImage.renderText(prompt: viewModel.contentChatText, fontName: selectedFontName, textColor: fontColor, position: textPosition()) { renderedImage in
            DispatchQueue.main.async {
                self.generatedImage = renderedImage
                self.isImageGenerated = true
            }
        }
    }




    
    private func textPosition() -> CGPoint {
        let x = CGFloat(Double(textXString) ?? 0.0)
        let y = CGFloat(Double(textYString) ?? 0.0)
        return CGPoint(x: x, y: y)
    }

    private func saveImage() {
        guard let image = generatedImage else { return }

        let size = CGSize(width: image.size.width, height: image.size.height)
        let renderer = UIGraphicsImageRenderer(size: size)

        let renderedImage = renderer.image { context in
            image.draw(at: .zero)
        
        showDownloadSuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showDownloadSuccessMessage = false
        }
    }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: renderedImage)
                } completionHandler: { success, error in
                    if let error = error {
                        print("Error saving image to the Photos library: \(error)")
                    } else {
                        print("Image saved successfully to the Photos library.")
                    }
                }
            } else {
                print("Permission denied. Unable to save image to the Photos library.")
            }
        }
    }

    private func shareImage() {
        isShareSheetPresented = true
    }
}

extension UIImage {
    func renderText(prompt: String, fontName: String, textColor: Color, position: CGPoint, completion: @escaping (UIImage?) -> Void) {
        let font = fontName == "System" ? UIFont.systemFont(ofSize: 30) : UIFont(name: fontName, size: 30)
        let uiColor = UIColor(textColor)
        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { context in
            draw(at: .zero)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font as Any,
                .foregroundColor: uiColor,
                .paragraphStyle: paragraphStyle
            ]

            let attributedText = NSAttributedString(string: prompt, attributes: attributes)
            let textSize = attributedText.size()

            let textRect = CGRect(
                x: position.x,
                y: position.y,
                width: textSize.width,
                height: textSize.height
            )

            attributedText.draw(in: textRect)
        }

        completion(renderedImage)
    }
}

extension UIColor {
    convenience init(_ color: SwiftUI.Color) {
        let components = color.components()
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: components.opacity)
    }
}

extension SwiftUI.Color {
    func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        guard let cgColor = self.cgColor else {
            return (1, 1, 1, 1)
        }

        return (
            red: cgColor.components?[0] ?? 1,
            green: cgColor.components?[1] ?? 1,
            blue: cgColor.components?[2] ?? 1,
            opacity: cgColor.alpha
        )
    }
}


struct ImagePreviewView: View {
    let image: UIImage

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all)

            Spacer()
        }
    }
}




final class OpenAIImageGenerator: ObservableObject {
    private var openAI: OpenAI?
    @Published var generatedImage: UIImage?
    @Published var isGeneratingImage = false

    init() {
        openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: ""))
    }

    func generateImage(prompt: String) async {
        guard let openAI = openAI else { return }

        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .large,
                responseFormat: .base64Json
            )

            let result = try await openAI.createImage(parameters: params)

            if let imageData = result.data.first?.image {
                let decodedImage = try openAI.decodeBase64Image(imageData)
                generatedImage = decodedImage
            }
        } catch {
            print("Failed to generate image: \(error)")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
