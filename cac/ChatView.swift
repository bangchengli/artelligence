import SwiftUI
import OpenAIKit

class ChatViewModel: ObservableObject {
    @Published var chatText: String = ""
    @Published var contentChatText: String = ""
    @Published var responseText: String = ""
    @Published var chatHistory: String = ""
    
    func updateContentChatText(with response: String) {
        self.contentChatText = response
    }
}


struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var chatText: String = ""
    @State private var responseText: String = ""
    @State private var chatHistory: String = ""
    @State private var showCopySuccessMessage: Bool = false
    @State private var isThinking: Bool = false


    
    private let openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: "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"))
    private let promptPresets = [
        "Create a landscape with mountains and a lake. A 5-6 words sentence",
        "Design a futuristic cityscape at night. A 5-6 wordssentence",
        "Paint a portrait of a person with abstract colors. A 5-6 words sentence",
        "Illustrate a fantasy creature in a magical forest. A 5-6 words sentence"
     ]
    var body: some View {
        VStack(spacing: 20) {
            Text("Discuss prompts and more with AI!")
                .font(.headline)
            Text("We provide some prompt presets! Just click Send if you want some ideas!")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(chatHistory)
                        .foregroundColor(.gray)
                    Text(responseText)
                }
            }
            
            TextField("Enter message", text: $viewModel.chatText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                sendMessage()
            }) {
                Text("Send")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                copyAnswerToClipboard()
            }) {
                Text("Copy Answer")
                    .font(.headline)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            if showCopySuccessMessage {
                Text("Copy success!")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .animation(.easeIn(duration: 1.0), value: showCopySuccessMessage)
            }
            if isThinking {
                Text("Thinking...")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationBarTitle("Chat")
    }
    private func copyAnswerToClipboard() {
        UIPasteboard.general.string = responseText
        viewModel.updateContentChatText(with: responseText)
        showCopySuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCopySuccessMessage = false
        }
    }

    private func sendMessage() {
        isThinking = true
        
        Task {
            do {
                var prompt = "User: \(viewModel.chatText)\n"
                    
                
                if viewModel.chatText.isEmpty {
                    prompt = "User: \(promptPresets.randomElement()!)\n"
                }
                    
                let completionParameter = CompletionParameters(
                    model: "text-davinci-003",
                    prompt: [prompt],
                    maxTokens: 1000,
                    temperature: 0.98
                )
                    
                let completionResponse = try await openAI.generateCompletion(parameters: completionParameter)
                    
                if let response = completionResponse.choices.first?.text {
                    responseText = "\(response)"
                }
                    
                chatHistory += prompt
                viewModel.chatText = ""
            } catch {
                print("Error: \(error)")
            }
            isThinking = false
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().environmentObject(ChatViewModel())
    }
}
