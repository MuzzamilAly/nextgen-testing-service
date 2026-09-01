import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
export function NotFoundPage(){return <section className="container flex min-h-[60vh] flex-col items-center justify-center text-center"><p className="section-label">404</p><h1 className="section-title">This page could not be found.</h1><p className="section-copy">The link may be outdated or the page may have moved.</p><Button asChild className="mt-7"><Link to="/">Return home</Link></Button></section>}
