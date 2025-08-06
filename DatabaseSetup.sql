-- Create users table (extends Supabase auth.users)
-- Note: Supabase creates auth.users automatically, we extend it with public.users
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    
    -- Name fields
    first_name TEXT,
    last_name TEXT,
    display_name TEXT,
    
    -- Contact information
    phone_number TEXT,
    
    -- Address fields
    street_address TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    
    -- Profile
    avatar_url TEXT,
    
    -- Notification preferences
    notifications_email BOOLEAN DEFAULT TRUE,
    notifications_push BOOLEAN DEFAULT TRUE,
    notifications_bluetooth BOOLEAN DEFAULT TRUE,
    notifications_marketing BOOLEAN DEFAULT FALSE,
    
    -- Account metadata
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create vehicles table
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    vin TEXT,
    license_plate TEXT,
    color TEXT,
    mileage INTEGER,
    fuel_type TEXT CHECK (fuel_type IN ('gasoline', 'diesel', 'electric', 'hybrid', 'plugin_hybrid', 'ethanol')),
    transmission TEXT CHECK (transmission IN ('manual', 'automatic', 'cvt', 'semi_automatic')),
    engine_size TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create vehicle_passports table
CREATE TABLE IF NOT EXISTS public.vehicle_passports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT,
    notes TEXT,
    purchase_date DATE,
    purchase_price DECIMAL(10,2),
    current_value DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    qr_code TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create vehicle_documents table
CREATE TABLE IF NOT EXISTS public.vehicle_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    passport_id UUID REFERENCES public.vehicle_passports(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('registration', 'insurance', 'inspection', 'warranty', 'receipt', 'manual', 'other')),
    title TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create maintenance_records table
CREATE TABLE IF NOT EXISTS public.maintenance_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    passport_id UUID REFERENCES public.vehicle_passports(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('oil_change', 'tire_rotation', 'brake_service', 'inspection', 'tune_up', 'repair', 'warranty', 'other')),
    description TEXT NOT NULL,
    cost DECIMAL(10,2),
    mileage INTEGER,
    service_provider TEXT,
    service_date DATE NOT NULL,
    next_service_due DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create storage bucket for vehicle files (only if it doesn't exist)
INSERT INTO storage.buckets (id, name, public)
VALUES ('vehicle-files', 'vehicle-files', true)
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_passports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_records ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

DROP POLICY IF EXISTS "Users can view own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can create own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can update own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can delete own vehicles" ON public.vehicles;

DROP POLICY IF EXISTS "Users can view own vehicle passports" ON public.vehicle_passports;
DROP POLICY IF EXISTS "Users can create own vehicle passports" ON public.vehicle_passports;
DROP POLICY IF EXISTS "Users can update own vehicle passports" ON public.vehicle_passports;
DROP POLICY IF EXISTS "Users can delete own vehicle passports" ON public.vehicle_passports;

DROP POLICY IF EXISTS "Users can view own vehicle documents" ON public.vehicle_documents;
DROP POLICY IF EXISTS "Users can create own vehicle documents" ON public.vehicle_documents;
DROP POLICY IF EXISTS "Users can delete own vehicle documents" ON public.vehicle_documents;

DROP POLICY IF EXISTS "Users can view own maintenance records" ON public.maintenance_records;
DROP POLICY IF EXISTS "Users can create own maintenance records" ON public.maintenance_records;
DROP POLICY IF EXISTS "Users can update own maintenance records" ON public.maintenance_records;
DROP POLICY IF EXISTS "Users can delete own maintenance records" ON public.maintenance_records;

-- Create RLS policies for users table
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for vehicles table
CREATE POLICY "Users can view own vehicles" ON public.vehicles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own vehicles" ON public.vehicles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vehicles" ON public.vehicles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vehicles" ON public.vehicles
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for vehicle_passports table
CREATE POLICY "Users can view own vehicle passports" ON public.vehicle_passports
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own vehicle passports" ON public.vehicle_passports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vehicle passports" ON public.vehicle_passports
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vehicle passports" ON public.vehicle_passports
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for vehicle_documents table
CREATE POLICY "Users can view own vehicle documents" ON public.vehicle_documents
    FOR SELECT USING (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

CREATE POLICY "Users can create own vehicle documents" ON public.vehicle_documents
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

CREATE POLICY "Users can delete own vehicle documents" ON public.vehicle_documents
    FOR DELETE USING (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

-- Create RLS policies for maintenance_records table
CREATE POLICY "Users can view own maintenance records" ON public.maintenance_records
    FOR SELECT USING (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

CREATE POLICY "Users can create own maintenance records" ON public.maintenance_records
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

CREATE POLICY "Users can update own maintenance records" ON public.maintenance_records
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

CREATE POLICY "Users can delete own maintenance records" ON public.maintenance_records
    FOR DELETE USING (
        auth.uid() IN (
            SELECT vp.user_id FROM public.vehicle_passports vp
            WHERE vp.id = passport_id
        )
    );

-- Drop existing storage policies if they exist
DROP POLICY IF EXISTS "Users can upload vehicle files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view vehicle files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete vehicle files" ON storage.objects;

-- Storage policies for vehicle files
CREATE POLICY "Users can upload vehicle files" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'vehicle-files' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view vehicle files" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'vehicle-files' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete vehicle files" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'vehicle-files' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_passports_user_id ON public.vehicle_passports(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_passports_vehicle_id ON public.vehicle_passports(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_documents_passport_id ON public.vehicle_documents(passport_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_records_passport_id ON public.maintenance_records(passport_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_records_service_date ON public.maintenance_records(service_date);

-- Create pending_notifications table
CREATE TABLE IF NOT EXISTS public.pending_notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('bluetooth_passport_push', 'maintenance_reminder', 'document_expiry', 'other')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    is_dismissed BOOLEAN DEFAULT FALSE NOT NULL,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security for notifications
ALTER TABLE public.pending_notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing notification policies if they exist
DROP POLICY IF EXISTS "Users can view own notifications" ON public.pending_notifications;
DROP POLICY IF EXISTS "Users can create own notifications" ON public.pending_notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.pending_notifications;
DROP POLICY IF EXISTS "Users can delete own notifications" ON public.pending_notifications;

-- Create RLS policies for pending_notifications table
CREATE POLICY "Users can view own notifications" ON public.pending_notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own notifications" ON public.pending_notifications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.pending_notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON public.pending_notifications
    FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_pending_notifications_user_id ON public.pending_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_pending_notifications_type ON public.pending_notifications(type);
CREATE INDEX IF NOT EXISTS idx_pending_notifications_is_read ON public.pending_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_pending_notifications_scheduled_for ON public.pending_notifications(scheduled_for);

-- User table indexes for profile features (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_display_name ON public.users(display_name);
CREATE INDEX IF NOT EXISTS idx_users_last_login_at ON public.users(last_login_at);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON public.users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_phone_number ON public.users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_city_state ON public.users(city, state_province);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS handle_updated_at ON public.users;
DROP TRIGGER IF EXISTS handle_updated_at ON public.vehicles;
DROP TRIGGER IF EXISTS handle_updated_at ON public.vehicle_passports;
DROP TRIGGER IF EXISTS handle_updated_at ON public.pending_notifications;

-- Create triggers for updated_at columns
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.vehicles
    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.vehicle_passports
    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.pending_notifications
    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at(); 