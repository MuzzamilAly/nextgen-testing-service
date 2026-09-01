export function BrandLogo({compact=false}:{compact?:boolean}){
  return <div className="flex items-center gap-3"><img src="/nextgen-logo.png" alt="NEXTGEN TESTING SERVICE logo" className="size-14 shrink-0 object-contain"/>{!compact&&<div><div className="font-display text-sm font-extrabold leading-tight tracking-[.08em] text-slate-900">NEXTGEN</div><div className="text-[9px] font-bold tracking-[.19em] text-primary">TESTING SERVICE</div></div>}</div>;
}
