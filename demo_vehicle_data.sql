-- Demo Vehicle Passport Data for Supabase
-- Run this in your Supabase SQL editor to populate demo data

-- First, temporarily modify the schema to allow NULL user_id for demo data
-- This allows us to create demo vehicles that can be assigned to real users later

-- Temporarily allow NULL user_id in vehicles table
ALTER TABLE public.vehicles ALTER COLUMN user_id DROP NOT NULL;

-- Temporarily allow NULL user_id in vehicle_passports table  
ALTER TABLE public.vehicle_passports ALTER COLUMN user_id DROP NOT NULL;

-- Create demo vehicles (using NULL user_id initially - will be assigned to real users)
INSERT INTO public.vehicles (id, user_id, make, model, year, vin, license_plate, color, mileage, fuel_type, transmission, engine_size, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', NULL, 'Tesla', 'Model 3', 2023, '5YJ3E1EA1KF123456', 'TESLA123', 'Pearl White', 15000, 'electric', 'automatic', 'Electric Motor', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440002', NULL, 'BMW', 'M3', 2022, 'WBS3R9C00NP123456', 'BMW-M3X', 'Alpine White', 8500, 'gasoline', 'automatic', '3.0L Twin Turbo', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440003', NULL, 'Porsche', '911 Carrera', 2024, 'WP0CA2A91PS123456', 'PRSCH11', 'Guards Red', 2100, 'gasoline', 'automatic', '3.0L Flat-6', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440004', NULL, 'Ford', 'Mustang GT', 2023, '1FA6P8CF1N5123456', 'MUSTANG', 'Race Red', 12000, 'gasoline', 'manual', '5.0L V8', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440005', NULL, 'Audi', 'RS6 Avant', 2023, 'WAUZZZ4G1N123456', 'AUD-RS6', 'Nardo Gray', 6800, 'gasoline', 'automatic', '4.0L Twin Turbo V8', NOW(), NOW());

-- Create demo vehicle passports (using NULL user_id initially)
INSERT INTO public.vehicle_passports (id, vehicle_id, user_id, title, notes, purchase_date, purchase_price, current_value, is_active, qr_code, created_at, updated_at) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', NULL, 'Demo Vehicle #1', 'Bluetooth-received Tesla Model 3 with Autopilot package', '2023-06-15', 52000.00, 48000.00, true, 'QR_TESLA_MODEL3_001', NOW(), NOW()),
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', NULL, 'Demo Vehicle #2', 'Performance BMW M3 with Competition Package', '2022-03-20', 78000.00, 71000.00, true, 'QR_BMW_M3_002', NOW(), NOW()),
    ('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', NULL, 'Demo Vehicle #3', 'Brand new Porsche 911 Carrera with Sport Chrono', '2024-01-10', 125000.00, 122000.00, true, 'QR_PORSCHE_911_003', NOW(), NOW()),
    ('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', NULL, 'Demo Vehicle #4', 'Classic Ford Mustang GT with manual transmission', '2023-08-05', 42000.00, 39000.00, true, 'QR_MUSTANG_GT_004', NOW(), NOW()),
    ('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', NULL, 'Demo Vehicle #5', 'Audi RS6 Avant with Dynamic Package Plus', '2023-11-28', 135000.00, 128000.00, true, 'QR_AUDI_RS6_005', NOW(), NOW());

-- Add some sample documents for each vehicle passport
INSERT INTO public.vehicle_documents (id, passport_id, type, title, file_url, file_size, mime_type, uploaded_at) VALUES
    ('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', 'registration', 'Vehicle Registration', 'https://demo.com/docs/tesla_registration.pdf', 245760, 'application/pdf', NOW()),
    ('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'insurance', 'Insurance Policy', 'https://demo.com/docs/tesla_insurance.pdf', 189440, 'application/pdf', NOW()),
    ('770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440002', 'registration', 'BMW Registration', 'https://demo.com/docs/bmw_registration.pdf', 256000, 'application/pdf', NOW()),
    ('770e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', 'warranty', 'M Performance Warranty', 'https://demo.com/docs/bmw_warranty.pdf', 378880, 'application/pdf', NOW()),
    ('770e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440003', 'registration', 'Porsche Registration', 'https://demo.com/docs/porsche_registration.pdf', 267776, 'application/pdf', NOW());

-- Add sample maintenance records
INSERT INTO public.maintenance_records (id, passport_id, type, description, cost, mileage, service_provider, service_date, next_service_due, created_at) VALUES
    ('880e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', 'inspection', 'Annual Safety Inspection', 120.00, 12000, 'Tesla Service Center', '2024-01-15', '2025-01-15', NOW()),
    ('880e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'other', 'Software Update v12.1', 0.00, 14500, 'Tesla Service Center', '2024-02-20', null, NOW()),
    ('880e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440002', 'oil_change', 'Oil Change & Filter', 285.00, 7500, 'BMW Dealership', '2024-01-10', '2024-07-10', NOW()),
    ('880e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440003', 'inspection', '1000-Mile Break-in Service', 450.00, 1000, 'Porsche Centre', '2024-02-05', '2024-08-05', NOW()),
    ('880e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440004', 'tune_up', 'Performance Tune & Inspection', 320.00, 10000, 'Ford Performance', '2024-01-25', '2024-07-25', NOW());

-- Note: These demo vehicles have NULL user_id initially
-- When a real user taps "Accept", the app will:
-- 1. Copy the vehicle data
-- 2. Assign it to the real user's ID
-- 3. Create a new passport for that user

COMMIT; 