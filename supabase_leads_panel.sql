-- ============================================================
-- Inuv Conecta — Painel de leads: status + acesso autenticado
-- Cole no SQL Editor do Supabase e clique em Run
-- ============================================================

-- Campo de status do lead (novo, contatado, fechou, nao_respondeu)
alter table leads add column if not exists status text not null default 'novo';

-- Permite que QUALQUER USUÁRIO AUTENTICADO (você, logado no painel)
-- possa ler e atualizar os leads. O público em geral (anon) continua
-- só podendo INSERIR (enviar), nunca ler ou editar.
create policy "Usuário autenticado pode ler leads" on leads
  for select
  to authenticated
  using (true);

create policy "Usuário autenticado pode atualizar leads" on leads
  for update
  to authenticated
  using (true);
