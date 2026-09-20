// ============================================================================
// FUNÇÃO "O CARTEIRO": manda e-mails de prospecção pelo Resend
// ============================================================================
// Isso roda no servidor do Supabase, não no navegador. Por isso a chave
// secreta do Resend pode viver aqui dentro (como variável de ambiente,
// nunca escrita neste arquivo) sem risco de vazar pro site publicado.
//
// Quem pode chamar esta função: só a Fernanda, logada no admin, com o
// e-mail configurado abaixo em EMAIL_PERMITIDO.
// ============================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const EMAIL_PERMITIDO = "fespositoguimaraes@gmail.com";
const EMAIL_CONTATO = "fespositoguimaraes@gmail.com";
const MAX_DESTINATARIOS = 250;
const PAUSA_ENTRE_ENVIOS_MS = 200; // ~5 por segundo, ritmo seguro do Resend

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Troca {{nome}} e {{marca}} pelo valor de cada destinatário
function preencherModelo(texto: string, nome: string, marca: string) {
  return texto
    .replaceAll("{{nome}}", nome || "")
    .replaceAll("{{marca}}", marca || "");
}

function pausar(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

Deno.serve(async (req) => {
  // Navegadores mandam uma requisição "OPTIONS" antes da de verdade, pra checar permissão
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ------------------------------------------------------------------
    // 1. Confere se quem está chamando é a Fernanda, logada de verdade
    // ------------------------------------------------------------------
    const authHeader = req.headers.get("Authorization") || "";
    const token = authHeader.replace("Bearer ", "");
    if (!token) {
      return jsonResponse({ erro: "Não autorizado: faça login de novo." }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Cliente "de visitante", só pra confirmar quem é o dono do token
    const supabaseAuth = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await supabaseAuth.auth.getUser(token);

    if (userError || !userData?.user || userData.user.email !== EMAIL_PERMITIDO) {
      return jsonResponse({ erro: "Não autorizado: este e-mail não pode disparar." }, 403);
    }

    // Cliente "de confiança", que ignora as travas de RLS pra gravar o histórico
    const supabaseAdmin = createClient(supabaseUrl, serviceKey);

    // ------------------------------------------------------------------
    // 2. Lê o que veio do admin
    // ------------------------------------------------------------------
    const payload = await req.json();
    const destinatarios: Array<{ email: string; nome?: string; marca?: string }> =
      payload.destinatarios || [];
    const assunto: string = payload.assunto || "";
    const corpoHtml: string = payload.corpoHtml || "";
    const pularJaEnviados: boolean = !!payload.pularJaEnviados;

    if (!assunto.trim() || !corpoHtml.trim()) {
      return jsonResponse({ erro: "Faltou o assunto ou o texto do e-mail." }, 400);
    }
    if (!destinatarios.length) {
      return jsonResponse({ erro: "Nenhum destinatário foi enviado." }, 400);
    }
    if (destinatarios.length > MAX_DESTINATARIOS) {
      return jsonResponse(
        { erro: `No máximo ${MAX_DESTINATARIOS} destinatários por disparo. Você mandou ${destinatarios.length}.` },
        400
      );
    }

    // ------------------------------------------------------------------
    // 3. Tira duplicados de e-mail (agências que atendem 2 marcas, por exemplo)
    // ------------------------------------------------------------------
    const vistos = new Set<string>();
    const listaUnica = destinatarios.filter((d) => {
      const email = (d.email || "").trim().toLowerCase();
      if (!email || vistos.has(email)) return false;
      vistos.add(email);
      return true;
    });

    // ------------------------------------------------------------------
    // 4. Quem já pediu pra sair, nunca recebe
    // ------------------------------------------------------------------
    const { data: optouts } = await supabaseAdmin.from("email_optout").select("email");
    const emailsOptout = new Set((optouts || []).map((o: { email: string }) => o.email.toLowerCase()));

    // ------------------------------------------------------------------
    // 5. Se pedido, pula quem já recebeu ESTE MESMO assunto com sucesso
    // ------------------------------------------------------------------
    let emailsJaEnviados = new Set<string>();
    if (pularJaEnviados) {
      const { data: jaEnviados } = await supabaseAdmin
        .from("email_envios")
        .select("email")
        .eq("assunto", assunto)
        .eq("status", "ok");
      emailsJaEnviados = new Set((jaEnviados || []).map((e: { email: string }) => e.email.toLowerCase()));
    }

    let pulados = 0;
    const paraEnviar = listaUnica.filter((d) => {
      const email = d.email.trim().toLowerCase();
      if (emailsOptout.has(email)) { pulados++; return false; }
      if (emailsJaEnviados.has(email)) { pulados++; return false; }
      return true;
    });

    // ------------------------------------------------------------------
    // 6. Manda um por um, devagar, e registra cada resultado
    // ------------------------------------------------------------------
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      return jsonResponse(
        { erro: "A chave do Resend ainda não foi configurada no Supabase (RESEND_API_KEY)." },
        500
      );
    }
    const fromEmail = Deno.env.get("RESEND_FROM_EMAIL") || "onboarding@resend.dev";

    let enviados = 0;
    let falharam = 0;
    let cotaEsgotada = false;

    for (const destinatario of paraEnviar) {
      const nome = (destinatario.nome || "").split(" ")[0];
      const marca = destinatario.marca || "";
      const assuntoFinal = preencherModelo(assunto, nome, marca);
      const corpoFinal = preencherModelo(corpoHtml, nome, marca);

      try {
        const resposta = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${resendApiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: fromEmail,
            to: [destinatario.email],
            subject: assuntoFinal,
            html: corpoFinal,
            reply_to: EMAIL_CONTATO,
            headers: {
              "List-Unsubscribe": `<mailto:${EMAIL_CONTATO}?subject=SAIR>`,
            },
          }),
        });

        const corpoResposta = await resposta.json().catch(() => ({}));

        // Cota diária do Resend acabou: para tudo na hora, sem tentar o resto
        const nomeErro = (corpoResposta?.name || "").toLowerCase();
        if (resposta.status === 429 && nomeErro.includes("quota")) {
          cotaEsgotada = true;
          break;
        }

        if (!resposta.ok) {
          falharam++;
          await supabaseAdmin.from("email_envios").insert({
            email: destinatario.email,
            assunto: assuntoFinal,
            status: "erro",
            erro: corpoResposta?.message || `Erro HTTP ${resposta.status}`,
            resend_id: null,
          });
        } else {
          enviados++;
          await supabaseAdmin.from("email_envios").insert({
            email: destinatario.email,
            assunto: assuntoFinal,
            status: "ok",
            erro: null,
            resend_id: corpoResposta?.id || null,
          });
        }
      } catch (err) {
        falharam++;
        await supabaseAdmin.from("email_envios").insert({
          email: destinatario.email,
          assunto: assuntoFinal,
          status: "erro",
          erro: String(err),
          resend_id: null,
        });
      }

      await pausar(PAUSA_ENTRE_ENVIOS_MS);
    }

    // ------------------------------------------------------------------
    // 7. Marca no cadastro de marcas quem recebeu com sucesso
    // ------------------------------------------------------------------
    const emailsEnviadosComSucesso = paraEnviar
      .slice(0, enviados)
      .map((d) => d.email);
    if (emailsEnviadosComSucesso.length) {
      await supabaseAdmin
        .from("marcas")
        .update({ prospeccao_enviada_em: new Date().toISOString() })
        .in("email", emailsEnviadosComSucesso);
    }

    return jsonResponse({
      enviados,
      falharam,
      pulados,
      cotaEsgotada,
      faltaram: paraEnviar.length - enviados - falharam,
    });
  } catch (err) {
    console.error(err);
    return jsonResponse({ erro: "Erro inesperado no carteiro: " + String(err) }, 500);
  }
});
