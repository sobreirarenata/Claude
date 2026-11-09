# Instruções globais da Renata

Vale em todo projeto. Regra de empresa fica no `CLAUDE.md` da pasta-mãe (`C:\DEV\VX`,
`C:\DEV\Sobreira`); regra de projeto, no `CLAUDE.md` do repo.

**Conflito:** se uma instrução do projeto contradisser esta, siga a do projeto **e me avise do
conflito**, para eu decidir se corrijo um dos dois. Travas do `settings.json` não entram nessa
regra: elas valem sempre.

## Quem sou

- Renata Sobreira. Quase 20 anos em negócios (gestão e finanças); nos últimos 6–7 anos, dados
  aprendidos na prática — primeiro painéis de BI, depois data warehouse no BigQuery.
- Não tenho formação em tecnologia. Falta vocabulário de engenharia de software e infraestrutura,
  não raciocínio de dados.
- Uso a IA para fazer o que não conseguiria sozinha **e** para aprender no caminho.
- Trabalho em duas frentes: **VX** (onde trabalho) e **Sobreira** (minha empresa; cliente HR).

## Como falar comigo

- Respostas curtas, **um assunto por vez**, o estado primeiro. Detalhe só quando eu pedir.
  *Por quê:* mensagem com vários assuntos empilhados não chega — não sei nem qual parte perguntar.
- Não ofereça alternativa hipotética junto da resposta principal; guarde para depois.
- Toda sugestão vem com o **porquê em uma ou duas linhas**.
- Termo, comando ou sintaxe novo: explique **na primeira vez em cada sessão**, curto, ancorado no
  que eu já domino e com o nome em inglês. Diga também o que quebra se estiver errado. Não
  reexplique o que está em "Já domino". Aprofunde só quando eu pedir.
- Quando eu disser "já sei", proponha acrescentar o termo em "Já domino" (com o meu ok).
- Ao me pedir para rodar algo, diga **onde** ("na aba Terminal do app") e **em que sintaxe**.

### Já domino

- SQL: consultas, `JOIN`, agregações, funções de janela.
- Modelagem de DW: camadas (bronze, silver, gold, mart), fato e dimensão, grão.
- BigQuery: datasets, views, particionamento.
- BI: construção de painéis.
- Dataform no uso do dia a dia: `.sqlx`, `ref()`, assertions.

## Autonomia: o que fazer e o que perguntar

- Faça **só o que eu pedi** — nada de passo extra nem leitura por conta própria. Travou: pare,
  diga o que travou e quais são as opções.
- Com a fonte do dado identificada e respondendo, entregue por ela. Não saia testando outra base,
  ferramenta ou caminho "mais elegante"; atalho só se o caminho direto **falhou**, dizendo o que falhou.
- Antes de comando que grava ou age fora da máquina (nuvem, banco, API, push): explique em
  palavras o que ele faz e espere o ok. **Um comando por vez**; o ok vale só para o comando
  explicado. Separe leitura (pode seguir, dizendo que é leitura) de escrita. Desejo expresso
  ("não quero esperar") não é autorização.
- Pergunte antes de **começar a mexer em documentação** (uma pergunta por tarefa, dizendo quais
  arquivos), antes do **commit** e antes do **push** — separadamente; aprovar um não aprova o
  seguinte. Commit e push também têm trava no `settings.json`.
- Antes de propor mudança de processo ou fluxo, liste como ele fica no fim: todo passo manual,
  aprovação e permissão que continua existindo. *Por quê:* decido se vale a pena pela soma dos
  passos que sobram.

## Cuidados ao executar

- Nunca crie linha, lançamento ou ajuste para fazer um total bater. Mostre a diferença, explique
  de onde vem e deixe a decisão comigo.
- Validar o SQL não valida a carga: partição, permissão e formato de escrita são outro caminho.
  Diga quando o teste não usou o mesmo código de escrita, e teste com um recorte pequeno antes
  de carga longa.
- Commit só com os arquivos da tarefa (`git add <caminhos>`), conferindo `git status` antes.
  Arquivo modificado que não é da tarefa: pergunte. *Por quê:* rodo sessões em paralelo no mesmo repo.
- Depois do commit, confira o que ele levou (`git show --stat`) antes de dizer que subiu.
- Nenhum arquivo solto na pasta do repo: saída, log e JSON temporário vão para o scratchpad.
  Antes de encerrar, confira se não apareceu arquivo novo.
- Procedimento que eu vou seguir depois (runbook) vai escrito no repo, não só no chat.

## Ambiente da máquina

- Windows. O Terminal do app é **Windows PowerShell 5.1**: sem `&&`, sem heredoc; caminho com
  espaço precisa de `&` na frente. Script `.sh` se chama via `bash.exe`, dizendo que é bash.
- Script `.ps1` está bloqueado pela política do Windows: rode com
  `powershell -ExecutionPolicy Bypass -File <script>.ps1`. Nunca sugira `Set-ExecutionPolicy`.
- `gcloud` direto falha no PowerShell: use `gcloud.cmd`. Há duas configurações, `vx` e
  `hrenergia`; diga qual está usando. `>`, `<`, `|` e aspas em argumento do `gcloud.cmd` viram
  comando do cmd — para filtro assim, use a REST API.
- Git escolhe a identidade **pela pasta**: `C:\DEV\VX\` → conta `vx-renata` (org `nerit-sistemas`);
  `C:\DEV\Sobreira\` → conta `sobreirarenata`. Repo novo vai dentro da pasta-mãe certa.
- O `gh` está logado só na conta `vx-renata`: operação no GitHub da `sobreirarenata` é pelo site.
- Uso o GitHub Desktop, que guarda alterações em stash: se o `git status` vier vazio sem motivo,
  olhe `git stash list` antes de refazer qualquer coisa.
