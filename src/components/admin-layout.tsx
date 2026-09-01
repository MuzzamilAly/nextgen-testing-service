import { useState } from "react";
import { BarChart3, BookOpen, Building2, ChevronLeft, ClipboardList, FileQuestion, GraduationCap, LayoutDashboard, Library, ListTree, Menu, Settings, ShieldCheck, Target, TestTube2, UserRoundCheck, Users, X } from "lucide-react";
import { Link, NavLink, Outlet } from "react-router-dom";
import { useAuth } from "@/auth/auth-context";
import { BrandLogo } from "./brand-logo";
import { Button } from "./ui/button";
import { cn } from "@/lib/utils";

// Shared with the placeholder page to keep route labels and icons consistent.
// eslint-disable-next-line react-refresh/only-export-components
export const adminNav=[
  ["Dashboard","/admin/dashboard",LayoutDashboard],["Students","/admin/students",Users],["Universities","/admin/universities",Building2],
  ["Programs","/admin/programs",GraduationCap],["Entry Tests","/admin/entry-tests",Target],["Subjects","/admin/subjects",BookOpen],["Chapters","/admin/chapters",Library],
  ["Topics","/admin/topics",ListTree],["Study Material","/admin/study-material",ClipboardList],["Question Bank","/admin/question-bank",FileQuestion],
  ["Mock Tests","/admin/mock-tests",TestTube2],["Exam Attempts","/admin/exam-attempts",UserRoundCheck],["Results","/admin/results",BarChart3],["Settings","/admin/settings",Settings],
] as const;

export function AdminLayout(){const [open,setOpen]=useState(false);const {profile,signOut}=useAuth();return <div className="min-h-screen bg-slate-100 lg:grid lg:grid-cols-[270px_1fr]">
  {open&&<button className="fixed inset-0 z-40 bg-slate-950/50 lg:hidden" onClick={()=>setOpen(false)} aria-label="Close navigation"/>}
  <aside className={cn("fixed inset-y-0 left-0 z-50 flex w-[270px] flex-col bg-slate-950 text-slate-300 transition-transform lg:sticky lg:top-0 lg:h-screen lg:translate-x-0",open?"translate-x-0":"-translate-x-full")}>
    <div className="flex h-20 items-center justify-between border-b border-white/10 px-5"><Link to="/admin/dashboard" className="rounded-lg bg-white p-2"><BrandLogo/></Link><Button className="text-white lg:hidden" variant="ghost" size="icon" onClick={()=>setOpen(false)}><X/></Button></div>
    <div className="flex items-center gap-3 border-b border-white/10 px-5 py-5"><div className="grid size-10 place-items-center rounded-xl bg-teal-400/10 text-teal-400"><ShieldCheck/></div><div className="min-w-0"><p className="truncate text-sm font-bold text-white">{profile?.full_name||"Administrator"}</p><p className="text-xs text-slate-500">Admin account</p></div></div>
    <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-4" aria-label="Admin navigation">{adminNav.map(([label,to,Icon])=><NavLink key={to} to={to} onClick={()=>setOpen(false)} className={({isActive})=>cn("flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition hover:bg-white/5 hover:text-white",isActive&&"bg-primary text-white shadow-lg shadow-primary/10")}><Icon className="size-4"/>{label}</NavLink>)}</nav>
    <div className="border-t border-white/10 p-4"><Button asChild className="w-full justify-start text-slate-300" variant="ghost"><Link to="/"><ChevronLeft/>View public website</Link></Button><Button className="mt-1 w-full justify-start text-slate-300" variant="ghost" onClick={()=>void signOut()}>Logout</Button></div>
  </aside>
  <div className="min-w-0"><header className="sticky top-0 z-30 flex h-20 items-center justify-between border-b bg-white/90 px-5 backdrop-blur sm:px-8"><div className="flex items-center gap-3"><Button className="lg:hidden" variant="outline" size="icon" onClick={()=>setOpen(true)} aria-label="Open admin navigation"><Menu/></Button><div><p className="text-xs font-bold uppercase tracking-wider text-primary">NEXTGEN</p><p className="font-display font-bold text-slate-900">Administration</p></div></div><div className="flex items-center gap-2 text-sm text-slate-500"><span className="hidden sm:inline">Secure admin area</span><ShieldCheck className="size-5 text-teal-600"/></div></header><main className="p-5 sm:p-8"><Outlet/></main></div>
  </div>}
