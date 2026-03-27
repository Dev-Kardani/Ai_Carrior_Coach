# CareerAI - Visual Workflow & Navigation Map

## 🎯 Quick Reference Guide

This document provides visual diagrams for understanding the complete CareerAI application flow.

---

## 📊 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAREERAI PLATFORM                        │
│                     (23 Screens, 6 Modules)                     │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
            ┌───────▼────────┐       ┌───────▼────────┐
            │  Public Routes │       │ Protected Routes│
            │  (Auth Flow)   │       │  (Main App)     │
            └───────┬────────┘       └───────┬─────────┘
                    │                        │
        ┌───────────┼─────────┐             │
        │           │         │             │
        ▼           ▼         ▼             ▼
    ┌──────┐  ┌───────┐  ┌──────┐   ┌──────────┐
    │Splash│  │ Login │  │Signup│   │ Dashboard│
    │      │  │+Forgot│  │+Setup│   │  Layout  │
    └──────┘  └───────┘  └──────┘   └─────┬────┘
                                           │
                        ┌──────────────────┼──────────────────┐
                        │                  │                  │
                    ┌───▼───┐          ┌──▼──┐           ┌───▼────┐
                    │Resume │          │Jobs │           │Interview│
                    │Module │          │Track│           │ System  │
                    │4 Scrns│          │4 Scr│           │ 3 Screens│
                    └───────┘          └─────┘           └─────────┘
                        │                  │                  │
                    ┌───▼───┐          ┌──▼──┐           ┌───▼────┐
                    │  Chat │          │Tools│           │  More  │
                    │2 Scrns│          │5 Scr│           │Features│
                    └───────┘          └─────┘           └────────┘
