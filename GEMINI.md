# AI-Gris Project Documentation

## Project Overview
AI-Gris is a comprehensive healthcare application built with Flutter, designed to facilitate patient-doctor interactions, medical record management, and AI-powered health insights.

## Tech Stack
- **Framework**: Flutter (Dart)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Firebase Authentication
- **Storage**: Supabase Storage
- **AI/ML**: Google Gemini (via `google_generative_ai`), DeepL (via API)
- **Maps/Location**: OpenStreetMap (Overpass API), Geolocator

## Key Features
- **User Roles**: Patient, Doctor
- **Medical Profile**: Comprehensive profile management including sick notes, certificates, and insurance details.
- **Search**: Location-based search for medical facilities (Pharmacies, Doctors, Hospitals).
- **AI Integration**:
    - Transcription refinement using Gemini.
    - Automated report generation.
    - Welcome email generation.
- **E-Receipt**: Upload and management of e-receipts with PDF generation.

## Architecture
- **State Management**: Provider (`MultiProvider`, `ChangeNotifierProvider`).
- **Services**: Service-based architecture (`DatabaseService`, `AuthService`, `AiService`, etc.).
- **Navigation**: `go_router`.

## Database Schema (Supabase)
- **users**: Stores basic user info (linked to Firebase Auth UID).
- **patients**: Stores patient-specific profiles.
- **doctors**: Stores doctor-specific profiles.
- **appointments**:
  - `id` (uuid, primary key, default: `gen_random_uuid()`)
  - `user_id` (uuid, foreign key to `users.id`)
  - `facility_id` (text)
  - `facility_name` (text)
  - `facility_type` (text)
  - `appointment_date` (timestamptz)
  - `status` (text, default: 'pending')
  - `created_at` (timestamptz, default: `now()`)
- **Storage Buckets**: `profiles`, `documents`.

## Recent Changes
- **Call & Book Functionality**:
    - Enhanced medical facility cards across all service screens.
    - Implemented real-time phone calling via `url_launcher`.
    - **Real-time Appointment Booking**: Replaced simulation with actual database insertion into Supabase `appointments` table.
    - Added visual indicators for Open/Closed status.
- Migrated database from Firestore to Supabase.
- Implemented storage for profile pictures and documents.
- **E-Rezept Integration**: Connected to Supabase Storage. Prescriptions are now uploaded to `documents` bucket.
- Optimized medical facility search with larger radius and geocoding.
- Removed language selector from Welcome Screen.

## Setup
1. Copy `.env.example` to `.env` and fill in API keys.
2. Ensure Supabase URL and Anon Key are set.
3. Ensure Firebase is configured (`firebase_options.dart`).
