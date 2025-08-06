-- Add new profile fields to existing users table
ALTER TABLE public.users 
ADD COLUMN display_name TEXT,
ADD COLUMN phone_number TEXT,
ADD COLUMN street_address TEXT,
ADD COLUMN city TEXT,
ADD COLUMN state_province TEXT,
ADD COLUMN postal_code TEXT,
ADD COLUMN country TEXT,
ADD COLUMN notifications_email BOOLEAN DEFAULT TRUE,
ADD COLUMN notifications_push BOOLEAN DEFAULT TRUE,
ADD COLUMN notifications_bluetooth BOOLEAN DEFAULT TRUE,
ADD COLUMN notifications_marketing BOOLEAN DEFAULT FALSE,
ADD COLUMN is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN last_login_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for profile features
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_display_name ON public.users(display_name);
CREATE INDEX idx_users_last_login_at ON public.users(last_login_at);
CREATE INDEX idx_users_is_active ON public.users(is_active);
CREATE INDEX idx_users_phone_number ON public.users(phone_number);
CREATE INDEX idx_users_city_state ON public.users(city, state_province); 