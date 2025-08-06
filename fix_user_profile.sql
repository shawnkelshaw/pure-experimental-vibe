-- Create user profile using the correct auth user ID
INSERT INTO public.users (
    id, email, first_name, last_name, display_name, phone_number,
    street_address, city, state_province, postal_code, country,
    avatar_url, notifications_email, notifications_push, 
    notifications_bluetooth, notifications_marketing, is_active,
    last_login_at, created_at, updated_at
)
SELECT 
    auth_users.id,  -- Get the real auth user ID
    'shawn@shawnkelshaw.com',
    'Shawn', 'Kelshaw', NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, true, true, true, false, true,
    NOW(), NOW(), NOW()
FROM auth.users AS auth_users
WHERE auth_users.email = 'shawn@shawnkelshaw.com'; 