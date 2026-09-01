import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import type { Session, User } from "@supabase/supabase-js";
import { isSupabaseConfigured, supabase } from "@/lib/supabase";
import type { Database } from "@/types/database";

export type Profile = Database["public"]["Tables"]["profiles"]["Row"];
type AuthState = {
  session: Session | null; user: User | null; profile: Profile | null;
  loading: boolean; configured: boolean; refreshProfile: () => Promise<void>; signOut: () => Promise<void>;
};
const AuthContext = createContext<AuthState | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session,setSession]=useState<Session|null>(null);
  const [profile,setProfile]=useState<Profile|null>(null);
  const [loading,setLoading]=useState(true);

  const loadProfile=useCallback(async(user:User|null)=>{
    if(!supabase||!user){setProfile(null);return;}
    const {data,error}=await supabase.from("profiles").select("*").eq("id",user.id).single();
    if(error){console.error("Unable to load profile",error.message);setProfile(null);return;}
    setProfile(data);
  },[]);

  useEffect(()=>{
    if(!supabase){setLoading(false);return;}
    let active=true;
    supabase.auth.getSession().then(async({data})=>{if(!active)return;setSession(data.session);await loadProfile(data.session?.user??null);if(active)setLoading(false);});
    const {data:{subscription}}=supabase.auth.onAuthStateChange((_event,next)=>{setSession(next);setTimeout(()=>{void loadProfile(next?.user??null);setLoading(false);},0);});
    return()=>{active=false;subscription.unsubscribe();};
  },[loadProfile]);

  const value=useMemo<AuthState>(()=>({session,user:session?.user??null,profile,loading,configured:isSupabaseConfigured,refreshProfile:()=>loadProfile(session?.user??null),signOut:async()=>{if(supabase)await supabase.auth.signOut();}}),[session,profile,loading,loadProfile]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
// AuthProvider and its hook intentionally share this module.
// eslint-disable-next-line react-refresh/only-export-components
export function useAuth(){const value=useContext(AuthContext);if(!value)throw new Error("useAuth must be used inside AuthProvider");return value;}
