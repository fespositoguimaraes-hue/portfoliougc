// ============================================================================
// FUNÇÃO "AVISAR NOVO LEAD": manda um e-mail pra Fernanda quando alguém
// preenche o formulário de contato do portfólio ("Bora criar juntos")
// ============================================================================
// Diferente da função enviar-emails (essa é pra prospecção em massa, só a
// Fernanda pode chamar), esta função é pública: qualquer visitante do site
// pode chamar, porque é o próprio formulário de contato que dispara.
//
// Como o e-mail sempre vai pra caixa da própria Fernanda, funciona mesmo
// sem domínio verificado no Resend (essa é justamente a única situação em
// que o remetente de teste do Resend consegue entregar pra qualquer um).

import { createClient } from "jsr:@supabase/supabase-js@2";

const EMAIL_DESTINO = "fespositoguimaraes@gmail.com";

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

function escapeHtml(texto: string) {
  return texto
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();
    const nome = String(payload.nome || "").trim().slice(0, 200);
    const email = String(payload.email || "").trim().slice(0, 200);
    const mensagem = String(payload.mensagem || "").trim().slice(0, 5000);

    if (!nome || !mensagem) {
      return jsonResponse({ erro: "Faltou nome ou mensagem." }, 400);
    }

    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      // Não trava o formulário do visitante por causa disso: só não manda o aviso.
      return jsonResponse({ avisoEnviado: false, motivo: "RESEND_API_KEY não configurada" });
    }
    const fromEmail = Deno.env.get("RESEND_FROM_EMAIL") || "onboarding@resend.dev";

    const corpoHtml = `
      <div style="max-width:560px; margin:0 auto; background:#ffffff; color:#222222; font-family:-apple-system,sans-serif; padding:24px; line-height:1.6; font-size:14px;">
        <h2 style="margin:0 0 16px;">Novo contato pelo portfólio</h2>
        <p><strong>Nome:</strong> ${escapeHtml(nome)}</p>
        <p><strong>E-mail:</strong> ${escapeHtml(email || "não informado")}</p>
        <p><strong>Mensagem:</strong></p>
        <p style="white-space:pre-line; background:#f6f3ee; padding:12px; border-radius:8px;">${escapeHtml(mensagem)}</p>
      </div>
    `;

    const resposta = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: fromEmail,
        to: [EMAIL_DESTINO],
        subject: `Novo contato: ${nome}`,
        html: corpoHtml,
        reply_to: email || undefined,
      }),
    });

    if (!resposta.ok) {
      const corpoErro = await resposta.text().catch(() => "");
      console.error("Falha ao enviar aviso de lead:", corpoErro);
      return jsonResponse({ avisoEnviado: false, motivo: "Resend recusou o envio" });
    }

    return jsonResponse({ avisoEnviado: true });
  } catch (err) {
    console.error(err);
    return jsonResponse({ avisoEnviado: false, motivo: String(err) }, 200);
  }
});
