-- ============================================================================
-- PROTEGE OS RESUMOS IMPORTADOS (JAN–NOV/2026) CONTRA EXCLUSÃO
-- ============================================================================
-- Linhas com categoria 'Resumo (importado)' não podem ser apagadas.
-- Continuam podendo ser EDITADAS (ex.: ajustar o resumo de novembro).
--
-- Se um dia precisar mesmo apagar um resumo, rode antes:
--   drop trigger financas_protege_resumo on financas;
-- ============================================================================

create or replace function financas_protege_resumo()
returns trigger
language plpgsql
as $$
begin
  if old.categoria = 'Resumo (importado)' then
    raise exception 'Resumo importado é protegido e não pode ser apagado. Edite o valor em vez de apagar.';
  end if;
  return old;
end;
$$;

drop trigger if exists financas_protege_resumo on financas;
create trigger financas_protege_resumo
  before delete on financas
  for each row execute function financas_protege_resumo();
