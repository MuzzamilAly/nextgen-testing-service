import { useCallback } from "react";
import { ArrowRight, BookOpenCheck, ClipboardCheck, Clock3, FileText, LoaderCircle } from "lucide-react";
import { Link } from "react-router-dom";
import { useAuth } from "@/auth/auth-context";
import { PageHero } from "@/components/page-hero";
import { CatalogState } from "@/components/subject-grid";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { listAvailableTests, listPublishedMaterials } from "@/data/catalog-repository";
import { useCatalog } from "@/hooks/use-catalog";

export function ResourcePage({type}:{type:"tests"|"material"}){return type==="tests"?<TestsPage/>:<MaterialsPage/>}

function TestsPage(){
  const {user}=useAuth();const loader=useCallback(()=>listAvailableTests(),[]);const {items,loading,error}=useCatalog(loader);
  return <><PageHero eyebrow="Practice tests" title="Practice with purpose" description="Build confidence with published exam-style tests from the NEXTGEN database."><Button asChild className="mt-7"><a href="#available-tests">View available tests <ArrowRight className="size-4"/></a></Button></PageHero>
    <section id="available-tests" className="scroll-mt-20 py-16"><div className="container"><h2 className="section-title">Available tests</h2><p className="section-copy mb-9">Choose a published test and continue through your secure student account.</p>
      {loading?<Loading/>:error?<CatalogState text={error}/>:!items.length?<CatalogState text="No published practice tests are available yet."/>:<div className="grid gap-5 md:grid-cols-2 lg:grid-cols-3">{items.map(test=><Card key={test.id} className="group overflow-hidden">{test.cover_image_url?<div className="aspect-[16/9] overflow-hidden bg-slate-50"><img src={test.cover_image_url} alt={`${test.name} cover`} className="size-full object-cover transition duration-500 group-hover:scale-105" loading="lazy"/></div>:null}<CardContent className="p-7"><div className="grid size-12 place-items-center rounded-xl bg-sky-50 text-primary"><ClipboardCheck/></div><h3 className="mt-5 font-display text-xl font-bold">{test.name}</h3><p className="mt-2 min-h-12 text-sm leading-6 text-slate-600">{test.description??"Structured admission-test practice."}</p><div className="mt-5 flex gap-4 border-t pt-4 text-xs font-semibold text-slate-500"><span className="flex items-center gap-1.5"><FileText className="size-4"/>{test.question_count} questions</span><span className="flex items-center gap-1.5"><Clock3 className="size-4"/>{test.duration_minutes} minutes</span></div><Button asChild className="mt-5 w-full"><Link to={user?`/student/tests/${test.id}`:"/login"}>{user?"Start Mock Test":"Sign in to start"}</Link></Button></CardContent></Card>)}</div>}
    </div></section></>;
}

function MaterialsPage(){
  const loader=useCallback(()=>listPublishedMaterials(),[]);const {items,loading,error}=useCatalog(loader);
  return <><PageHero eyebrow="Study material" title="Study with clarity" description="Focused notes and resources loaded from the NEXTGEN academic database."><Button asChild className="mt-7"><a href="#learning-resources">View learning material <ArrowRight className="size-4"/></a></Button></PageHero>
    <section id="learning-resources" className="scroll-mt-20 py-16"><div className="container"><h2 className="section-title">Published learning resources</h2><p className="section-copy mb-9">Review concise foundations across your admission-test subjects.</p>
      {loading?<Loading/>:error?<CatalogState text={error}/>:!items.length?<CatalogState text="No published study material is available yet."/>:<div className="grid gap-5 md:grid-cols-2">{items.map(item=><Card key={item.id}><CardContent className="p-7"><div className="grid size-12 place-items-center rounded-xl bg-teal-50 text-teal-700"><BookOpenCheck/></div><h3 className="mt-5 font-display text-xl font-bold">{item.title}</h3><p className="mt-2 text-sm font-medium leading-6 text-slate-500">{item.description??"Published study resource"}</p><div className="mt-5 whitespace-pre-line border-t pt-5 text-sm leading-7 text-slate-700">{item.content}</div></CardContent></Card>)}</div>}
    </div></section></>;
}

function Loading(){return <div className="grid min-h-48 place-items-center"><LoaderCircle className="animate-spin text-primary"/></div>}
