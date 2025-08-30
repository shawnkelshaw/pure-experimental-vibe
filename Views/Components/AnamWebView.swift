import SwiftUI
import SafariServices

struct AnamSafariView: UIViewControllerRepresentable {
    let sessionToken: String
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Use the working Anam integration URL
        let url = URL(string: "https://shawnkelshaw.com/anam/anam-clean.html")!
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = context.coordinator
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismissAction: { 
            DispatchQueue.main.async {
                self.isPresented = false
            }
        })
    }
    
    private func createAnamWebURL(sessionToken: String) -> URL {
        // Direct link to hosted Anam file - no token needed since API key is embedded
        let baseURL = "https://shawnkelshaw.com/anam/anam-clean.html"
        
        return URL(string: baseURL)!
    }
    
    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let dismissAction: () -> Void
        
        init(dismissAction: @escaping () -> Void) {
            self.dismissAction = dismissAction
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismissAction()
        }
    }
}

#Preview {
    AnamSafariView(sessionToken: "preview-token", isPresented: .constant(true))
}
