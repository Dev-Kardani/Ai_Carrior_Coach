# AI Career Coach

// run : flutter run -d macos

A 100% free AI-powered career assistant for resume analysis and career guidance, built with Flutter, Supabase, and Google Gemini API.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Supabase](https://img.shields.io/badge/Supabase-Free%20Tier-green.svg)
![Gemini](https://img.shields.io/badge/Gemini-1.5%20Flash-orange.svg)

## ✨ Features

- 🔐 **Secure Authentication** - Email/password login with Supabase (includes Forgot Password flow)
- 📄 **Resume Upload** - Upload PDF resumes with local text extraction
- 🤖 **AI Resume Analyzer** - Get detailed feedback with scores, strengths, weaknesses, and ATS compatibility
- 📊 **Skill Gap Analyzer** - Identify missing skills for your target role with personalized learning roadmaps
- 💬 **AI Career Chat** - ChatGPT-style interface for career questions
- 🎯 **Mock Interview** - Configure and start AI-powered practice sessions
- 🎨 **Premium UI** - Glassmorphism design with smooth animations
- 🌙 **Dark/Light Theme** - Beautiful themes for any preference
- 💾 **Local Storage** - Chat history saved locally
- 🆓 **100% Free** - No subscriptions, no hidden costs

## 🚀 Tech Stack

- **Frontend**: Flutter 3.0+
- **Backend**: Supabase (Auth + Database + Storage)
- **AI**: Google Gemini 1.5 Flash
- **PDF Parsing**: pdf_text (local, no API)
- **State Management**: Provider
- **UI**: Glassmorphism, Google Fonts, Flutter Animate

## 📋 Prerequisites

Before you begin, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or higher)
- A [Supabase](https://supabase.com) account (free tier)
- A [Google Gemini API](https://makersuite.google.com/app/apikey) key (free tier)
- Android Studio or VS Code with Flutter extensions

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd ai_career_coach
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```env
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

### 4. Set Up Supabase

Follow the detailed guide in [SUPABASE_SETUP.md](SUPABASE_SETUP.md):

1. Create a Supabase project
2. Run the SQL schema (`supabase_schema.sql`)
3. Create the `resumes` storage bucket
4. Configure storage policies
5. Disable email confirmation (optional)
6. **Important**: Add `ai-career-coach://reset-password` to **Authentication > URL Configuration > Redirect URLs** for the Forgot Password feature to work.

### 5. Run the App

```bash
flutter run
```

## 📱 Usage

### First Time Setup

1. **Sign Up**: Create an account with your email and password
2. **Upload Resume**: Upload your PDF resume (max 5MB)
3. **Get Analysis**: AI will analyze your resume and provide a score with detailed feedback
4. **Explore Features**:
   - Check your skill gaps for different roles
   - Chat with the AI career coach
   - Get personalized improvement suggestions

### Features Overview

#### Resume Analyzer
- Upload PDF resume
- Get a score (0-100)
- View strengths and weaknesses
- Check ATS compatibility
- Receive actionable improvement suggestions

#### Skill Gap Analyzer
- Select your target role (Flutter Developer, Data Analyst, etc.)
- See missing skills
- Get a personalized learning roadmap with priorities and timelines

#### AI Career Chat
- Ask any career-related questions
- Get instant AI-powered responses
- Chat history saved locally
- Suggested prompts for quick start

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── theme/              # App colors and themes
│   ├── constants/          # App-wide constants
│   └── utils/              # Validators and utilities
├── features/
│   ├── auth/               # Login and signup screens
│   ├── dashboard/          # Main dashboard
│   ├── resume/             # Resume upload and analysis
│   ├── skill_gap/          # Skill gap analyzer
│   └── chat/               # AI career chat
├── services/
│   ├── supabase_service.dart    # Supabase operations
│   ├── gemini_service.dart      # Gemini AI integration
│   ├── pdf_service.dart         # PDF text extraction
│   └── storage_service.dart     # Local storage
├── models/                 # Data models
└── main.dart              # App entry point
```

## 💰 Cost & Free Tier Limits

### Supabase Free Tier
- **Database**: 500MB storage
- **File Storage**: 1GB
- **Bandwidth**: 2GB/month
- **API Requests**: Unlimited

### Google Gemini Free Tier
- **Requests**: 60 per minute
- **Tokens**: 1 million per month
- **Models**: Gemini 1.5 Flash

> ✅ **Safe to Use**: This app is optimized to stay well within free tier limits for personal use.

## 🔒 Security

- Row Level Security (RLS) enabled on all Supabase tables
- Users can only access their own data
- Passwords hashed by Supabase Auth
- API keys stored in environment variables (not committed to Git)

## 🐛 Troubleshooting

### "Flutter not found"
- Install Flutter SDK from [flutter.dev](https://flutter.dev)
- Add Flutter to your PATH

### "Invalid API key"
- Check your `.env` file for correct credentials
- Ensure no extra spaces in the keys

### "PDF extraction failed"
- Ensure the PDF contains selectable text (not scanned images)
- Check file size is under 5MB

### "Supabase connection error"
- Verify your Supabase URL and anon key
- Check that the database schema is set up correctly



## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

If you have any questions or need help, please open an issue on GitHub.

---

**Built with ❤️ using Flutter, Supabase, and Gemini AI**

**100% Free • No Subscriptions • No Hidden Costs**

# Ai_Carrior_Coach
