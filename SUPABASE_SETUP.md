# Supabase Setup Guide

This guide will help you set up Supabase for the AI Career Coach app.

## Prerequisites

- A Supabase account (free tier is sufficient)
- Basic understanding of SQL

## Step 1: Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click **"New Project"**
4. Fill in the project details:
   - **Name**: AI Career Coach
   - **Database Password**: Choose a strong password (save it securely)
   - **Region**: Select the closest region to you
5. Click **"Create new project"**
6. Wait for the project to be provisioned (this may take a few minutes)

## Step 2: Get Your API Credentials

1. Once your project is ready, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (under "Project API keys")
3. Save these values - you'll need them for the `.env` file

## Step 3: Run the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **"New query"**
3. Open the `supabase_schema.sql` file from your project
4. Copy the entire contents of the file
5. Paste it into the SQL Editor
6. Click **"Run"** to execute the schema
7. You should see a success message confirming that the tables were created

## Step 4: Create Storage Bucket

1. In your Supabase dashboard, go to **Storage**
2. Click **"Create a new bucket"**
3. Enter the bucket name: `resumes`
4. Set **Public bucket** to **OFF** (we'll use RLS for security)
5. Click **"Create bucket"**

## Step 5: Configure Storage Policies

1. Click on the `resumes` bucket you just created
2. Go to **Policies** tab
3. Click **"New policy"**
4. Create the following policies:

### Policy 1: Allow authenticated users to upload
- **Policy name**: Allow authenticated uploads
- **Allowed operation**: INSERT
- **Target roles**: authenticated
- **Policy definition**:
```sql
(bucket_id = 'resumes'::text) AND (auth.uid() IS NOT NULL)
```

### Policy 2: Allow users to read their own files
- **Policy name**: Allow users to read own files
- **Allowed operation**: SELECT
- **Target roles**: authenticated
- **Policy definition**:
```sql
(bucket_id = 'resumes'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)
```

## Step 6: Disable Email Confirmation (Optional but Recommended)

For a smoother user experience during development:

1. Go to **Authentication** → **Settings**
2. Scroll down to **Email Auth**
3. **Uncheck** "Enable email confirmations"
4. Click **"Save"**

> ⚠️ **Note**: In production, you should enable email confirmation for better security.

## Step 7: Configure Your Flutter App

1. In your Flutter project, copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Open the `.env` file and add your credentials:
   ```
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

3. Get your Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Step 8: Test the Connection

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Try to sign up with a test account
3. If successful, you should see the user in **Authentication** → **Users** in Supabase

## Troubleshooting

### "Invalid API key" error
- Double-check that you copied the correct anon key from Supabase
- Make sure there are no extra spaces in your `.env` file

### "Table does not exist" error
- Verify that you ran the `supabase_schema.sql` successfully
- Check the SQL Editor for any error messages

### Storage upload fails
- Verify that the `resumes` bucket exists
- Check that storage policies are correctly configured
- Ensure the bucket name matches exactly: `resumes`

### Email confirmation required
- Go to Authentication → Settings
- Disable "Enable email confirmations"

### "Column does not exist" error (e.g., "uploaded_at does not exist")
This error typically occurs when the schema wasn't fully executed or tables were partially created.

**Solution 1: Re-run the entire schema (Recommended)**
1. In Supabase SQL Editor, first drop the existing tables:
   ```sql
   DROP TABLE IF EXISTS public.ai_results CASCADE;
   DROP TABLE IF EXISTS public.resumes CASCADE;
   DROP TABLE IF EXISTS public.users CASCADE;
   ```
2. Then run the entire `supabase_schema.sql` file again

**Solution 2: Add the missing column**
If you only need to fix the `uploaded_at` column:
```sql
ALTER TABLE public.resumes ADD COLUMN IF NOT EXISTS uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
```

> 💡 **Tip**: Always check the SQL Editor for error messages after running the schema. Make sure all tables and columns were created successfully.

## Free Tier Limits

Supabase free tier includes:
- **Database**: 500MB storage
- **Storage**: 1GB file storage
- **Bandwidth**: 2GB per month
- **API requests**: Unlimited

These limits are more than sufficient for personal use and testing.

## Next Steps

Once Supabase is set up:
1. Configure your Gemini API key
2. Run the Flutter app
3. Test all features (signup, login, resume upload, AI analysis)

For more help, visit the [Supabase Documentation](https://supabase.com/docs).
