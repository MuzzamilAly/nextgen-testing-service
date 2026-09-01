import { Navigate, Route, Routes } from "react-router-dom";
import { AdminRoute, StudentRoute } from "@/auth/route-guards";
import { AdminLayout } from "@/components/admin-layout";
import { SiteLayout } from "@/components/site-layout";
import { AboutPage, ContactPage, ProgramsPage, SubjectsPage, UniversitiesPage } from "@/pages/content-pages";
import { AuthPage, ForgotPasswordPage, ResetPasswordPage } from "@/pages/auth-page";
import { HomePage } from "@/pages/home-page";
import { ResourcePage } from "@/pages/resource-page";
import { NotFoundPage } from "@/pages/not-found-page";
import { StudentDashboard, StudentProfile, StudentResults } from "@/pages/dashboard-pages";
import { AdminDashboard, AdminPlaceholder } from "@/pages/admin-pages";
import { MockTestPage } from "@/pages/mock-test-page";
import { SubscriptionPage } from "@/pages/subscription-page";
import { ProgramDetailPage } from "@/pages/program-detail-page";
import { UniversityDetailPage } from "@/pages/university-detail-page";
import { EntryTestDetailPage, EntryTestsPage } from "@/pages/entry-tests-page";
import { SubjectDetailPage } from "@/pages/subject-detail-page";
import { StudyMaterialDetailPage, StudyMaterialsPage } from "@/pages/study-materials-page";

export default function App(){return <Routes>
  <Route element={<SiteLayout/>}>
    <Route index element={<HomePage/>}/><Route path="about" element={<AboutPage/>}/><Route path="programs" element={<ProgramsPage/>}/><Route path="programs/:slug" element={<ProgramDetailPage/>}/><Route path="universities" element={<UniversitiesPage/>}/><Route path="universities/:slug" element={<UniversityDetailPage/>}/><Route path="entry-tests" element={<EntryTestsPage/>}/><Route path="entry-tests/:slug" element={<EntryTestDetailPage/>}/><Route path="subjects" element={<SubjectsPage/>}/><Route path="subjects/:slug" element={<SubjectDetailPage/>}/><Route path="practice-tests" element={<ResourcePage type="tests"/>}/><Route path="study-material" element={<StudyMaterialsPage/>}/><Route path="study-material/:materialId" element={<StudyMaterialDetailPage/>}/><Route path="contact" element={<ContactPage/>}/>
    <Route path="login" element={<AuthPage mode="login"/>}/><Route path="register" element={<AuthPage mode="register"/>}/><Route path="forgot-password" element={<ForgotPasswordPage/>}/><Route path="reset-password" element={<ResetPasswordPage/>}/>
    <Route element={<StudentRoute/>}><Route path="student" element={<Navigate to="/student/dashboard" replace/>}/><Route path="student/dashboard" element={<StudentDashboard/>}/><Route path="student/profile" element={<StudentProfile/>}/><Route path="student/results" element={<StudentResults/>}/><Route path="student/subscription" element={<SubscriptionPage/>}/><Route path="student/tests/:testId" element={<MockTestPage/>}/></Route>
    <Route path="*" element={<NotFoundPage/>}/>
  </Route>
  <Route element={<AdminRoute/>}><Route path="admin" element={<AdminLayout/>}>
    <Route index element={<Navigate to="/admin/dashboard" replace/>}/><Route path="dashboard" element={<AdminDashboard/>}/>
    <Route path="students" element={<AdminPlaceholder section="Students"/>}/><Route path="universities" element={<AdminPlaceholder section="Universities"/>}/><Route path="programs" element={<AdminPlaceholder section="Programs"/>}/><Route path="entry-tests" element={<AdminPlaceholder section="Entry Tests"/>}/><Route path="subjects" element={<AdminPlaceholder section="Subjects"/>}/><Route path="chapters" element={<AdminPlaceholder section="Chapters"/>}/><Route path="topics" element={<AdminPlaceholder section="Topics"/>}/><Route path="study-material" element={<AdminPlaceholder section="Study Material"/>}/><Route path="question-bank" element={<AdminPlaceholder section="Question Bank"/>}/><Route path="mock-tests" element={<AdminPlaceholder section="Mock Tests"/>}/><Route path="exam-attempts" element={<AdminPlaceholder section="Exam Attempts"/>}/><Route path="results" element={<AdminPlaceholder section="Results"/>}/><Route path="settings" element={<AdminPlaceholder section="Settings"/>}/>
  </Route></Route>
</Routes>}
