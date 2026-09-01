import { useEffect, useState } from "react";

export function useCatalog<T>(loader:()=>Promise<{items:T[];count:number}>){const [items,setItems]=useState<T[]>([]);const [count,setCount]=useState(0);const [loading,setLoading]=useState(true);const [error,setError]=useState("");useEffect(()=>{let active=true;setLoading(true);loader().then(result=>{if(active){setItems(result.items);setCount(result.count);setLoading(false)}}).catch(()=>{if(active){setError("Catalog information is currently unavailable.");setLoading(false)}});return()=>{active=false};},[loader]);return {items,count,loading,error};}
