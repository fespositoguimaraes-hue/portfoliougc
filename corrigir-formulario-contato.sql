-- ============================================================================
-- CORREÇÃO: o formulário "Bora criar juntos" não estava salvando no banco
-- ============================================================================
-- Motivo: a tabela "marcas" tem uma proteção (RLS) que bloqueava qualquer
-- gravação de visitante anônimo do site. Só quem está logada no admin
-- conseguia gravar. Essa política libera SÓ a criação de novos registros
-- pra visitantes (não libera leitura, edição nem exclusão: isso continua
-- só pra você, logada).
--
-- Onde rodar: painel do Supabase > seu projeto > SQL Editor > New query
-- Cole isto e clique em "Run".
-- ============================================================================

drop policy if exists "visitante pode cadastrar via formulario" on marcas;
create policy "visitante pode cadastrar via formulario"
  on marcas for insert
  to anon
  with check (true);

-- ============================================================================
-- FIM. Depois de rodar, me avisa que eu testo e confirmo.
-- ============================================================================
