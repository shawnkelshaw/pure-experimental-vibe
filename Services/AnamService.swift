import Foundation
import Supabase

@MainActor
class AnamService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseConfig.shared.client
    
    func generateSessionToken() async -> String? {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Get current user's JWT token
            let session = try await supabase.auth.session
            
            // Call Supabase Edge Function using URLSession
            guard let url = URL(string: "https://iegsoumvmhvvhmdyxhxs.supabase.co/functions/v1/generate-anam-token") else {
                await MainActor.run {
                    errorMessage = "Invalid function URL"
                    isLoading = false
                }
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Anam token response status: \(httpResponse.statusCode)")
            }
            
            // Parse response
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("Raw Anam response: \(responseString)")
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Parsed JSON: \(json)")
                
                // Check if it's an error response
                if let error = json["error"] as? String {
                    print("Supabase Edge Function error: \(error)")
                    await MainActor.run {
                        errorMessage = "Edge Function error: \(error)"
                        isLoading = false
                    }
                    return nil
                }
                
                // Check for session token
                if let sessionToken = json["sessionToken"] as? String {
                    await MainActor.run {
                        isLoading = false
                    }
                    print("Generated Anam session token: \(sessionToken.prefix(20))...")
                    return sessionToken
                } else {
                    print("No sessionToken in response")
                    await MainActor.run {
                        errorMessage = "No session token in response"
                        isLoading = false
                    }
                    return nil
                }
            } else {
                print("Failed to parse JSON response")
                await MainActor.run {
                    errorMessage = "Invalid JSON response: \(responseString)"
                    isLoading = false
                }
                return nil
            }
            
        } catch {
            print("Anam token generation error: \(error)")
            await MainActor.run {
                errorMessage = "Failed to generate session token: \(error.localizedDescription)"
                isLoading = false
            }
            return nil
        }
    }
}
