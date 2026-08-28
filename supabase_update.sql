-- ============================================================
-- Inuv Conecta — Atualização dos valores de Mbps/GB e novos perfis
-- Cole isso no SQL Editor do Supabase e clique em Run
-- (é seguro rodar mesmo já tendo rodado o script anterior)
-- ============================================================

-- ---------- Atualiza valores de perfis existentes (Residencial) ----------
update usage_profiles set down_mbps=25, up_mbps=3  where type='residencial' and profile_key='basico';
update usage_profiles set down_mbps=50, up_mbps=3  where type='residencial' and profile_key='4k';
update usage_profiles set down_mbps=75, up_mbps=15 where type='residencial' and profile_key='gamer';
update usage_profiles set down_mbps=45, up_mbps=5  where type='residencial' and profile_key='cloudgame';
update usage_profiles set down_mbps=5,  up_mbps=20 where type='residencial' and profile_key='live';
update usage_profiles set down_mbps=75, up_mbps=35 where type='residencial' and profile_key='criador';
update usage_profiles set down_mbps=15, up_mbps=25, name='Aula ao vivo / infoproduto (você transmitindo)' where type='residencial' and profile_key='infoproduto';
update usage_profiles set down_mbps=30, up_mbps=15 where type='residencial' and profile_key='homeoffice';
update usage_profiles set down_mbps=1,  up_mbps=4  where type='residencial' and profile_key='cam1080';
update usage_profiles set down_mbps=1,  up_mbps=10 where type='residencial' and profile_key='cam4k';
update usage_profiles set down_mbps=5,  up_mbps=5  where type='residencial' and profile_key='automacao';
update usage_profiles set down_mbps=35, up_mbps=15 where type='residencial' and profile_key='marketplace';

-- ---------- Atualiza valores de perfis existentes (Empresarial) ----------
update usage_profiles set down_mbps=1,  up_mbps=4  where type='empresarial' and profile_key='cam1080e';
update usage_profiles set down_mbps=1,  up_mbps=10 where type='empresarial' and profile_key='cam4ke';
update usage_profiles set down_mbps=10, up_mbps=10 where type='empresarial' and profile_key='pdv';
update usage_profiles set down_mbps=5,  up_mbps=20 where type='empresarial' and profile_key='liveempresa';
update usage_profiles set down_mbps=40, up_mbps=15 where type='empresarial' and profile_key='marketplacee';
update usage_profiles set down_mbps=15, up_mbps=25, name='Aula ao vivo / treinamento online' where type='empresarial' and profile_key='infoprodutoe';

-- Wi-Fi para clientes agora pede quantidade de clientes simultâneos no pico
update usage_profiles
  set has_qty=true, def_qty=5, unit='cliente(s) simultâneo(s) no pico', down_mbps=5, up_mbps=1
  where type='empresarial' and profile_key='wificliente';

-- ---------- Novos perfis (Residencial) ----------
insert into usage_profiles (type, profile_key, name, unit, has_qty, def_qty, down_mbps, up_mbps, sort_order)
values
('residencial','celularwifi','Uso de celular no dia a dia (redes sociais, vídeos, posts)','pessoa(s)',true,1,8,3,13),
('residencial','jogosmobile','Jogos mobile para crianças (Free Fire, Roblox, Fortnite)','criança(s)',true,0,15,3,14)
on conflict (type, profile_key) do update
  set name=excluded.name, unit=excluded.unit, has_qty=excluded.has_qty,
      def_qty=excluded.def_qty, down_mbps=excluded.down_mbps, up_mbps=excluded.up_mbps;

-- ---------- Novo perfil (Empresarial) ----------
insert into usage_profiles (type, profile_key, name, unit, has_qty, def_qty, down_mbps, up_mbps, sort_order)
values
('empresarial','celularwifie','Uso de celular dos funcionários (Wi-Fi)','pessoa(s)',true,1,8,3,9)
on conflict (type, profile_key) do update
  set name=excluded.name, unit=excluded.unit, has_qty=excluded.has_qty,
      def_qty=excluded.def_qty, down_mbps=excluded.down_mbps, up_mbps=excluded.up_mbps;

-- ---------- Atualiza níveis de GB dos perfis de Celular ----------
update usage_profiles set levels='[{"label":"Leve","gb":1},{"label":"Médio","gb":3},{"label":"Intenso","gb":6}]'
  where type='celular' and profile_key='gps';
update usage_profiles set levels='[{"label":"Leve","gb":3},{"label":"Médio","gb":10},{"label":"Intenso","gb":25}]'
  where type='celular' and profile_key='video';
update usage_profiles set levels='[{"label":"Leve","gb":5},{"label":"Médio","gb":15},{"label":"Intenso","gb":30}]'
  where type='celular' and profile_key='liveMobile';

-- ---------- Novo perfil de Celular: jogos mobile ----------
insert into usage_profiles (type, profile_key, name, levels, sort_order)
values
('celular','jogosmobile','Jogos mobile (Free Fire, Roblox, Fortnite)',
  '[{"label":"Leve","gb":2},{"label":"Médio","gb":8},{"label":"Intenso","gb":18}]', 8)
on conflict (type, profile_key) do update
  set name=excluded.name, levels=excluded.levels;

-- ---------- Novos planos de celular (33GB, 50GB, 100GB) ----------
insert into plans (type, name, price_label, gb, sort_order) values
('celular', 'Plano 33GB', 'R$ 79,99/mês', 33, 4),
('celular', 'Plano 50GB', 'R$ 99,99/mês', 50, 5),
('celular', 'Plano 100GB', 'R$ 169,99/mês', 100, 6)
on conflict do nothing;
