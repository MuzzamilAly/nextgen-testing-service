alter table public.mock_tests
  add column if not exists cover_image_url text;

update public.mock_tests
set cover_image_url = case name
  when 'Science Mini Mock' then '/test-science-mini.png'
  when 'English Skills Quiz' then '/subject-english.png'
  when 'NEXTGEN Foundation Diagnostic' then '/test-foundation-diagnostic.png'
  else cover_image_url
end
where name in ('Science Mini Mock', 'English Skills Quiz', 'NEXTGEN Foundation Diagnostic');

update public.mock_tests
set description = 'Three focused questions on grammar and subject-verb agreement.'
where name = 'English Skills Quiz';
