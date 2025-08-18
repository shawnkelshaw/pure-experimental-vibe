# Supabase Integration Guide

## Overview

This guide walks you through integrating Supabase into your Pure Experimental Vibe vehicle passport app. The integration includes authentication, real-time database operations, and file storage.

## Prerequisites

1. A Supabase account and project
2. Xcode 14.0 or later
3. iOS 16.0 or later
4. Swift 5.8 or later

## Step 1: Add Supabase Swift SDK

### Option A: Using Xcode (Recommended)

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/supabase/supabase-swift`
4. Select version `2.5.1` or later
5. Add to your target

### Option B: Using Swift Package Manager

Add this to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/supabase/supabase-swift", from: "2.5.1")
```

## Step 2: Set Up Database Schema

1. Go to your Supabase dashboard
2. Navigate to the SQL Editor
3. Run the SQL script from `DatabaseSetup.sql` to create all necessary tables and policies

The database schema includes:
- **users**: User profiles extending Supabase auth
- **vehicles**: Vehicle information
- **vehicle_passports**: Digital passports for vehicles
- **vehicle_documents**: Attached documents
- **maintenance_records**: Service history
- **Storage bucket**: For file uploads

## Step 3: Configure Your Project

### Update Configuration

1. Open `SupabaseConfig.swift`
2. Replace the placeholder values with your actual Supabase credentials:

```swift
private let supabaseURL = URL(string: "https://your-project-id.supabase.co")!
private let supabaseKey = "your-anon-key-here"
```

### Alternative: Using Config.plist

1. Add your credentials to `Config.plist`:
```xml
<key>SUPABASE_URL</key>
<string>https://your-project-id.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>your-anon-key-here</string>
```

2. Load from plist in `SupabaseConfig.swift`:
```swift
private func loadConfig() -> (url: String, key: String) {
    guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let url = plist["SUPABASE_URL"] as? String,
          let key = plist["SUPABASE_ANON_KEY"] as? String else {
        fatalError("Config.plist not found or invalid")
    }
    return (url, key)
}
```

## Step 4: Set Up Authentication

The `AuthService` class handles user authentication:

- **Sign Up**: Creates new users and profiles
- **Sign In**: Authenticates existing users
- **Sign Out**: Logs out users
- **Session Management**: Maintains auth state

### Usage Example:

```swift
@EnvironmentObject var authService: AuthService

// Sign up
await authService.signUp(
    email: "user@example.com",
    password: "securePassword",
    firstName: "John",
    lastName: "Doe"
)

// Sign in
await authService.signIn(email: "user@example.com", password: "securePassword")
```

## Step 5: Implement Data Operations

The `VehicleService` handles all database operations:

### Vehicle Operations
- `fetchUserVehicles(userId:)`: Get user's vehicles
- `createVehicle(_:)`: Add new vehicle
- `updateVehicle(_:)`: Update vehicle info
- `deleteVehicle(id:)`: Remove vehicle

### Passport Operations
- `fetchVehiclePassports(userId:)`: Get user's passports
- `createVehiclePassport(_:)`: Create new passport
- `updateVehiclePassport(_:)`: Update passport
- `deleteVehiclePassport(id:)`: Deactivate passport

### Document & Maintenance
- `addDocument(_:)`: Upload and attach documents
- `addMaintenanceRecord(_:)`: Add service records
- `uploadFile(data:fileName:bucket:)`: Upload files to storage

## Step 6: Update Views with ViewModels

The `GarageViewModel` manages the state for your garage view:

```swift
@StateObject private var garageViewModel = GarageViewModel(authService: authService)

// In your view
.onAppear {
    Task {
        await garageViewModel.loadGarageData()
    }
}
```

## Step 7: Authentication Flow

### Required View Updates

1. **App Level**: Inject `AuthService` as environment object
2. **HomeView**: Check authentication state
3. **MyGarageView**: Use `GarageViewModel` for data operations

### Sample Authentication Check:

```swift
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        if authService.isAuthenticated {
            RootTabView()
        } else {
            LoginView()
        }
    }
}
```

## Step 8: Handle Real-time Updates (Optional)

For real-time functionality, add Supabase subscriptions:

```swift
func subscribeToPassportChanges() {
    let subscription = supabase.channel("vehicle_passports")
        .onPostgresChange(
            event: .all,
            schema: "public",
            table: "vehicle_passports",
            filter: "user_id=eq.\(userId)"
        ) { payload in
            // Handle real-time updates
            Task { @MainActor in
                await loadGarageData()
            }
        }
        .subscribe()
}
```

## Security Considerations

1. **Row Level Security (RLS)**: Already configured in database schema
2. **File Upload Security**: Users can only access their own files
3. **API Keys**: Never commit real keys to version control
4. **Environment Variables**: Use different configs for dev/prod

## File Storage Setup

1. Create storage bucket named `vehicle-files`
2. Configure bucket policies (included in SQL script)
3. Organize files by user ID: `userId/vehicleId/filename.pdf`

## Testing Your Integration

1. **Authentication**: Test sign up, sign in, sign out
2. **Data Operations**: Create, read, update, delete vehicles and passports
3. **File Upload**: Test document attachment
4. **Error Handling**: Verify error states are handled gracefully

## Troubleshooting

### Common Issues:

1. **Authentication Errors**: Check your Supabase URL and anon key
2. **Database Access**: Verify RLS policies are correctly applied
3. **File Upload Issues**: Ensure storage bucket exists and has proper policies
4. **Network Errors**: Implement proper error handling and retry logic

### Debug Mode:

Enable debug logging by adding to your `SupabaseConfig`:

```swift
lazy var client: SupabaseClient = {
    var config = SupabaseClientOptions()
    config.debug = true // Enable for debugging
    return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey, options: config)
}()
```

## Next Steps

1. **Test Authentication**: Create test accounts and verify login flow
2. **Add Sample Data**: Create test vehicles and passports
3. **Implement Additional Features**: QR code generation, advanced search
4. **Optimize Performance**: Add caching and pagination
5. **Add Real-time Features**: Live updates and notifications

## Support

- Supabase Documentation: https://supabase.io/docs
- Supabase Swift SDK: https://github.com/supabase/supabase-swift
- SwiftUI Documentation: https://developer.apple.com/documentation/swiftui

---

Your Supabase integration is now complete! Your app can authenticate users, store vehicle data, manage documents, and track maintenance records in a secure, scalable backend. 