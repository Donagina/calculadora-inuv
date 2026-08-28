-- ============================================================
-- Inuv Internet — Calculadora de Diagnóstico
-- Script de criação das tabelas + dados iniciais (seed)
-- Cole isso inteiro no SQL Editor do Supabase e clique em Run
-- ============================================================

-- 1) Tabela de PLANOS (residencial, empresarial, celular)
create table if not exists plans (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('residencial','empresarial','celular')),
  name text not null,
  price_label text not null,
  down_mbps numeric,      -- usado em residencial/empresarial
  up_mbps numeric,        -- usado em residencial/empresarial
  gb numeric,             -- usado em celular
  sort_order int not null default 0
);

-- 2) Tabela de PERFIS DE USO (o que aparece como item marcável na calculadora)
create table if not exists usage_profiles (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('residencial','empresarial','celular')),
  profile_key text not null,       -- identificador curto (ex: 'cam1080')
  name text not null,
  unit text,                       -- ex: 'câmera(s)' — null quando não tem quantidade
  has_qty boolean not null default false,
  def_qty int default 0,
  down_mbps numeric,                -- null para perfis de celular
  up_mbps numeric,                  -- null para perfis de celular
  levels jsonb,                     -- só para celular: [{"label":"Leve","gb":3}, ...]
  sort_order int not null default 0,
  unique (type, profile_key)
);

-- 3) Tabela de LEADS (capturados quando alguém usa a calculadora)
create table if not exists leads (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text,
  phone text,
  plan_type text,                  -- 'residencial' | 'empresarial' | 'celular'
  selected_profiles jsonb,         -- snapshot do que a pessoa marcou
  calculated_down numeric,
  calculated_up numeric,
  calculated_gb numeric,
  recommended_plan text
);

-- ============================================================
-- SEGURANÇA (Row Level Security)
-- Planos e perfis: qualquer pessoa pode LER (a calculadora é pública)
-- Leads: qualquer pessoa pode INSERIR (enviar), ninguém de fora pode LER
--        (você lê os leads direto pelo painel do Supabase, autenticado)
-- ============================================================

alter table plans enable row level security;
alter table usage_profiles enable row level security;
alter table leads enable row level security;

create policy "Leitura pública de planos" on plans
  for select using (true);

create policy "Leitura pública de perfis" on usage_profiles
  for select using (true);

create policy "Qualquer um pode enviar lead" on leads
  for insert with check (true);

-- (De propósito, não existe policy de SELECT para leads — assim ninguém
--  de fora consegue ler a lista de contatos pelo site, só você pelo painel.)

-- ============================================================
-- DADOS INICIAIS — Planos reais da Inuv
-- ============================================================

insert into plans (type, name, price_label, down_mbps, up_mbps, sort_order) values
('residencial', '400 Mega', 'R$ 79,90/mês', 400, 400, 1),
('residencial', '700 Mega', 'R$ 99,90/mês', 700, 700, 2),
('residencial', '900 Mega', 'R$ 129,90/mês', 900, 900, 3),
('empresarial', '500 Mega Empresarial', 'R$ 119,90/mês', 500, 500, 1),
('empresarial', '700 Mega Empresarial', 'R$ 139,90/mês', 700, 700, 2),
('empresarial', '900 Mega Empresarial', 'R$ 169,90/mês', 900, 900, 3);

insert into plans (type, name, price_label, gb, sort_order) values
('celular', 'Plano 11GB', 'R$ 49,99/mês', 11, 1),
('celular', 'Plano 16GB', 'R$ 59,99/mês', 16, 2),
('celular', 'Plano 23GB', 'R$ 69,99/mês', 23, 3);

-- ============================================================
-- DADOS INICIAIS — Perfis de uso Residencial
-- ============================================================

