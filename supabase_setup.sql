-- Supabase Setup SQL
-- Run this in the Supabase SQL Editor to initialize the database schema and storage buckets.

-- 1. Create Tables

-- Users table (extends auth.users)
-- Note: Supabase handles auth.users automatically. We'll create a public profiles table if you want to store extra data, 
-- but the app seems to use 'users' table directly in public schema for additional info.
CREATE TABLE public.users (
  id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  email text,
  display_name text,
  role text, -- 'patient' or 'doctor'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS for users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view/edit their own data
CREATE POLICY "Users can view own data" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own data" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);


-- Patients Profile Table
CREATE TABLE public.patients (
  id uuid REFERENCES public.users(id) NOT NULL PRIMARY KEY,
  date_of_birth date,
  gender text,
  blood_type text,
  allergies text[],
  medications text[],
  insurance_provider text,
  insurance_number text,
  emergency_contact_name text,
  emergency_contact_phone text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS for patients
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

-- Policy: Patients can view/edit their own profile
CREATE POLICY "Patients can view own profile" ON public.patients FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Patients can update own profile" ON public.patients FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Patients can insert own profile" ON public.patients FOR INSERT WITH CHECK (auth.uid() = id);


-- Doctors Profile Table
CREATE TABLE public.doctors (
  id uuid REFERENCES public.users(id) NOT NULL PRIMARY KEY,
  specialty text,
  license_number text,
  clinic_name text,
  clinic_address text,
  clinic_phone text,
  bio text,
  availability jsonb, -- structured availability data
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS for doctors
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;

-- Policy: Doctors can view/edit their own profile
CREATE POLICY "Doctors can view own profile" ON public.doctors FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Doctors can update own profile" ON public.doctors FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Doctors can insert own profile" ON public.doctors FOR INSERT WITH CHECK (auth.uid() = id);
-- Public can view doctors (optional, for search)
CREATE POLICY "Public can view doctors" ON public.doctors FOR SELECT USING (true);


-- Appointments Table
CREATE TABLE public.appointments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  facility_id text NOT NULL, -- External ID from OSM or internal
  facility_name text NOT NULL,
  facility_type text NOT NULL,
  appointment_date timestamptz NOT NULL,
  status text DEFAULT 'pending', -- 'pending', 'confirmed', 'cancelled', 'completed'
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS for appointments
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view/manage their own appointments
CREATE POLICY "Users can view own appointments" ON public.appointments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own appointments" ON public.appointments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own appointments" ON public.appointments FOR UPDATE USING (auth.uid() = user_id);


-- 2. Storage Buckets

-- Create 'profiles' bucket for user avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', true);

-- Policy: Public can view profile pictures
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'profiles' );
-- Policy: Users can upload their own profile picture
CREATE POLICY "User Upload" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1] );
CREATE POLICY "User Update" ON storage.objects FOR UPDATE USING ( bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1] );


-- Create 'documents' bucket for medical records/receipts
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false);

-- Policy: Users can view/upload their own documents
-- NOTE: This assumes folder structure like 'userid/type/filename'
CREATE POLICY "User View Documents" ON storage.objects FOR SELECT USING ( bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1] );
CREATE POLICY "User Upload Documents" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1] );


-- 3. Functions (Optional)

-- Trigger to update 'updated_at' column
CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_modtime BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_patients_modtime BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_doctors_modtime BEFORE UPDATE ON public.doctors FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