```

---

## 🔐 Authentication Flow (Screens 1-4)

```
┌──────────────────────────────────────────────────────────────────┐
│                      ENTRY POINT LOGIC                           │
└──────────────────────────────────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  SPLASH SCREEN  │
                    │   (Screen #1)   │
                    │  Check Session  │
                    └────────┬────────┘
                             │
                  ┌──────────┴──────────┐
                  │                     │
           [No Session]          [Has Session]
                  │                     │
                  ▼                     ▼
         ┌────────────────┐    ┌────────────────┐
         │  LOGIN SCREEN  │    │   DASHBOARD    │
         │   (Screen #2)  │    │   (Screen #5)  │
         │                │    │   Main Hub     │
         └────────┬───────┘    └────────────────┘
                  │
      ┌───────────┴───────────┐
      │                       │
 [New User?]            [Authenticate]
      │                       │
      ▼                       │
┌─────────────┐               │
│SIGNUP SCREEN│               │
│ (Screen #3) │               │
└──────┬──────┘               │
       │                      │
       ▼                      │
┌──────────────┐              │
│PROFILE SETUP │              │
│ (Screen #4)  │              │
└──────┬───────┘              │
       │                      │
       └──────────┬───────────┘
                  │
                  ▼
         ┌────────────────┐
         │   DASHBOARD    │
         │   (Screen #5)  │
         │   Welcome!     │
         └────────────────┘

SCREENS IN THIS MODULE:
1. Splash Screen      → /
2. Login Screen       → /auth/login
3. Signup Screen      → /auth/signup
4. Forgot Password    → /auth/forgot-password
5. Update Password    → /auth/update-password
6. Profile Setup      → /auth/setup
```

---

## 🏠 Dashboard Hub (Screen 5)

```
┌───────────────────────────────────────────────────────────────────┐
│                     DASHBOARD - CENTRAL HUB                       │
│                        (Screen #5)                                │
│                       Route: /app                                 │
└───────────────────────────────────────────────────────────────────┘
│                                                                   │
│  ┌─────────────────────────────────────────────────────┐         │
│  │          Welcome Section                            │         │
│  │  "Hello, Alex! 👋"                                  │         │
│  └─────────────────────────────────────────────────────┘         │
│                                                                   │
│  ┌─────────────────────────────────────────────────────┐         │
│  │     Resume Score Widget (Circular Chart)            │         │
│  │           78/100 ATS Score                          │         │
│  │  [View Analysis] [Update Resume]                    │         │
│  └─────────────────────────────────────────────────────┘         │
│                                                                   │
│  ┌──────────────────────┐  ┌──────────────────────┐             │
│  │   Action Required    │  │   Market Insight     │             │
│  │   2 follow-ups       │  │   Roles up 15%       │             │
│  └──────────────────────┘  └──────────────────────┘             │
│                                                                   │
│  ┌─────────────────────────────────────────────────────┐         │
│  │             QUICK ACCESS MODULES (6 Cards)          │         │
│  ├─────────────┬─────────────┬─────────────┐           │         │
│  │  Resume     │  Skill Gap  │  Mock       │           │         │
│  │  Analysis   │   Analysis  │  Interview  │           │         │
│  │  Screen #6  │  Screen #9  │  Screen #10 │           │         │
│  ├─────────────┼─────────────┼─────────────┤           │         │
│  │  Job        │  AI Career  │  Career     │           │         │
│  │  Tracker    │    Chat     │   Tools     │           │         │
│  │  Screen #13 │  Screen #17 │  Screen #19 │           │         │
│  └─────────────┴─────────────┴─────────────┘           │         │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

NAVIGATION FROM DASHBOARD:
→ /app/resume/upload      (Resume Module)
→ /app/resume/skills      (Skill Gap)
→ /app/interview/setup    (Mock Interview)
→ /app/jobs               (Job Tracker)
→ /app/chat               (AI Chat)
→ /app/tools              (Tools Hub)
```

---

## 📄 Resume Analysis Pipeline (Screens 6-9)

```
┌────────────────────────────────────────────────────────────┐
│              RESUME ANALYSIS WORKFLOW                      │
│                  (4 Screens)                               │
└────────────────────────────────────────────────────────────┘

STEP 1: Upload
┌──────────────────────┐
│  RESUME UPLOAD       │
│   (Screen #6)        │
│  /app/resume/upload  │
├──────────────────────┤
│  [Drop Resume Here]  │
│   PDF or DOC         │
│  [Browse Files]      │
└──────────┬───────────┘
           │
           │ [File Selected]
           ▼
STEP 2: Processing
┌──────────────────────┐
│  PROCESSING STATE    │
│   (Screen #7)        │
│/app/resume/processing│
├──────────────────────┤
│    🔄 Analyzing...   │
│    Progress: 65%     │
│  "Extracting text"   │
└──────────┬───────────┘
           │
           │ [Analysis Complete]
           ▼
STEP 3: Analysis Results
┌──────────────────────┐
│  RESUME ANALYSIS     │
│   (Screen #8)        │
│ /app/resume/analysis │
├──────────────────────┤
│  Score: 78/100 ⭐    │
│                      │
│  ✅ Strengths:       │
│  • Clear formatting  │
│  • Quantified impact │
│                      │
│  ⚠️ Improvements:    │
│  • Add keywords      │
│  • Expand skills     │
│                      │
│ [View Skill Gap]     │
│ [Re-upload Resume]   │
└──────────┬───────────┘
           │
           │ [Optional: Skill Gap]
           ▼
STEP 4: Skill Gap Analysis
┌──────────────────────┐
│   SKILL GAP          │
│   (Screen #9)        │
│ /app/resume/skills   │
├──────────────────────┤
│  Target: PM Role     │
│                      │
│  Missing Skills:     │
│  • Product Strategy  │
│  • A/B Testing       │
│  • SQL               │
│                      │
│  Recommendations:    │
│  📚 Courses          │
│  🛠️ Tools Practice   │
│                      │
│ [Back to Dashboard]  │
└──────────────────────┘

NAVIGATION PATHS:
6 → 7 → 8 → 9 → Dashboard
    ↑___|   ↑_______|
  [Re-upload]  [Skip to Dashboard]
```

---

## 🎤 Mock Interview System (Screens 10-12)

```
┌────────────────────────────────────────────────────────────┐
│             MOCK INTERVIEW WORKFLOW                        │
│                  (3 Screens)                               │
└────────────────────────────────────────────────────────────┘

STEP 1: Configuration
┌──────────────────────────┐
│  INTERVIEW SETUP         │
│   (Screen #10)           │
│ /app/interview/setup     │
├──────────────────────────┤
│  Job Role:               │
│  ▼ Product Manager       │
│                          │
│  Difficulty:             │
│  ○ Entry ● Mid ○ Senior  │
│                          │
│  Duration:               │
│  ○ 15min ● 30min ○ 45min │
│                          │
│  [Start Interview] →     │
└──────────────┬───────────┘
               │
               ▼
STEP 2: Live Interview
┌──────────────────────────┐
│  INTERVIEW EXECUTION     │
│   (Screen #11)           │
│ /app/interview/active    │
├──────────────────────────┤
│  🤖 AI Interviewer       │
│  "Tell me about a time   │
│   you led a team..."     │
│                          │
│  Question 3/10           │
│  ⏱️ 12:45 remaining      │
│                          │
│  Your Answer:            │
│  ┌────────────────────┐  │
│  │                    │  │
│  └────────────────────┘  │
│  [Submit Answer] →       │
└──────────────┬───────────┘
               │
               │ [Interview Complete]
               ▼
STEP 3: Performance Review
┌──────────────────────────┐
│  INTERVIEW FEEDBACK      │
│   (Screen #12)           │
│ /app/interview/feedback  │
├──────────────────────────┤
│  Overall: 8.5/10 🌟      │
│                          │
│  Strengths:              │
│  ✅ Clear communication  │
│  ✅ STAR method used     │
│                          │
│  Improvements:           │
│  📈 More specific data   │
│  📈 Expand on outcomes   │
│                          │
│  Detailed Analysis:      │
│  [Q1: 9/10] [Q2: 8/10]   │
│                          │
│ [New Interview]          │
│ [Back to Dashboard]      │
└──────────────────────────┘

NAVIGATION PATHS:
10 → 11 → 12 → Dashboard
 ↑______________|
   [New Interview]
```

---

## 💼 Job Tracker with Kanban (Screens 13-16)

```
┌────────────────────────────────────────────────────────────┐
│              JOB TRACKER WORKFLOW                          │
│                  (4 Screens)                               │
└────────────────────────────────────────────────────────────┘

MAIN VIEW: Kanban Board
┌──────────────────────────────────────────────────────────────┐
│  JOB BOARD (KANBAN)                                          │
│   (Screen #13)                                               │
│  /app/jobs                                                   │
├──────────────────────────────────────────────────────────────┤
│  [+ Add New Job]                                             │
│                                                              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │Wish  │ │Appld │ │Interv│ │Offer │ │Reject│              │
│  │list  │ │      │ │iew   │ │      │ │      │              │
│  ├──────┤ ├──────┤ ├──────┤ ├──────┤ ├──────┤              │
│  │Google│ │Meta  │ │Apple │ │      │ │Amzn  │              │
│  │PM    │ │PM    │ │PM    │ │      │ │PM    │              │
│  │▼     │ │▼     │ │▼     │ │      │ │▼     │              │
│  ├──────┤ ├──────┤ ├──────┤ ├──────┤ ├──────┤              │
│  │Click:│ │Click:│ │Click:│ │      │ │      │              │
│  │View  │ │View  │ │View  │ │      │ │      │              │
│  │Detail│ │Detail│ │Detail│ │      │ │      │              │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘              │
│                                                              │
│  [Drag cards between columns to update status]              │
└──────────────────────────────────────────────────────────────┘
           │                    │
           │                    │
   [+ New Job]          [Click Card]
           │                    │
           ▼                    ▼
    ┌──────────┐         ┌──────────┐
    │JOB ENTRY │         │JOB DETAIL│
    │Screen #14│         │Screen #15│
    │/jobs/new │         │/jobs/:id │
    ├──────────┤         ├──────────┤
    │Company:  │         │ Google   │
    │_________ │         │ PM Role  │
    │          │         │ Applied: │
    │Position: │         │ Feb 15   │
    │_________ │         │          │
    │          │         │ Status:  │
    │URL:      │         │Wishlist  │
    │_________ │         │          │
    │          │         │ Notes:   │
    │Date:     │         │ "Great"  │
    │_________ │         │          │
    │          │         │ [Edit]   │
    │Status:   │         │ [Delete] │
    │▼______   │         └────┬─────┘
    │          │              │
    │[Save]    │         [Edit]
    └────┬─────┘              │
         │                    ▼
         │             ┌──────────┐
         │             │ JOB EDIT │
         │             │Screen #16│
         │             │/jobs/:id │
         │             │   /edit  │
         │             ├──────────┤
         │             │ [Same as │
         │             │  Entry   │
         │             │  Form]   │
         │             │          │
         │             │ [Save]   │
         └─────────┬───┴────┬─────┘
                   │        │
                   ▼        ▼
            ┌─────────────────┐
            │   JOB BOARD     │
            │  (Return)       │
            └─────────────────┘

NAVIGATION PATHS:
13 (Board) → 14 (New) → 13 (Board)
13 (Board) → 15 (Detail) → 16 (Edit) → 13 (Board)
             └─────────────────────┘
```

---

## 💬 AI Career Chat (Screens 17-18)

```
┌────────────────────────────────────────────────────────────┐
│              AI CAREER CHAT WORKFLOW                       │
│                  (2 Screens)                               │
└────────────────────────────────────────────────────────────┘

MAIN CHAT INTERFACE
┌──────────────────────────────────────────────────────────────┐
│  AI CAREER CHAT                                              │
│   (Screen #17)                                               │
│  /app/chat                                                   │
├──────────┬───────────────────────────────────────────────────┤
│ Sidebar  │  Active Conversation                             │
│          │                                                   │
│ Chats:   │  You: "How do I improve my resume?"              │
│ ───────  │  ╭──────────────────────────────────╮            │
│ Today    │  │ AI: Here are 5 key strategies... │            │
│ • Chat 1 │  ╰──────────────────────────────────╯            │
│ • Chat 2 │                                                   │
│          │  You: "Tell me more about #3"                    │
│ Week     │  ╭──────────────────────────────────╮            │
│ • Chat 3 │  │ AI: Quantifying achievements...  │            │
│          │  ╰──────────────────────────────────╯            │
│ [+ New]  │                                                   │
│          │  ┌─────────────────────────────────┐             │
│          │  │ Type your message...            │             │
│          │  └─────────────────────────────────┘             │
│          │  [Send]                                          │
└──────────┴───────────────────────────────────────────────────┘
     │
     │ [+ New Chat]
     ▼
┌──────────────────────────┐
│  NEW CHAT                │
│   (Screen #18)           │
│  /app/chat/new           │
├──────────────────────────┤
│  Start a new conversation│
│                          │
│  Suggested Prompts:      │
│  ▸ Resume feedback       │
│  ▸ Interview prep        │
│  ▸ Career transition     │
│  ▸ Salary negotiation    │
│                          │
│  Or type your own:       │
│  ┌────────────────────┐  │
│  │                    │  │
│  └────────────────────┘  │
│  [Start Chat]            │
└──────────┬───────────────┘
           │
           ▼
    ┌──────────────┐
    │ AI CAREER    │
    │   CHAT       │
    │ (Active)     │
    └─���────────────┘

NAVIGATION PATHS:
17 (Chat) → 18 (New) → 17 (Active Chat)
17 → Dashboard
```

---

## 🛠️ Career Tools Suite (Screens 19-23)

```
┌────────────────────────────────────────────────────────────┐
│              CAREER TOOLS WORKFLOW                         │
│                  (5 Screens)                               │
└────────────────────────────────────────────────────────────┘

HUB: Central Access Point
┌──────────────────────────────────────────────────────────────┐
│  TOOLS HUB                                                   │
│   (Screen #19)                                               │
│  /app/tools                                                  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │ Cover Letter │  │  Networking  │                         │
│  │  Generator   │  │   Message    │                         │
│  │  Screen #20  │  │  Screen #21  │                         │
│  │     ✉️       │  │     🤝       │                         │
│  └──────┬───────┘  └──────┬───────┘                         │
│         │                 │                                  │
│  ┌──────┴───────┐  ┌──────┴───────┐                         │
│  │  Portfolio   │  │   Salary     │                         │
│  │  Architect   │  │ Negotiator   │                         │
│  │  Screen #22  │  │  Screen #23  │                         │
│  │     📁       │  │     💰       │                         │
│  └──────────────┘  └──────────────┘                         │
└──────────────────────────────────────────────────────────────┘
    │        │           │           │
    │        │           │           │
    ▼        ▼           ▼           ▼
┌────────┐┌────────┐┌────────┐┌────────┐
│Cover   ││Network ││Portfol ││Salary  │
│Letter  ││Message ││io      ││Negot.  │
│#20     ││#21     ││#22     ││#23     │
└────────┘└────────┘└────────┘└────────┘

TOOL #1: Cover Letter Generator (Screen #20)
┌──────────────────────────────────────┐
│  COVER LETTER GENERATOR              │
│  /app/tools/cover-letter             │
├──────────────────────────────────────┤
│  Job Description:                    │
│  ┌────────────────────────────────┐  │
│  │ Paste job description...       │  │
│  └────────────────────────────────┘  │
│                                      │
│  Company Info:                       │
│  ┌────────────────────────────────┐  │
│  │ Google, Product Manager        │  │
│  └────────────────────────────────┘  │
│                                      │
│  [Generate with AI] →                │
│                                      │
│  Generated Letter:                   │
│  ┌────────────────────────────────┐  │
│  │ Dear Hiring Manager,           │  │
│  │                                │  │
│  │ I am excited to apply for...   │  │
│  └────────────────────────────────┘  │
│  [Edit] [Copy] [Download]            │
│  [Back to Tools]                     │
└──────────────────────────────────────┘

TOOL #2: Networking Message (Screen #21)
┌──────────────────────────────────────┐
│  NETWORKING MESSAGE GENERATOR        │
│  /app/tools/networking               │
├──────────────────────────────────────┤
│  Context:                            │
│  ○ Cold outreach                     │
│  ● Mutual connection                 │
│  ○ Event follow-up                   │
│                                      │
│  Recipient:                          │
│  ┌────────────────────────────────┐  │
│  │ Name, Title, Company           │  │
│  └────────────────────────────────┘  │
│                                      │
│  Goal:                               │
│  ▼ Informational interview           │
│                                      │
│  [Generate Message] →                │
│                                      │
│  Generated Message:                  │
│  ┌────────────────────────────────┐  │
│  │ Hi [Name],                     │  │
│  │ I noticed we both...           │  │
│  └────────────────────────────────┘  │
│  [Copy] [Edit]                       │
│  [Back to Tools]                     │
└──────────────────────────────────────┘

TOOL #3: Portfolio Architect (Screen #22)
┌──────────────────────────────────────┐
│  PORTFOLIO ARCHITECT                 │
│  /app/tools/portfolio                │
├──────────────────────────────────────┤
│  Create Your Career Portfolio        │
│                                      │
│  Projects:                           │
│  ┌────────────────────────────────┐  │
│  │ + Add Project                  │  │
│  │ ─────────────────────────      │  │
│  │ Project 1: E-commerce App      │  │
│  │ Project 2: Data Dashboard      │  │
│  └────────────────────────────────┘  │
│                                      │
│  Skills Showcase:                    │
│  [React] [Python] [SQL] [+ Add]      │
│                                      │
│  [Preview Portfolio]                 │
│  [Export as PDF]                     │
│  [Back to Tools]                     │
└──────────────────────────────────────┘

TOOL #4: Salary Negotiator (Screen #23)
┌──────────────────────────────────────┐
│  SALARY NEGOTIATION ASSISTANT        │
│  /app/tools/salary                   │
├──────────────────────────────────────┤
│  Current Offer:                      │
│  $ ┌──────────┐                      │
│    │ 120,000  │                      │
│    └──────────┘                      │
│                                      │
│  Target Salary:                      │
│  $ ┌──────────┐                      │
│    │ 140,000  │                      │
│    └──────────┘                      │
│                                      │
│  Experience:                         │
│  ▼ 5-7 years                         │
│                                      │
│  [Generate Script] →                 │
│                                      │
│  Negotiation Script:                 │
│  ┌────────────────────────────────┐  │
│  │ "Thank you for the offer.      │  │
│  │  Based on my experience and    │  │
│  │  market data..."               │  │
│  └────────────────────────────────┘  │
│                                      │
│  Market Insights:                    │
│  • Average for role: $135K           │
│  • 75th percentile: $150K            │
│                                      │
│  [Copy Script] [Back to Tools]       │
└──────────────────────────────────────┘

NAVIGATION PATHS:
19 (Hub) → 20 (Cover Letter) → 19 (Hub)
19 (Hub) → 21 (Networking) → 19 (Hub)
19 (Hub) → 22 (Portfolio) → 19 (Hub)
19 (Hub) → 23 (Salary) → 19 (Hub)
```

---

## 🔀 Complete User Flow Examples

### Example Flow 1: Complete Onboarding
```
START
  ↓
Splash (1) → Signup (3) → Profile Setup (4) → Dashboard (5)
  ↓
Resume Upload (6) → Processing (7) → Analysis (8)
  ↓
Dashboard (5) → Explore other modules
```

### Example Flow 2: Job Application Workflow
```
Dashboard (5)
  ↓
Job Board (13) → Add New Job (14) → Job Board (13)
  ↓
[Drag card: Wishlist → Applied]
  ↓
View Detail (15) → Add notes → Back to Board (13)
  ↓
Tools Hub (19) → Cover Letter (20) → Generate → Copy
  ↓
Back to Dashboard (5)
```

### Example Flow 3: Interview Preparation
```
Dashboard (5)
  ↓
Mock Interview Setup (10) → Select PM, Mid-level, 30min
  ↓
Interview Execution (11) → Answer 10 questions
  ↓
Interview Feedback (12) → Review score 8.5/10
  ↓
AI Career Chat (17) → "How can I improve answer to Q3?"
  ↓
Get tips → Practice again or Dashboard
```

### Example Flow 4: Career Transition Support
```
Dashboard (5)
  ↓
AI Career Chat (17) → "I want to switch from PM to Data"
  ↓
Get AI advice → Suggested: Check Skill Gap
  ↓
Skill Gap (9) → See missing skills: SQL, Python, Tableau
  ↓
Tools Hub (19) → Portfolio Architect (22) → Build data projects
  ↓
Dashboard (5) → Track progress
```

---

## 📱 Screen-by-Screen Quick Reference

| # | Screen | Route | Module | Parent |
|---|--------|-------|--------|--------|
| 1 | Splash | `/` | Auth | - |
| 2 | Login | `/auth/login` | Auth | Splash |
| 3 | Signup | `/auth/signup` | Auth | Splash |
| 4 | Profile Setup | `/auth/setup` | Auth | Signup |
| 5 | Dashboard | `/app` | Hub | - |
| 6 | Resume Upload | `/app/resume/upload` | Resume | Dashboard |
| 7 | Processing | `/app/resume/processing` | Resume | Upload |
| 8 | Analysis | `/app/resume/analysis` | Resume | Processing |
| 9 | Skill Gap | `/app/resume/skills` | Resume | Analysis |
| 10 | Interview Setup | `/app/interview/setup` | Interview | Dashboard |
| 11 | Interview Active | `/app/interview/active` | Interview | Setup |
| 12 | Interview Feedback | `/app/interview/feedback` | Interview | Active |
| 13 | Job Board | `/app/jobs` | Jobs | Dashboard |
| 14 | Job Entry | `/app/jobs/new` | Jobs | Board |
| 15 | Job Detail | `/app/jobs/:id` | Jobs | Board |
| 16 | Job Edit | `/app/jobs/:id/edit` | Jobs | Detail |
| 17 | AI Chat | `/app/chat` | Chat | Dashboard |
| 18 | New Chat | `/app/chat/new` | Chat | AI Chat |
| 19 | Tools Hub | `/app/tools` | Tools | Dashboard |
| 20 | Cover Letter | `/app/tools/cover-letter` | Tools | Hub |
| 21 | Networking | `/app/tools/networking` | Tools | Hub |
| 22 | Portfolio | `/app/tools/portfolio` | Tools | Hub |
| 23 | Salary | `/app/tools/salary` | Tools | Hub |

---

## 🎯 Module Summary

```
┌────────────────────────────────────────────────────────┐
│  MODULE BREAKDOWN                                      │
├────────────────┬───────────┬──────────────────────────┤
│ Module         │ Screens   │ Key Features             │
├────────────────┼───────────┼──────────────────────────┤
│ 1. Auth        │ 4 (1-4)   │ Session, Login, Signup   │
│ 2. Dashboard   │ 1 (5)     │ Hub, Stats, Navigation   │
│ 3. Resume      │ 4 (6-9)   │ Upload, AI Score, Skills │
│ 4. Interview   │ 3 (10-12) │ Setup, Q&A, Feedback     │
│ 5. Jobs        │ 4 (13-16) │ Kanban, CRUD, Tracking   │
│ 6. Chat        │ 2 (17-18) │ AI Conversation, History │
│ 7. Tools       │ 5 (19-23) │ 4 Generators + Hub       │
├────────────────┼───────────┼──────────────────────────┤
│ TOTAL          │ 23        │ Fully Connected          │
└─────���──────────┴───────────┴──────────────────────────┘
```

---

## ✅ Verification Points

### Routing Verification
- [ ] All 23 routes are defined in `/src/app/routes.tsx`
- [ ] Protected routes use `DashboardLayout`
- [ ] Public routes (auth) are standalone
- [ ] Dynamic routes work (`:id` for jobs)

### Navigation Verification
- [ ] Dashboard links to all 6 modules
- [ ] Each module has proper back navigation
- [ ] Sequential flows work (Upload → Process → Analysis)
- [ ] Sidebar navigation accessible on all `/app/*` routes

### Module Connectivity
- [ ] Resume module: 4-screen pipeline complete
- [ ] Interview module: 3-screen flow complete
- [ ] Jobs module: Kanban + CRUD complete
- [ ] Chat module: Main + New working
- [ ] Tools module: Hub + 4 tools connected

### User Experience
- [ ] No dead-end screens (all have exit paths)
- [ ] Consistent design across screens
- [ ] Loading states implemented
- [ ] Responsive layouts working

---

**End of Visual Workflow Documentation**

*Use this document to verify the complete navigation flow and ensure all 23 screens are properly connected and accessible.*
