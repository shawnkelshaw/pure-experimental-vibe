import SwiftUI
import WebKit

struct AnamWebView: UIViewRepresentable {
    let sessionToken: String
    @Binding var isPresented: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Add close button overlay
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.closeButtonTapped), for: .touchUpInside)
        
        webView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: webView.topAnchor, constant: 60),
            closeButton.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Load the Anam integration page
        if let url = URL(string: "https://shawnkelshaw.com/anam/anam-clean.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismissAction: { 
            self.isPresented = false
        })
    }
    
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let dismissAction: () -> Void
        
        init(dismissAction: @escaping () -> Void) {
            self.dismissAction = dismissAction
        }
        
        @objc func closeButtonTapped() {
            dismissAction()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Web page loaded successfully
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error)")
        }
    }
}

// Keep the old Safari view as backup
struct AnamSafariView: UIViewControllerRepresentable {
    let sessionToken: String
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let webView = AnamWebView(sessionToken: sessionToken, isPresented: $isPresented)
        let hostingController = UIHostingController(rootView: webView)
        hostingController.view.backgroundColor = .black
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    AnamSafariView(sessionToken: "preview-token", isPresented: .constant(true))
}
