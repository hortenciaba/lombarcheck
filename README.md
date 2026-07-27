# Lombar Check — guia de configuração e publicação

Este pacote contém o app pronto, o ícone em todos os tamanhos exigidos pelas
lojas, e a estrutura para (1) instalar como app hoje mesmo, (2) ativar login e
banco de dados reais, e (3) publicar nas lojas quando você estiver pronto.

## O que está aqui

```
index.html              → o app inteiro (interface + lógica)
manifest.json            → metadados do PWA (nome, ícone, cor)
sw.js                     → service worker (funciona offline / instalável)
icons/                    → ícones já gerados em todos os tamanhos
supabase-schema.sql       → script para criar o banco de dados com segurança
package.json              → dependências para empacotar com Capacitor
capacitor.config.json     → configuração para gerar os projetos iOS/Android
```

---

## Passo 1 — Ativar login e banco de dados reais (Supabase)

Sem isso, o app funciona sozinho no navegador, sem login, salvando só
localmente. Para ter contas de verdade e dados protegidos:

1. Crie uma conta gratuita em **https://supabase.com** (não pede cartão)
2. Clique em "New Project", dê um nome e escolha uma região (ex.: São Paulo)
3. Espere ~2 minutos o projeto ser criado
4. Vá em **SQL Editor** → cole o conteúdo de `supabase-schema.sql` → **Run**
5. Vá em **Project Settings → API** e copie:
   - a **Project URL**
   - a chave **anon public**
6. Abra `index.html`, procure por:
   ```js
   const SUPABASE_URL = '';
   const SUPABASE_ANON_KEY = '';
   ```
   e cole os dois valores entre as aspas.

Pronto — a partir daí, a tela de login/cadastro passa a funcionar de verdade:
cada fisioterapeuta cria sua própria conta (e-mail + senha), e só enxerga os
próprios pacientes (isso é garantido pelo banco de dados, não só pelo app —
veja os comentários de segurança dentro do `supabase-schema.sql`).

Por padrão o Supabase exige confirmação de e-mail no cadastro. Se quiser
desativar isso durante os testes: **Authentication → Providers → Email →
desmarque "Confirm email"**.

---

## Passo 2 — Testar como app instalável (hoje, sem loja nenhuma)

Um PWA (Progressive Web App) só é "instalável" quando servido por HTTPS — não
funciona abrindo o `index.html` direto do computador. O jeito mais rápido de
testar:

1. Acesse **https://app.netlify.com/drop**
2. Arraste a pasta inteira (todos os arquivos deste pacote) para lá
3. Você recebe um link `https://algo.netlify.app`
4. Abra esse link no celular:
   - **Android (Chrome):** aparece um banner "Adicionar à tela inicial", ou
     use o menu ⋮ → "Instalar app"
   - **iPhone (Safari):** toque em Compartilhar → "Adicionar à Tela de
     Início"

O app passa a abrir em tela cheia, com ícone próprio, como um app nativo —
mesmo sem passar pela App Store/Play Store. Para muitas clínicas isso já é
suficiente; a loja só é necessária se você quiser vender/distribuir
publicamente com descoberta via busca nas lojas.

---

## Passo 3 — Publicar de verdade na App Store e Play Store

Aqui entram as partes que só você (ou alguém contratado) pode fazer, porque
exigem contas pessoais/empresariais e um Mac:

### O que você precisa providenciar
| Item | Custo | Observação |
|---|---|---|
| Conta Apple Developer Program | US$ 99/ano | Necessária para publicar no iOS, mesmo em teste |
| Conta Google Play Console | US$ 25 (única vez) | Necessária para publicar no Android |
| Um Mac com Xcode instalado | — | Obrigatório para gerar o build iOS (não existe alternativa) |
| Política de Privacidade publicada (URL pública) | — | Ambas as lojas exigem, ainda mais por lidar com dados de saúde |

### Como gerar os projetos nativos (Capacitor)
Com Node.js instalado na sua máquina:

```bash
npm install
npx cap add ios
npx cap add android
npx cap sync
```

Isso cria as pastas `ios/` e `android/` com projetos nativos completos, já
usando os ícones deste pacote. Antes de rodar, edite o `appId` em
`capacitor.config.json` (hoje está como `com.seudominio.lombarcheck` —
troque `seudominio` pelo domínio da sua clínica/empresa, é o identificador
único do app nas lojas e não pode ser alterado depois de publicado).

- **iOS:** `npx cap open ios` abre no Xcode → Product → Archive → enviar para
  a App Store Connect
- **Android:** `npx cap open android` abre no Android Studio → Build → Generate
  Signed Bundle → enviar para o Play Console

### Itens que as lojas vão pedir na submissão
- Capturas de tela do app (várias resoluções)
- Descrição, categoria (Saúde e Fitness / Medical)
- Política de privacidade (obrigatória para apps de saúde)
- Justificativa de uso de dados sensíveis (a Apple pergunta explicitamente
  sobre dados de saúde durante a revisão)
- Prazo de revisão: normalmente 1–3 dias (Apple), poucas horas a 1–2 dias
  (Google)

---

## O que eu (Claude) fiz e o que ficou de fora

**Feito:** ícone em todos os tamanhos, app funcional completo, PWA
instalável, tela de login/cadastro, arquitetura de banco de dados com
segurança por usuário (linha a linha), script SQL pronto para rodar.

**Fora do meu alcance:** criar as contas Apple/Google em seu nome, gerar e
assinar o build iOS (exige Mac físico), submeter para revisão, hospedar o
backend continuamente (o Supabase resolve isso — é hospedado por eles, não
por mim), e redigir a política de privacidade específica da sua clínica
(posso ajudar a redigir um rascunho se você quiser).
