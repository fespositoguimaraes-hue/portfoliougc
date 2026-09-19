// ============================================================================
// CONFIGURAÇÃO DO SUPABASE
// ============================================================================
// Este arquivo guarda as credenciais do seu banco de dados.
// É seguro porque só tem a chave PÚBLICA (anon), não a secreta.
//
// NUNCA adicione a chave secreta aqui!

const SUPABASE_URL = 'https://wimqztbttlcmjctledoo.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_IY8TwPK1YrjvkWBfPU1agA_7UfGRvNV';

// Depois que Supabase for carregado via CDN, isso vai estar disponível:
// window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)