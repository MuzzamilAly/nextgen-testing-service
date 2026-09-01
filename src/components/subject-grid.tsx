import { useCallback } from "react";
import { Atom, BookOpen, Brain, Calculator, ChartNoAxesCombined, Code2, Dna, FlaskConical, Globe2, Languages, LoaderCircle, Route } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "./ui/button";
import { listPublishedSubjects, type CatalogSubject } from "@/data/catalog-repository";
import { useCatalog } from "@/hooks/use-catalog";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";

const icons={dna:Dna,atom:Atom,book:BookOpen,languages:Languages,calculator:Calculator,flask:FlaskConical,code:Code2,brain:Brain,route:Route,chart:ChartNoAxesCombined,globe:Globe2};
const subjectImages={
  biology:"/subject-biology.png",
  chemistry:"/subject-chemistry.png",
  physics:"/subject-physics.png",
  english:"/subject-english.png",
};
export function SubjectGrid(){const loader=useCallback(()=>listPublishedSubjects(),[]);const {items,loading,error}=useCatalog(loader);if(loading)return <div className="grid min-h-40 place-items-center"><LoaderCircle className="animate-spin text-primary"/></div>;if(error)return <CatalogState text={error}/>;if(!items.length)return <CatalogState text="No published subjects are available yet."/>;return <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">{items.map(subject=><SubjectCard key={subject.id} subject={subject}/>)}</div>}
function SubjectCard({subject}:{subject:CatalogSubject}){const iconKey=(subject.icon??"book").toLowerCase();const Icon=icons[iconKey as keyof typeof icons]??BookOpen;const image=subjectImages[subject.slug.toLowerCase() as keyof typeof subjectImages]??imageFromName(subject.name);return <Card className="group flex flex-col overflow-hidden transition hover:-translate-y-1 hover:shadow-soft">{image?<div className="aspect-[4/3] overflow-hidden bg-slate-50"><img src={image} alt={`${subject.name} study book`} className="size-full object-cover transition duration-500 group-hover:scale-105" loading="lazy"/></div>:null}<CardHeader><div className="mb-3 grid size-12 place-items-center rounded-xl bg-sky-50 text-primary"><Icon/></div><CardTitle>{subject.name}</CardTitle></CardHeader><CardContent className="flex flex-1 flex-col text-sm leading-6 text-slate-600"><p className="flex-1">{subject.description??"Learning content is being prepared."}</p><Button asChild variant="outline" className="mt-5 w-full"><Link to={`/subjects/${subject.slug}`}>Explore Subject</Link></Button></CardContent></Card>}
function imageFromName(name:string){const key=name.trim().toLowerCase();return ({biology:"/subject-biology.png",chemistry:"/subject-chemistry.png",physics:"/subject-physics.png",english:"/subject-english.png"} as Record<string,string>)[key]}
export function CatalogState({text}:{text:string}){return <div className="rounded-2xl border border-dashed bg-white p-10 text-center text-sm text-slate-500">{text}</div>}
