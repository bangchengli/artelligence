import SwiftUI
import AuthenticationServices

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    var onSignedIn: ((String, String) -> Void)?
    var onSignedOut: (() -> Void)?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        fatalError("Unable to find a suitable presentation anchor.")
    }
    
    func authorize() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let firstName = appleIDCredential.fullName?.givenName ?? ""
            let lastName = appleIDCredential.fullName?.familyName ?? ""
            
            onSignedIn?(firstName, lastName)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Apple sign-in failed: \(error.localizedDescription)")
    }
    
    func signOut() {
        onSignedOut?()
    }
}


struct CreateAccountView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isSignedIn: Bool = false
    
    let appleSignInCoordinator = AppleSignInCoordinator()
    
    var body: some View {
        VStack(spacing: 20) {
            if isSignedIn {
                Text("Welcome, \(firstName) \(lastName)!")
                    .font(.headline)
                
                Button("Log Out") {
                    appleSignInCoordinator.signOut()
                    isSignedIn = false
                }
                .font(.title)
            } else {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            let firstName = appleIDCredential.fullName?.givenName ?? ""
                            let lastName = appleIDCredential.fullName?.familyName ?? ""
                            self.firstName = firstName
                            self.lastName = lastName
                            isSignedIn = true
                            print("Sign in with Apple success")
                        }
                    case .failure(let error):
                        // Handle error
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(width: 200, height: 44)
            }
        }
        .onAppear {
            appleSignInCoordinator.onSignedIn = { firstName, lastName in
                self.firstName = firstName
                self.lastName = lastName
                isSignedIn = true
            }
            
            appleSignInCoordinator.onSignedOut = {
                isSignedIn = false
            }
        }
    }
}
