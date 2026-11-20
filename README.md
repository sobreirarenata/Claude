# Configuração global do Claude Code

Fonte da verdade das instruções e travas que valem em **todo projeto** aberto no Claude Code
nesta máquina.

| Arquivo | O que é | Como chega ao Claude Code |
|---|---|---|
| `CLAUDE.md` | Instruções de comportamento (texto que o Claude lê e procura seguir) | `C:\Users\renat\.claude\CLAUDE.md` tem só uma linha que importa este arquivo |
| `settings.json` | Travas (o próprio Claude Code aplica, independe do Claude lembrar) | **Cópia** em `C:\Users\renat\.claude\settings.json` — mudou aqui, copiar de novo |
| `hooks/trava-drive.ps1` | Script da trava do Drive `H:\` (ver seção abaixo) | Chamado direto daqui pelo `settings.json`; não precisa copiar |

## Como as travas funcionam

- **Proibido (`deny`)**: o Claude Code bloqueia sem perguntar.
- **Pedir ok (`ask`)**: aparece a janelinha "Permitir?" e você decide, toda vez.
- Ordem: primeiro o proibido, depois o pedir ok, por último o liberado. Uma liberação de projeto
  ou um "permitir sempre" clicado numa janelinha **não** anula uma trava daqui.
- Valem em todos os modos de permissão, inclusive o automático. O proibido vale até no "bypass".
- Cada trava aparece duas vezes: uma para o **Bash** e outra para o **PowerShell** — a trava de
  um não cobre o outro.
- **Não é cofre**: a trava pega o jeito comum de escrever o comando. Um comando escrito de outra
  forma (ex.: `git -C pasta push`) pode passar. Por isso a regra também está em texto no `CLAUDE.md`.

## Liberado (sem janelinha)

Comandos do dia a dia, locais ou só de leitura. Sem esta lista, sessões no modo de permissão
**padrão** abrem janelinha para tudo. O proibido e o pedir ok continuam vencendo: `git add -A`
segue bloqueado mesmo com `git add` liberado (decidido em 17/11/2026).

| Comando | Por que está liberado |
|---|---|
| `git status`, `git diff`, `git log`, `git show`, `git branch` | Só leitura |
| `git add <arquivo>`, `git commit` | Local e reversível; coberto pelo ok do plano da tarefa |
| `git fetch`, `git pull` | Só trazem o que está no GitHub para a máquina; nada sai dela (decidido em 17/11/2026) |
| `gcloud ... list / describe`, `gcloud logging read`, `gcloud config list`, `gcloud auth print-access-token` | Só leitura no GCP |

Leitura **pela API** (`curl`, `Invoke-RestMethod`) **não** está liberada: algumas leituras usam o
mesmo formato das escritas (a leitura de log e o disparo do Dataform são ambos POST), então não dá
para separar com segurança.

No que pede ok, a janelinha **é** a aprovação: o Claude explica no chat e executa, sem perguntar
duas vezes.

## Proibido

| Comando | O que faz | Exemplo do risco |
|---|---|---|
| `git add -A`, `git add --all`, `git add .` | Põe **tudo** o que mudou na pasta no próximo commit | Levar trabalho de outra sessão em paralelo (HR, 06/10/2026) |
| `git commit -a` | Adiciona tudo e commita num comando só | Mesmo risco do `git add -A` |
| `git push --force`, `git push -f` | Sobrescreve o histórico no GitHub, apagando commits de lá | Apagar o histórico dos apps do Lovable |
| `git reset --hard` | Descarta sem volta tudo o que não foi commitado | Perder horas de edição |
| `git clean` | Apaga arquivos novos que ainda não estão no git | Apagar um rascunho não commitado |
| `Set-ExecutionPolicy` | Muda a regra de segurança do Windows para scripts | Afrouxar a proteção da máquina |

## Pedir ok

Só o que é **irreversível ou sai da máquina**. Mudança local e reversível (editar arquivo,
`git commit`, `git config`, mover arquivo, memória) não tem trava: entra no plano da tarefa, que
ela aprova uma vez — ver "Aprovação por risco" no `CLAUDE.md` (decidido em 12/11/2026).

**Git e GitHub**

| Comando | O que faz |
|---|---|
| `git push` | Envia os commits para o GitHub |
| `git merge`, `git rebase` | Juntam ou reescrevem histórico de branches |
| `gh pr create`, `gh pr merge` | Abrem e aprovam pull requests |
| `gh repo create` | Cria repositório no GitHub |

**Arquivos da máquina**

| Comando ou caminho | O que faz |
|---|---|
| `rm`, `Remove-Item` (e `del`) | Apagam arquivo ou pasta |
| Editar `~/.gitconfig*` | Identidade do git e regras de pasta |
| Editar `~/.ssh/` | Chaves de acesso ao GitHub |
| Editar `~/.claude/settings*.json` | As próprias travas — o Claude não as afrouxa sem o seu ok |
| Editar `~/.claude/CLAUDE.md` | A ligação com este repositório |

As memórias do Claude (`~/.claude/projects/.../memory`) ficam **livres**, guiadas pela regra em texto.

**Nuvem e dados**

| Comando | O que faz |
|---|---|
| `gcloud ... create / delete / update / deploy / execute` | Criam, apagam, alteram, publicam ou disparam algo no GCP |
| `gcloud ... add-iam-policy-binding / remove-iam-policy-binding / set-iam-policy` | Dão ou tiram permissão no GCP |
| `bq mk / rm / load / cp / update / insert` | Criam, apagam, carregam, copiam ou alteram tabelas no BigQuery |
| `bq query` | Roda SQL — pode ler ou alterar dados, por isso pergunta sempre |
| BigQuery pelo MCP: `execute_sql`, `cancel_job` | SQL que pode alterar dados; cancelar consulta em andamento |
| `curl`, `Invoke-RestMethod`, `Invoke-WebRequest` | Chamam APIs direto (ex.: disparar o Dataform). Perguntam também em leitura. |

O `gcloud` de leitura (`list`, `describe`, `logging read`) e a ferramenta `execute_sql_readonly`
do BigQuery seguem livres.

**Navegador e sites**

| Ferramenta | O que faz |
|---|---|
| `mcp__claude-in-chrome__navigate` | Abre um site no seu Chrome |
| `mcp__Claude_Browser__navigate`, `mcp__Claude_Browser__preview_start` | Abrem um site no navegador do app |
| `WebFetch` | Lê uma página da internet sem abrir janela |

Pergunta para **abrir** o site; clicar dentro de um site já liberado não pergunta de novo. Página
publicada pelo próprio Claude, que o app abre sozinho, não passa por estas ferramentas e não tem
trava (decidido em 18/11/2026).

**Instalar programa**

| Comando | O que faz |
|---|---|
| `npm install`, `pip install`, `winget` | Instalam programas e bibliotecas |

## Trava do Drive `H:\` (só leitura em 5 pastas)

Decidido em 20/11/2026, para a conferência semanal de pagamentos do HR. O Claude só pode **ler**
estas pastas, com as subpastas:

- `H:\Drives compartilhados\Administrativo\1 - GAR\Financeiro\Borderô pagamentos` (inclui GAR-Ipe)
- `H:\Drives compartilhados\Administrativo\2 - HR\Financeiro\Borderô pagamentos`
- `H:\Drives compartilhados\Administrativo\3 - GB Agro\Financeiro\Borderô pagamentos`
- `H:\Drives compartilhados\Administrativo\4 - DGB Ipe\Financeiro\Borderô pagamentos`
- `H:\Drives compartilhados\Administrativo\5 - BAR\Financeiro\Borderô pagamentos`

Duas camadas:

| Camada | O que faz |
|---|---|
| `deny` `Edit(//h/**)` | Bloqueia as ferramentas de editar e criar arquivo em todo o `H:\` |
| Hook `hooks/trava-drive.ps1` | Script que roda **antes** de cada leitura, busca, edição ou comando de terminal. Bloqueia: (1) qualquer caminho do `H:\` fora das 5 pastas; (2) editar ou criar arquivo no `H:\`; (3) comando de terminal que cite o `H:\` e mova, copie, renomeie, apague, crie ou grave algo (inclusive `>`) |

Limites (não é cofre):

- Comando montado de forma indireta (caminho dentro de variável, juntado em pedaços) pode passar.
  Por isso a regra também vai em texto na skill da conferência.
- Um script rodado pelo Claude é visto só pelo comando que o dispara, não pelo que faz por dentro:
  o código da conferência abre os arquivos apenas para leitura.
- Também bloqueia leitura com redirecionamento (`2>`) que cite o `H:\` — efeito colateral aceito.
- Cada ferramenta passa pelo script (~0,5 s a mais por ação).
- Mudou o nome de uma pasta: ajustar a lista `$liberadas` no script e esta seção.
- O hook passa a valer em **sessão nova** do Claude Code.

## Manutenção

- **Conexão MCP nova**: a trava do BigQuery cita o código interno da conexão de hoje
  (`mcp__16df193e-febc-476c-92b9-796765b017bd__...`). Se a conexão for refeita ou entrar outra
  (BigQuery da HR, Supabase), acrescentar as ferramentas de escrita dela em `ask`.
- **Linha `CLAUDE_CODE_USE_POWERSHELL_TOOL`** (em `env`): mantém a ferramenta de PowerShell ligada,
  porque certas travas do Bash podem desligá-la no Windows.
- O `settings.json` não aceita comentário nem vírgula sobrando no fim de lista — conferir antes de copiar.
- Sintaxe conferida na documentação oficial em 09/11/2026: <https://code.claude.com/docs/en/permissions>.
