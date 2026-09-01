alter table public.universities drop constraint if exists universities_logo_url_check;
alter table public.universities add constraint universities_logo_url_check
  check (logo_url is null or logo_url ~ '^(https?://|/)');

update public.universities set logo_url = case slug
  when 'nust' then '/universities/nust.png'
  when 'fast-nuces' then '/universities/fast-nuces.png'
  when 'comsats' then '/universities/comsats.png'
  when 'giki' then '/universities/giki.png'
  when 'uet-lahore' then '/universities/uet-lahore.png'
  when 'pieas' then '/universities/pieas.png'
  when 'air-university' then '/universities/air-university.png'
  when 'ist' then '/universities/ist.png'
  when 'bahria-university' then '/universities/bahria-university.png'
  when 'lums' then '/universities/lums.png'
  when 'ned' then '/universities/ned.png'
  when 'university-of-punjab' then '/universities/university-of-punjab.png'
  else logo_url
end,
updated_at = now()
where slug in ('nust','fast-nuces','comsats','giki','uet-lahore','pieas','air-university','ist','bahria-university','lums','ned','university-of-punjab');
