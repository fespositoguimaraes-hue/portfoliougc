-- ============================================================================
-- IMPORTA OS JOBS ATIVOS DO UGCONTROL (lidos em 18/11/2026)
-- ============================================================================
-- 37 jobs: os 44 ativos menos 7 que já estavam cadastrados no admin
-- (Passageiro R$ 1.200, Avatim, Mary Kay, 4lsport, Pierweek, Coza, Andorinha).
-- Cada job vira uma campanha + 1 pagamento pendente em financas.
-- Também zera as linhas "pendente" dos resumos importados: agora o
-- "a receber" vem dos jobs, um por um (senão contaria duas vezes).
-- Pode rodar de novo: não duplica.
-- ============================================================================

do $$
declare
  j record;
  novo_id bigint;
begin
  for j in select * from (values
    ('Avon | Iconic Colection', 'Avon', 'Entregue', 1, 340.00, '2026-05-10'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Nuvemshop', 'Nuvemshop', 'Entregue', 1, 600.00, '2026-06-19'::date, 'Importado do UGControl · formato: tiktok · etapa lá: Aguardando pagamento'),
    ('Cerave', 'Cerave', 'Entregue', 1, 353.60, '2026-06-21'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('EspaçoLaser', 'EspaçoLaser', 'Entregue', 1, 500.00, '2026-06-22'::date, 'Importado do UGControl · formato: UGC ads · etapa lá: Aguardando pagamento'),
    ('Kibon', 'Kibon', 'Entregue', 1, 512.50, '2026-06-24'::date, 'Importado do UGControl · formato: Reels · etapa lá: Aguardando pagamento'),
    ('Hellmans - molho pra chuchar', 'Hellmans', 'Entregue', 1, 500.00, '2026-06-30'::date, 'Importado do UGControl · formato: Tiktok · etapa lá: Aguardando pagamento'),
    ('Creator Ads', 'Creator Ads', 'Aprovado', 1, 240.00, '2026-06-25'::date, 'Importado do UGControl · formato: reels · etapa lá: Para postar'),
    ('creator ads', 'creator ads', 'Entregue', 1, 240.00, '2026-07-04'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Don Cream', 'Don Cream', 'Entregue', 1, 600.00, '2026-08-14'::date, 'Importado do UGControl · formato: ugc ads · etapa lá: Aguardando pagamento'),
    ('Pantene - serum bambu', 'Pantene', 'Entregue', 1, 412.50, '2026-08-14'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Fashion Up', 'Fashion Up', 'Entregue', 1, 1000.00, '2026-08-21'::date, 'Importado do UGControl · formato: ug ads · etapa lá: Aguardando pagamento'),
    ('Melhor Seguro', 'Melhor Seguro', 'Entregue', 1, 3500.00, '2026-08-21'::date, 'Importado do UGControl · formato: ugc ads · etapa lá: Aguardando pagamento'),
    ('Fyhe', 'Fyhe', 'Entregue', 1, 900.00, '2026-09-02'::date, 'Importado do UGControl · formato: ugc ads · etapa lá: Aguardando pagamento'),
    ('Loreal WOW', 'Loreal WOW', 'Entregue', 1, 300.00, '2026-09-06'::date, 'Importado do UGControl · formato: Reels · etapa lá: Aguardando pagamento'),
    ('Passageiro de Primeira', 'Passageiro de Primeira', 'Entregue', 1, 500.00, '2026-09-11'::date, 'Importado do UGControl · formato: ugc ads · etapa lá: Aguardando pagamento'),
    ('Mercado Livre - Basic', 'Mercado Livre', 'Entregue', 1, 540.00, '2026-09-15'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('QDB - The Sophia Sinot Effect', 'QDB', 'Entregue', 1, 581.00, '2026-09-24'::date, 'Importado do UGControl · formato: REELS · etapa lá: Aguardando pagamento'),
    ('QDB - Glazed Donut Lips', 'QDB', 'Entregue', 1, 613.12, '2026-09-24'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('MAGALU', 'MAGALU', 'Entregue', 1, 1500.00, '2026-09-28'::date, 'Importado do UGControl · formato: videomaker · etapa lá: Aguardando pagamento'),
    ('ITAVEMA - TOYOTA INTER JAPAN', 'ITAVEMA', 'Entregue', 1, 1210.00, '2026-09-30'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Tostitos', 'Tostitos', 'Entregue', 1, 450.00, '2026-10-01'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Pierre (1)', 'Pierre', 'Aprovação', 1, 1000.00, '2026-10-02'::date, 'Importado do UGControl · formato: Reels · etapa lá: Aguardando Aprovação'),
    ('Pierre', 'Pierre', 'Entregue', 1, 600.00, '2026-10-02'::date, 'Importado do UGControl · formato: ugc ads · etapa lá: Aguardando pagamento'),
    ('Boticário', 'Boticário', 'Entregue', 1, 606.41, '2026-10-05'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Chico Rei', 'Chico Rei', 'Entregue', 1, 650.00, '2026-10-26'::date, 'Importado do UGControl · formato: UGC ADS · etapa lá: Aguardando pagamento'),
    ('Sam`s Club', 'Sam`s Club', 'Entregue', 1, 1300.00, '2026-10-28'::date, 'Importado do UGControl · formato: ugc · etapa lá: Aguardando pagamento'),
    ('Cerave', 'Cerave', 'Entregue', 1, 489.99, '2026-11-03'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Centro Universitário Unigrande', 'Centro Universitário Unigrande', 'Entregue', 1, 650.00, '2026-11-09'::date, 'Importado do UGControl · formato: UGC ADS · etapa lá: Aguardando pagamento'),
    ('Batavo', 'Batavo', 'Entregue', 1, 477.40, '2026-11-10'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento'),
    ('Citamobbi', 'Citamobbi', 'Briefing', 1, 1100.00, '2026-11-11'::date, 'Importado do UGControl · formato: UGC ADS · etapa lá: Aguardando Produto'),
    ('Gilette Venus', 'Gilette Venus', 'Gravação', 1, 452.00, '2026-11-18'::date, 'Importado do UGControl · formato: REELS · etapa lá: Em Produção'),
    ('Parmalat Natural Seleto', 'Parmalat Natural Seleto', 'Entregue', 1, 211.75, '2026-11-18'::date, 'Importado do UGControl · formato: Reels · etapa lá: Aguardando pagamento'),
    ('Feelin', 'Feelin', 'Gravação', 1, 400.00, null::date, 'Importado do UGControl · formato: UGC ADS · etapa lá: Em Produção'),
    ('Sensodyne - 2 entregas', 'Sensodyne', 'Entregue', 2, 500.00, '2026-11-18'::date, 'Importado do UGControl · formato: tiktok · etapa lá: Aguardando pagamento · sem data de pagamento lá (coloquei 18/11/26)'),
    ('Loreal', 'Loreal', 'Entregue', 1, 840.00, '2026-11-18'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento · sem data de pagamento lá (coloquei 18/11/26)'),
    ('Eucerin', 'Eucerin', 'Entregue', 1, 780.00, '2026-11-18'::date, 'Importado do UGControl · formato: reels · etapa lá: Aguardando pagamento · sem data de pagamento lá (coloquei 18/11/26)'),
    ('PicPay', 'PicPay', 'Entregue', 1, 840.00, '2026-11-18'::date, 'Importado do UGControl · formato: Reels · etapa lá: Aguardando pagamento · sem data de pagamento lá (coloquei 18/11/26)')
  ) as t(campanha, cliente, status, qtd, valor, venc, obs)
  loop
    if exists (select 1 from campanhas c where c.campanha = j.campanha and c.valor = j.valor
               and c.obs like 'Importado do UGControl%') then
      continue;
    end if;

    insert into campanhas (campanha, cliente, tipo, status, qtd, valor, obs, ativa)
    values (j.campanha, j.cliente, 'Job UGC', j.status, j.qtd, j.valor, j.obs, j.status <> 'Entregue')
    returning id into novo_id;

    if j.venc is not null then
      insert into financas (ambito, tipo, descricao, categoria, valor, data, vencimento, status, campanha_id)
      values ('empresa', 'entrada', j.campanha || ' · ' || j.cliente, 'Job UGC', j.valor, j.venc, j.venc, 'pendente', novo_id);
    end if;
  end loop;
end $$;

update financas
   set valor = 0,
       obs = coalesce(obs || ' · ', '') || 'zerado em 18/11/26: o a receber agora vem dos jobs importados do UGControl',
       atualizado_em = now()
 where categoria = 'Resumo (importado)' and status = 'pendente' and valor > 0;
