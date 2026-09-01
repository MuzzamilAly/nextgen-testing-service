import { useEffect } from "react";
import { Link, Outlet, useLocation } from "react-router-dom";
import { BrandLogo } from "./brand-logo";
import { SiteHeader } from "./site-header";
import { EducationalDisclaimer } from "./educational-disclaimer";

export function SiteLayout() {
  const { pathname } = useLocation();
  useEffect(() => { window.scrollTo(0, 0); }, [pathname]);

  return <div className="min-h-screen overflow-hidden bg-background text-foreground">
    <SiteHeader />
    <main><Outlet /></main>
    <footer className="border-t bg-slate-950 py-12 text-slate-300">
      <div className="container grid gap-9 md:grid-cols-[1.4fr_1fr_1fr]">
        <div><div className="inline-flex rounded-xl bg-white p-2"><BrandLogo /></div><p className="mt-4 max-w-sm text-sm leading-6 text-slate-400">Organized digital preparation for future medical and nursing professionals.</p><p className="mt-3 text-xs font-semibold text-teal-400">Founded by BHARAT KOHLI</p><div className="mt-4 grid gap-1 text-sm text-slate-400"><a className="hover:text-white" href="mailto:nextgentesting001@gmail.com">nextgentesting001@gmail.com</a><a className="hover:text-white" href="tel:+923362300940">+92 336 2300940</a></div></div>
        <FooterLinks title="Explore" links={[["Programs","/programs"],["Entry Tests","/entry-tests"],["Practice Tests","/practice-tests"],["Study Material","/study-material"]]} />
        <FooterLinks title="Company" links={[["About","/about"],["Contact","/contact"],["Student Login","/login"]]} />
      </div>
      <div className="container mt-9"><EducationalDisclaimer /></div>
      <div className="container mt-10 border-t border-white/10 pt-6 text-xs text-slate-500">© {new Date().getFullYear()} NEXTGEN TESTING SERVICE. All rights reserved.</div>
    </footer>
  </div>;
}

function FooterLinks({ title, links }: { title: string; links: string[][] }) {
  return <div><h3 className="font-bold text-white">{title}</h3><div className="mt-4 grid gap-2 text-sm">{links.map(([label,to]) => <Link key={to} to={to}>{label}</Link>)}</div></div>;
}
