-- ============================================================
-- Inuv Conecta — Recalibração dos valores Empresariais
-- Cole no SQL Editor do Supabase e clique em Run
-- ============================================================

update usage_profiles set down_mbps=10, up_mbps=10 where type='empresarial' and profile_key='equipe';
update usage_profiles set down_mbps=1,  up_mbps=5  where type='empresarial' and profile_key='cam1080e';
update usage_profiles set down_mbps=1,  up_mbps=12 where type='empresarial' and profile_key='cam4ke';
update usage_profiles set down_mbps=8,  up_mbps=2  where type='empresarial' and profile_key='wificliente';
update usage_profiles set down_mbps=5,  up_mbps=18 where type='empresarial' and profile_key='liveempresa';
update usage_profiles set down_mbps=80, up_mbps=50 where type='empresarial' and profile_key='marketplacee';

-- PDV agora pede quantidade de caixas (antes era um valor fixo único)
update usage_profiles
  set has_qty=true, def_qty=1, unit='caixa(s)', down_mbps=12, up_mbps=12
  where type='empresarial' and profile_key='pdv';
