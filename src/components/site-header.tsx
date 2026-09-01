import { useState } from "react";
import { Menu, X } from "lucide-react";
import { Link, NavLink } from "react-router-dom";
import { BrandLogo } from "./brand-logo";
import { Button } from "./ui/button";
import { cn } from "@/lib/utils";
import { useAuth } from "@/auth/auth-context";

const links = [["Programs","/programs"],["Universities","/universities"],["Entry Tests","/entry-tests"],["Subjects","/subjects"],["Practice Tests","/practice-tests"],["Study Material","/study-material"],["About","/about"]];
export function SiteHeader() {
  const [open,setOpen]=useState(false);
  const {user,profile,signOut}=useAuth();
  const accountTo=profile?.role==="admin"?"/admin":"/student/dashboard";
  return <header className="sticky top-0 z-50 border-b border-slate-200/70 bg-white/95 backdrop-blur-xl"><div className="container flex h-20 items-center justify-between"><Link to="/" aria-label="NEXTGEN home"><BrandLogo /></Link><nav className="hidden items-center gap-5 xl:flex" aria-label="Main navigation">{links.map(([label,to]) => <NavLink key={to} to={to} className={({isActive})=>cn("text-sm font-medium text-slate-600 transition hover:text-primary",isActive&&"text-primary")}>{label}</NavLink>)}</nav><div className="hidden items-center gap-2 sm:flex">{user?<><Button asChild variant="ghost"><Link to={accountTo}>{profile?.full_name||"Dashboard"}</Link></Button><Button variant="outline" onClick={()=>void signOut()}>Logout</Button></>:<><Button asChild variant="ghost"><Link to="/login">Sign in</Link></Button><Button asChild><Link to="/register">Get started</Link></Button></>}</div><Button onClick={()=>setOpen(!open)} className="xl:hidden" variant="ghost" size="icon" aria-label="Toggle menu" aria-expanded={open}>{open?<X/>:<Menu/>}</Button></div>{open&&<nav className="container grid gap-1 border-t py-4 xl:hidden" aria-label="Mobile navigation">{links.map(([label,to])=><NavLink onClick={()=>setOpen(false)} key={to} to={to} className="rounded-lg px-3 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">{label}</NavLink>)}<div className="mt-2 grid grid-cols-2 gap-2 sm:hidden">{user?<><Button asChild><Link onClick={()=>setOpen(false)} to={accountTo}>Dashboard</Link></Button><Button variant="outline" onClick={()=>{void signOut();setOpen(false)}}>Logout</Button></>:<><Button asChild variant="outline"><Link onClick={()=>setOpen(false)} to="/login">Sign in</Link></Button><Button asChild><Link onClick={()=>setOpen(false)} to="/register">Get started</Link></Button></>}</div></nav>}</header>;
}
