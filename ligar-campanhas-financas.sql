-- ============================================================================
-- LIGA A ABA "CAMPANHAS" COM A ABA "FINANÇAS"
-- ============================================================================
-- Cada campanha (job) passa a ter seus pagamentos lançados em Finanças.
-- Um pagamento = uma linha em financas com campanha_id apontando para o job.
--
-- Rode no Supabase > SQL Editor. Pode rodar mais de uma vez sem problema.
-- ============================================================================

-- Campanhas: dados do fechamento e nota fiscal
alter table campanhas add column if not exists data_fechamento date;
alter table campanhas add column if not exists nf text check (nf in ('emitida', 'nao_emitida'));
alter table campanhas add column if not exists nf_numero text;
alter table campanhas add column if not exists obs text;

-- Finanças: ligação com a campanha + datas de vencimento e de pagamento
--   vencimento = quando estava previsto cair
--   pago_em    = quando caiu de verdade (a coluna "data" passa a ser essa data)
alter table financas add column if not exists campanha_id bigint references campanhas (id) on delete set null;
alter table financas add column if not exists vencimento date;
alter table financas add column if not exists pago_em date;

create index if not exists financas_campanha_idx on financas (campanha_id);
