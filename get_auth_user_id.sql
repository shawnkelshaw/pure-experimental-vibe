-- Get the correct auth user ID for your email
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'shawn@shawnkelshaw.com'; 