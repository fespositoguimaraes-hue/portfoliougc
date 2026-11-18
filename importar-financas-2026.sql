-- ============================================================================
-- IMPORTAR OS TOTAIS DE 2026 (JANEIRO A NOVEMBRO) DA PLATAFORMA DA EMPRESA
-- ============================================================================
-- Rode DEPOIS do criar-financas.sql, e só UMA vez (se rodar de novo, duplica).
--
-- Para cada mês entram até 3 lançamentos da EMPRESA, com a categoria
-- "Resumo (importado)":
--   • Recebido   -> entrada confirmada
--   • Pendente   -> entrada pendente (marque como recebida no admin quando cair)
--   • Despesas   -> saída confirmada
-- Esses resumos não contam como "jobs" na contagem do mês, e a nota fiscal
-- fica como "Não informado" (dá para editar cada um no admin).
--
-- Onde rodar: painel do Supabase > SQL Editor > New query > cole > Run.
-- ============================================================================

insert into financas (ambito, tipo, descricao, categoria, valor, data, status) values
  -- Janeiro
  ('empresa', 'entrada', 'Recebidos de janeiro (resumo)',   'Resumo (importado)',  8910.00, '2026-01-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de janeiro (resumo)',    'Resumo (importado)',  3410.00, '2026-01-15', 'confirmado'),
  -- Fevereiro
  ('empresa', 'entrada', 'Recebidos de fevereiro (resumo)', 'Resumo (importado)',  3050.00, '2026-02-15', 'confirmado'),
  ('empresa', 'entrada', 'Pendente de fevereiro (resumo)',  'Resumo (importado)',   977.40, '2026-02-15', 'pendente'),
  ('empresa', 'saida',   'Despesas de fevereiro (resumo)',  'Resumo (importado)',  4414.00, '2026-02-15', 'confirmado'),
  -- Março
  ('empresa', 'entrada', 'Recebidos de março (resumo)',     'Resumo (importado)',  9920.00, '2026-03-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de março (resumo)',      'Resumo (importado)',  6541.00, '2026-03-15', 'confirmado'),
  -- Abril
  ('empresa', 'entrada', 'Recebidos de abril (resumo)',     'Resumo (importado)',  9741.25, '2026-04-15', 'confirmado'),
  ('empresa', 'entrada', 'Pendente de abril (resumo)',      'Resumo (importado)',   350.00, '2026-04-15', 'pendente'),
  ('empresa', 'saida',   'Despesas de abril (resumo)',      'Resumo (importado)',  5923.02, '2026-04-15', 'confirmado'),
  -- Maio
  ('empresa', 'entrada', 'Recebidos de maio (resumo)',      'Resumo (importado)', 14697.30, '2026-05-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de maio (resumo)',       'Resumo (importado)', 11996.42, '2026-05-15', 'confirmado'),
  -- Junho
  ('empresa', 'entrada', 'Recebidos de junho (resumo)',     'Resumo (importado)', 15069.64, '2026-06-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de junho (resumo)',      'Resumo (importado)',  4245.00, '2026-06-15', 'confirmado'),
  -- Julho
  ('empresa', 'entrada', 'Recebidos de julho (resumo)',     'Resumo (importado)',  8873.40, '2026-07-15', 'confirmado'),
  ('empresa', 'entrada', 'Pendente de julho (resumo)',      'Resumo (importado)',  6640.00, '2026-07-15', 'pendente'),
  ('empresa', 'saida',   'Despesas de julho (resumo)',      'Resumo (importado)',  3976.00, '2026-07-15', 'confirmado'),
  -- Agosto
  ('empresa', 'entrada', 'Recebidos de agosto (resumo)',    'Resumo (importado)', 21179.11, '2026-08-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de agosto (resumo)',     'Resumo (importado)',  4189.00, '2026-08-15', 'confirmado'),
  -- Setembro
  ('empresa', 'entrada', 'Recebidos de setembro (resumo)',  'Resumo (importado)', 26154.02, '2026-09-15', 'confirmado'),
  ('empresa', 'saida',   'Despesas de setembro (resumo)',   'Resumo (importado)',  7708.95, '2026-09-15', 'confirmado'),
  -- Outubro
  ('empresa', 'entrada', 'Recebidos de outubro (resumo)',   'Resumo (importado)', 15814.50, '2026-10-15', 'confirmado'),
  ('empresa', 'entrada', 'Pendente de outubro (resumo)',    'Resumo (importado)',  4200.00, '2026-10-15', 'pendente'),
  ('empresa', 'saida',   'Despesas de outubro (resumo)',    'Resumo (importado)',  6876.55, '2026-10-15', 'confirmado'),
  -- Novembro (até agora)
  ('empresa', 'entrada', 'Recebidos de novembro (resumo)',  'Resumo (importado)', 10925.06, '2026-11-15', 'confirmado'),
  ('empresa', 'entrada', 'Pendente de novembro (resumo)',   'Resumo (importado)',  5950.00, '2026-11-15', 'pendente');
