API & Data

The app currently uses a hybrid approach to data and integration:

⸻

🧠 Backend – Supabase

Supabase serves as the primary data warehouse and authentication provider for the app.
	•	Stores structured data for vehicle profiles, user accounts, and market listings
	•	Enables secure user sign-in/sign-up and session management
	•	Designed to scale with real-time updates and peer-to-peer data resolution

Core Models:
	•	Vehicle
	•	GarageItem
	•	MarketListing
	•	UserProfile

All models support serialization for transmission (e.g., QR code encoding, Bluetooth exchange).

⸻

🧪 Simulated Layers (Prototype Mode)

To support non-production hardware features, the app currently simulates:
	•	Bluetooth Notifications
	•	Local triggers simulate proximity-based notifications between devices
	•	Used to mock discovery and handoff of vehicle passports
	•	QR Code Scanning
	•	Static codes and mock scan responses are used to simulate ownership or listing resolution
	•	Interactions mimic camera-based scanning without requiring AVFoundation setup
	•	Mocked Data
	•	Used where Supabase data is not yet implemented (e.g., test vehicles)
	•	Allows UI to render even when offline or disconnected

⸻

📦 Persistence & State
	•	Supabase provides remote persistence for all core models
	•	Temporary data (e.g., in-session scanned content or simulation payloads) live in local runtime memory
	•	Local caching for performance is planned but not yet implemented

⸻

This document will evolve alongside production integration milestones and should reflect the latest state of server interaction and mock behavior.