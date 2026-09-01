import { Navigate, Outlet, useLocation } from "react-router-dom";
import { LoaderCircle, ShieldAlert } from "lucide-react";
import { useAuth } from "./auth-context";
import { Button } from "@/components/ui/button";

export function StudentRoute(){const {user,loading}=useAuth();const location=useLocation();if(loading)return <Loading/>;return user?<Outlet/>:<Navigate to="/login" replace state={{from:location.pathname}}/>;}
export function AdminRoute(){const {user,profile,loading}=useAuth();if(loading)return <Loading/>;if(!user)return <Navigate to="/login" replace state={{from:"/admin/dashboard"}}/>;if(profile?.role!=="admin")return <section className="container flex min-h-[65vh] flex-col items-center justify-center text-center"><ShieldAlert className="size-12 text-amber-500"/><h1 className="mt-5 section-title">Admin access required</h1><p className="section-copy max-w-md">Your account does not have permission to access this area.</p><Button className="mt-6" onClick={()=>history.back()}>Go back</Button></section>;return <Outlet/>;}
function Loading(){return <div className="grid min-h-[65vh] place-items-center"><LoaderCircle className="size-8 animate-spin text-primary" aria-label="Loading account"/></div>}
