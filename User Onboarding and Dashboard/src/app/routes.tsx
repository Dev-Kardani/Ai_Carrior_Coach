import { createBrowserRouter } from "react-router";
import DashboardLayout from "./layout/DashboardLayout";
import SplashScreen from "./pages/auth/SplashScreen";
import LoginScreen from "./pages/auth/LoginScreen";
import SignupScreen from "./pages/auth/SignupScreen";
import ProfileSetupScreen from "./pages/auth/ProfileSetupScreen";
import DashboardScreen from "./pages/dashboard/DashboardScreen";
import ResumeUploadScreen from "./pages/resume/ResumeUploadScreen";
import ProcessingStateScreen from "./pages/resume/ProcessingStateScreen";
import ResumeAnalysisScreen from "./pages/resume/ResumeAnalysisScreen";
import SkillGapScreen from "./pages/resume/SkillGapScreen";
import MockInterviewSetupScreen from "./pages/interview/MockInterviewSetupScreen";
import MockInterviewExecutionScreen from "./pages/interview/MockInterviewExecutionScreen";
import MockInterviewFeedbackScreen from "./pages/interview/MockInterviewFeedbackScreen";
import JobBoardScreen from "./pages/jobs/JobBoardScreen";
import JobEntryScreen from "./pages/jobs/JobEntryScreen";
import JobDetailViewScreen from "./pages/jobs/JobDetailViewScreen";
import JobEditScreen from "./pages/jobs/JobEditScreen";
import AICareerChatScreen from "./pages/chat/AICareerChatScreen";
import NewChatScreen from "./pages/chat/NewChatScreen";
import ToolsHubScreen from "./pages/tools/ToolsHubScreen";
import CoverLetterScreen from "./pages/tools/CoverLetterScreen";
import NetworkingMessageScreen from "./pages/tools/NetworkingMessageScreen";
import PortfolioArchitectScreen from "./pages/tools/PortfolioArchitectScreen";
import SalaryNegotiatorScreen from "./pages/tools/SalaryNegotiatorScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: SplashScreen,
  },
  {
    path: "/auth/login",
    Component: LoginScreen,
  },
  {
    path: "/auth/signup",
    Component: SignupScreen,
  },
  {
    path: "/auth/setup",
    Component: ProfileSetupScreen,
  },
  {
    path: "/app",
    Component: DashboardLayout,
    children: [
      { index: true, Component: DashboardScreen },
      { path: "resume/upload", Component: ResumeUploadScreen },
      { path: "resume/processing", Component: ProcessingStateScreen },
      { path: "resume/analysis", Component: ResumeAnalysisScreen },
      { path: "resume/skills", Component: SkillGapScreen },
      { path: "interview/setup", Component: MockInterviewSetupScreen },
      { path: "interview/active", Component: MockInterviewExecutionScreen },
      { path: "interview/feedback", Component: MockInterviewFeedbackScreen },
      { path: "jobs", Component: JobBoardScreen },
      { path: "jobs/new", Component: JobEntryScreen },
      { path: "jobs/:id", Component: JobDetailViewScreen },
      { path: "jobs/:id/edit", Component: JobEditScreen },
      { path: "chat", Component: AICareerChatScreen },
      { path: "chat/new", Component: NewChatScreen },
      { path: "tools", Component: ToolsHubScreen },
      { path: "tools/cover-letter", Component: CoverLetterScreen },
      { path: "tools/networking", Component: NetworkingMessageScreen },
      { path: "tools/portfolio", Component: PortfolioArchitectScreen },
      { path: "tools/salary", Component: SalaryNegotiatorScreen },
    ],
  },
]);
