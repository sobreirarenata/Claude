# Receitas do ambiente da máquina

Consulta sob demanda — não é lido em toda sessão. O resumo que vale sempre está no `CLAUDE.md`,
seção "Ambiente da máquina".

## gcloud

### Por que `gcloud.cmd`

A `ExecutionPolicy` do escopo `LocalMachine` está `Restricted` (provavelmente política da TI).
O `gcloud` é um `gcloud.ps1` e falha com `PSSecurityException / UnauthorizedAccess`. O
`gcloud.cmd` não passa pela política. Um alias num `profile.ps1` também não funcionaria.

- Nos comandos que a Renata roda no terminal dela: sempre `gcloud.cmd`.
- Nos comandos que o Claude roda pela ferramenta PowerShell, `gcloud` funciona (a sessão vem com
  `Process = Bypass`).
- O mesmo bloqueio atinge o `Activate.ps1` de venv Python: chame `.venv\Scripts\python.exe` direto.
- `gcloud.cmd` é um `.bat`: `>`, `<`, `|`, `&` e aspas internas no argumento são interpretados pelo
  cmd (escapar com `^` não funciona). Filtro assim vai pela REST API, com o token de
  `gcloud.cmd auth print-access-token --configuration=vx`.

### Python do SDK

Não há Python no sistema: `python` é o stub da Microsoft Store. Desde 24/09/2026 a variável de
**usuário** `CLOUDSDK_PYTHON` aponta para
`C:\Users\renat\AppData\Local\Google\Cloud SDK\google-cloud-sdk\platform\bundledpython\python.exe`.
Se sumir, exportar antes de qualquer comando. Para scripts Python, criar venv a partir desse binário.

### Duas contas, duas configurações

| Configuração | Conta | Projeto | Impersonation |
|---|---|---|---|
| `vx` | renata.sobreira@vx.med.br | vx-prd-pacs-bd179c3c86429934 | — |
| `hrenergia` | admin@hrenergia.com | hrenergia | claude-bq-leitor@hrenergia |

- Trocar (não precisa logar de novo): `gcloud.cmd config configurations activate vx` (ou `hrenergia`).
- A configuração ativa vale para a **máquina inteira**, inclusive os comandos do Claude. Erro de
  permissão inesperado: `gcloud.cmd config list` mostra qual está ativa.
- Se reaparecer uma configuração `default`, é instalação nova do SDK — foi apagada em 16/09/2026
  por misturar conta da hrenergia com projeto da VX.
- O MCP do BigQuery **não** depende disso (credencial própria). O `gcloud` só importa para
  infraestrutura: Scheduler, Cloud Run, IAM.

### Reautenticar (sessão expirada)

Reautenticação é frequente (política da organização). Dar o comando certo de primeira:

```powershell
gcloud.cmd auth login renata.sobreira@vx.med.br --force
```

- Sem `--force`, o gcloud tenta renovar em silêncio, cai no desafio de reautenticação e pede
  **senha no terminal** — ela não digita senha ali (o terminal é legível pelo assistente).
- Se insistir: `gcloud.cmd auth revoke <conta>` antes, depois o login.
- Navegador não abriu: `gcloud.cmd auth login --no-launch-browser` devolve um código de uso único;
  colar esse código no terminal é seguro.
- Conferir que a configuração certa está ativa antes de logar.

## Git

### Duas identidades, escolhidas pela pasta

| Pasta | Identidade | Conta GitHub | Apelido SSH |
|---|---|---|---|
| `C:\DEV\VX\` | renata.sobreira@vx.med.br | `vx-renata` (org `nerit-sistemas`) | `github-vx` |
| `C:\DEV\Sobreira\` (HR, HR-App, HR-App-infra, HR-Maquinas, Claude) | renata@sobreirainteligenciaanalitica.com | `sobreirarenata` | `github-hr` |

- Arquivos: `~/.gitconfig` (`includeIf gitdir/i:` por pasta-mãe), `~/.gitconfig-vx`,
  `~/.gitconfig-hr`, `~/.ssh/config` (apelidos com `IdentitiesOnly yes`), chaves
  `id_ed25519_vx` e `id_ed25519_hr`.
- Cada arquivo de identidade tem `url.insteadOf` que troca `git@github.com:` pelo apelido: clonar
  com a URL normal do GitHub funciona dentro da pasta certa.
- Pastas reunidas em `C:\DEV\Sobreira\` em 09/11/2026; antes eram regras soltas por pasta.
- **Atenção:** o `[user]` padrão do `~/.gitconfig` tem nome e e-mail da VX, então o `useConfigOnly`
  não protege: repo **fora** das duas pastas-mãe commita como VX sem avisar (foi assim que o
  HR-Maquinas fez 23 commits com o e-mail da VX). Tirar esse padrão é decisão pendente.
- Cliente novo não precisa de conta GitHub nova: uma conta para a VX, outra para todo o resto.
- O `gh` está logado só na `vx-renata`.

### GitHub Desktop guarda alterações em stash

Ao trocar de branch com alterações não commitadas, o GitHub Desktop **guarda tudo num stash
automático** (`!!GitHub_Desktop<nome-do-branch>`) e devolve o working tree limpo, sem avisar.
Aconteceu duas vezes em 28/08/2026 no vx-synapse; o trabalho estava íntegro no stash nas duas.

Se o `git status` vier limpo quando não deveria:
1. `git stash list` antes de qualquer outra coisa.
2. Conferir o conteúdo: `git stash show --stat` e um `grep` no `git stash show -p` por alguma
   marca do trabalho recente.
3. Só então `git stash pop` (com o working tree limpo, não sobrescreve nada).
4. `git reflog` confirma a troca de branch que causou.

Nunca reescrever o que sumiu sem checar o stash. Não confiar que um worktree criado numa sessão
continue existindo na seguinte: reconferir com `git worktree list`.
