-- Supabase Setup SQL
-- Run this in the Supabase SQL Editor to initialize the database schema and storage buckets.
-- This script is idempotent: it will skip creating tables if they already exist, 
-- but will recreate policies to ensure they are up to date.

-- 1. Create Tables

-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  email text,
  display_name text,
  role text, -- 'patient' or 'doctor'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS for users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policies for users
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
CREATE POLICY "Users can view own data" ON public.users FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own data" ON public.users;
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own data" ON public.users;
CREATE POLICY "Users can insert own data" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);


-- Patients Profile Table
CREATE TABLE IF NOT EXISTS public.patients (
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

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Patients can view own profile" ON public.patients;
CREATE POLICY "Patients can view own profile" ON public.patients FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Patients can update own profile" ON public.patients;
CREATE POLICY "Patients can update own profile" ON public.patients FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Patients can insert own profile" ON public.patients;
CREATE POLICY "Patients can insert own profile" ON public.patients FOR INSERT WITH CHECK (auth.uid() = id);


-- Doctors Profile Table
CREATE TABLE IF NOT EXISTS public.doctors (
  id uuid REFERENCES public.users(id) NOT NULL PRIMARY KEY,
  specialty text,
  license_number text,
  clinic_name text,
  clinic_address text,
  clinic_phone text,
  bio text,
  availability jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Doctors can view own profile" ON public.doctors;
CREATE POLICY "Doctors can view own profile" ON public.doctors FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Doctors can update own profile" ON public.doctors;
CREATE POLICY "Doctors can update own profile" ON public.doctors FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Doctors can insert own profile" ON public.doctors;
CREATE POLICY "Doctors can insert own profile" ON public.doctors FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Public can view doctors" ON public.doctors;
CREATE POLICY "Public can view doctors" ON public.doctors FOR SELECT USING (true);


-- Appointments Table
CREATE TABLE IF NOT EXISTS public.appointments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  facility_id text NOT NULL,
  facility_name text NOT NULL,
  facility_type text NOT NULL,
  appointment_date timestamptz NOT NULL,
  status text DEFAULT 'pending',
  notes text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own appointments" ON public.appointments;
CREATE POLICY "Users can view own appointments" ON public.appointments FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own appointments" ON public.appointments;
CREATE POLICY "Users can insert own appointments" ON public.appointments FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own appointments" ON public.appointments;
CREATE POLICY "Users can update own appointments" ON public.appointments FOR UPDATE USING (auth.uid() = user_id);


-- 2. Storage Buckets

-- Create 'profiles' bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'profiles' );

DROP POLICY IF EXISTS "User Upload" ON storage.objects;
CREATE POLICY "User Upload" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1] );

DROP POLICY IF EXISTS "User Update" ON storage.objects;
CREATE POLICY "User Update" ON storage.objects FOR UPDATE USING ( bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1] );


-- Create 'documents' bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "User View Documents" ON storage.objects;
CREATE POLICY "User View Documents" ON storage.objects FOR SELECT USING ( bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1] );

DROP POLICY IF EXISTS "User Upload Documents" ON storage.objects;
CREATE POLICY "User Upload Documents" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1] );


-- 3. Functions

CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_users_modtime ON public.users;
CREATE TRIGGER update_users_modtime BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

DROP TRIGGER IF EXISTS update_patients_modtime ON public.patients;
CREATE TRIGGER update_patients_modtime BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

DROP TRIGGER IF EXISTS update_doctors_modtime ON public.doctors;
CREATE TRIGGER update_doctors_modtime BEFORE UPDATE ON public.doctors FOR EACH ROW EXECUTE PROCEDURE update_modified_column();