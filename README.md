# Configuração global do Claude Code

Fonte da verdade das instruções e travas que valem em **todo projeto** aberto no Claude Code
nesta máquina.

| Arquivo | O que é | Como chega ao Claude Code |
|---|---|---|
| `CLAUDE.md` | Instruções de comportamento (texto que o Claude lê e procura seguir) | `C:\Users\renat\.claude\CLAUDE.md` tem só uma linha que importa este arquivo |
| `settings.json` | Travas (o próprio Claude Code aplica, independe do Claude lembrar) | **Cópia** em `C:\Users\renat\.claude\settings.json` — mudou aqui, copiar de novo |

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

**Git e GitHub**

| Comando | O que faz |
|---|---|
| `git commit` | Grava um pacote de mudanças no histórico local |
| `git push` | Envia os commits para o GitHub |
| `git merge`, `git rebase` | Juntam ou reescrevem histórico de branches |
| `git config` | Muda configuração do git (nome, e-mail, regras de pasta). Pergunta também quando só lê. |
| `gh pr create`, `gh pr merge` | Abrem e aprovam pull requests |
| `gh repo create` | Cria repositório no GitHub |

**Arquivos da máquina**

| Comando ou caminho | O que faz |
|---|---|
| `rm`, `Remove-Item` (e `del`) | Apagam arquivo ou pasta |
| `mv`, `Move-Item` | Movem ou renomeiam |
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

**Instalar programa**

| Comando | O que faz |
|---|---|
| `npm install`, `pip install`, `winget` | Instalam programas e bibliotecas |

## Manutenção

- **Conexão MCP nova**: a trava do BigQuery cita o código interno da conexão de hoje
  (`mcp__16df193e-febc-476c-92b9-796765b017bd__...`). Se a conexão for refeita ou entrar outra
  (BigQuery da HR, Supabase), acrescentar as ferramentas de escrita dela em `ask`.
- **Linha `CLAUDE_CODE_USE_POWERSHELL_TOOL`** (em `env`): mantém a ferramenta de PowerShell ligada,
  porque certas travas do Bash podem desligá-la no Windows.
- O `settings.json` não aceita comentário nem vírgula sobrando no fim de lista — conferir antes de copiar.
- Sintaxe conferida na documentação oficial em 09/11/2026: <https://code.claude.com/docs/en/permissions>.
