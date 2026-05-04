do $$
begin
	if not exists (select 1 from pg_roles where rolname = 'supabase_admin') then
		create role supabase_admin login superuser password 'postgres';
	else
		alter role supabase_admin with login superuser password 'postgres';
	end if;
end
$$;

