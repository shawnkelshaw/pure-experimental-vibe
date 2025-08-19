import Foundation
import Supabase

class SupabaseConfig {
    static let shared = SupabaseConfig()
    
    // Replace these with your actual Supabase project credentials
    private let supabaseURL = URL(string: "https://iegsoumvmhvvhmdyxhxs.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllZ3NvdW12bWh2dmhtZHl4aHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5MTY5OTcsImV4cCI6MjA2NzQ5Mjk5N30.6uTac2a61UsLXdIEKw_RWlgrsMeAFapV3zHrbi_i1TI"
    
    lazy var client: SupabaseClient = {
        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }()
    
    private init() {}
}

// MARK: - Environment Configuration
extension SupabaseConfig {
    // For production, consider using environment variables or a plist file
    static func configure(url: String, key: String) -> SupabaseClient {
        guard let supabaseURL = URL(string: url) else {
            fatalError("Invalid Supabase URL")
        }
        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: key)
    }
} 