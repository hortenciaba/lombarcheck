-- ============================================================
-- Lombar Check — schema do banco de dados (Supabase / PostgreSQL)
-- ============================================================
-- Como usar:
-- 1. Crie um projeto gratuito em https://supabase.com
-- 2. Abra "SQL Editor" no painel do projeto
-- 3. Cole este arquivo inteiro e clique em "Run"
-- 4. Em "Project Settings" > "API", copie a "Project URL" e a
--    "anon public key" e cole nas constantes SUPABASE_URL e
--    SUPABASE_ANON_KEY no topo do index.html
-- ============================================================

-- Tabela de pacientes: cada linha guarda a avaliação inteira de
-- um paciente como JSON (mesmo formato usado no app), amarrada
-- ao fisioterapeuta (user_id) que a criou.
create table if not exists public.patients (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null default 'Paciente sem nome',
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists patients_user_id_idx on public.patients(user_id);
create index if not exists patients_updated_at_idx on public.patients(updated_at desc);

-- ============================================================
-- Row Level Security (RLS): cada fisioterapeuta só enxerga,
-- edita e apaga os PRÓPRIOS pacientes. Isso é o que garante que
-- os dados fiquem realmente isolados e seguros entre contas.
-- ============================================================
alter table public.patients enable row level security;

drop policy if exists "select_own_patients" on public.patients;
create policy "select_own_patients"
  on public.patients for select
  using (auth.uid() = user_id);

drop policy if exists "insert_own_patients" on public.patients;
create policy "insert_own_patients"
  on public.patients for insert
  with check (auth.uid() = user_id);

drop policy if exists "update_own_patients" on public.patients;
create policy "update_own_patients"
  on public.patients for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "delete_own_patients" on public.patients;
create policy "delete_own_patients"
  on public.patients for delete
  using (auth.uid() = user_id);

-- ============================================================
-- Notas sobre segurança e LGPD:
-- - As senhas dos fisioterapeutas NUNCA ficam nesta tabela — o
--   Supabase Auth já cuida disso (hash + salt) na tabela interna
--   auth.users, que não é acessível diretamente pelo app.
-- - Os dados trafegam sempre por HTTPS.
-- - Se algum dia precisar apagar todos os dados de um usuário
--   (direito ao esquecimento da LGPD), basta apagar o usuário em
--   Authentication > Users no painel — o "on delete cascade"
--   acima já apaga os pacientes associados automaticamente.
-- - Para uso clínico real, avalie também assinar um DPA (Data
--   Processing Agreement) com o Supabase e revisar em qual
--   região os dados ficam hospedados (escolha ao criar o
--   projeto) — dados de saúde são "dados sensíveis" pela LGPD.
-- ============================================================