insert into usage_profiles (type, profile_key, name, unit, has_qty, def_qty, down_mbps, up_mbps, sort_order) values
('residencial', 'basico', 'Streaming em TV/dispositivo', 'TV(s)', true, 1, 15, 2, 1),
('residencial', '4k', 'Streaming 4K', 'TV(s) em 4K', true, 0, 25, 2, 2),
('residencial', 'gamer', 'Jogos competitivos', null, false, 0, 10, 3, 3),
('residencial', 'cloudgame', 'Jogo em nuvem (GeForce Now etc.)', null, false, 0, 40, 3, 4),
('residencial', 'live', 'Live de vendas (TikTok/Insta/FB/Shopee)', 'transmissão(ões) simultânea(s)', true, 1, 3, 10, 5),
('residencial', 'criador', 'Criação/edição de vídeo', null, false, 0, 15, 15, 6),
('residencial', 'infoproduto', 'Aula ao vivo / infoproduto', null, false, 0, 5, 10, 7),
('residencial', 'homeoffice', 'Home office (videochamada)', 'pessoa(s) simultânea(s)', true, 1, 6, 6, 8),
('residencial', 'cam1080', 'Câmera de segurança 1080p', 'câmera(s)', true, 0, 1, 3, 9),
('residencial', 'cam4k', 'Câmera de segurança 4K', 'câmera(s)', true, 0, 2, 8, 10),
('residencial', 'automacao', 'Automação (Alexa, fechadura, portão)', null, false, 0, 1, 1, 11),
('residencial', 'marketplace', 'Venda em marketplace', null, false, 0, 5, 8, 12);

-- ============================================================
-- DADOS INICIAIS — Perfis de uso Empresarial
-- ============================================================

insert into usage_profiles (type, profile_key, name, unit, has_qty, def_qty, down_mbps, up_mbps, sort_order) values
('empresarial', 'equipe', 'Funcionários/dispositivos na rede', 'pessoa(s)', true, 2, 5, 5, 1),
('empresarial', 'cam1080e', 'Câmera de segurança 1080p', 'câmera(s)', true, 0, 1, 3, 2),
('empresarial', 'cam4ke', 'Câmera de segurança 4K', 'câmera(s)', true, 0, 2, 8, 3),
('empresarial', 'wificliente', 'Wi-Fi para clientes', null, false, 0, 15, 3, 4),
('empresarial', 'pdv', 'Sistema de PDV / estoque na nuvem', null, false, 0, 5, 5, 5),
('empresarial', 'liveempresa', 'Live de vendas da marca', 'transmissão(ões) simultânea(s)', true, 0, 3, 10, 6),
('empresarial', 'marketplacee', 'Gestão de marketplace', null, false, 0, 5, 8, 7),
('empresarial', 'infoprodutoe', 'Aula ao vivo / treinamento online', null, false, 0, 5, 10, 8);

-- ============================================================
-- DADOS INICIAIS — Perfis de uso Celular (com níveis leve/médio/intenso em GB)
-- ============================================================

insert into usage_profiles (type, profile_key, name, levels, sort_order) values
('celular', 'social', 'Redes sociais (Instagram/Facebook/TikTok)',
  '[{"label":"Leve","gb":3},{"label":"Médio","gb":8},{"label":"Intenso","gb":15}]', 1),
('celular', 'whats', 'WhatsApp (mensagens, fotos, chamadas de voz)',
  '[{"label":"Leve","gb":1},{"label":"Médio","gb":2},{"label":"Intenso","gb":4}]', 2),
('celular', 'gps', 'Navegação (Waze/Uber/Google Maps)',
  '[{"label":"Leve","gb":0.5},{"label":"Médio","gb":1.5},{"label":"Intenso","gb":3}]', 3),
('celular', 'video', 'Vídeo fora do Wi-Fi (YouTube/Netflix)',
  '[{"label":"Leve","gb":2},{"label":"Médio","gb":8},{"label":"Intenso","gb":20}]', 4),
('celular', 'videocall', 'Videochamadas pelo celular',
  '[{"label":"Leve","gb":1},{"label":"Médio","gb":3},{"label":"Intenso","gb":6}]', 5),
('celular', 'liveMobile', 'Live de vendas pelo celular (sem Wi-Fi)',
  '[{"label":"Leve","gb":3},{"label":"Médio","gb":8},{"label":"Intenso","gb":18}]', 6),
('celular', 'geral', 'Navegação geral, e-mail, apps de banco',
  '[{"label":"Leve","gb":1},{"label":"Médio","gb":2},{"label":"Intenso","gb":4}]', 7);
