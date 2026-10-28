# Contribuindo

Sugestões, bugs e pull requests são bem-vindos. Para algo grande, abra uma issue
antes para conversar sobre a ideia.

## Ambiente

```bash
git clone https://github.com/thiagofeliperibeiro/workdeck.git
cd workdeck
./install.sh
```

Rodar o `install.sh` de dentro do clone instala o que está nele, inclusive
commits que ainda não viraram versão: ele copia o clone para
`~/.local/share/workdeck`, que é de onde o `work` roda. Depois de mudar algo,
faça commit e rode o `./install.sh` de novo para usar a mudança.

## Estrutura

```
install.sh            o instalador, uma função por etapa e o main no fim
uninstall.sh          o desinstalador, guiado pelo manifesto da instalação
instalar.sh           a instalação numa linha (curl | bash)
lib/comum.sh          caminhos e funções usados por todos os scripts
bin/work              o único comando no PATH
bin/work-panel        o painel
bin/workdeck-agent    abre o agente de IA e o review num painel
config/               tmux.conf, o bloco do shell e os painéis que vêm prontos
themes/               as cores do kitty e do tmux de cada tema
terminals/            a configuração do kitty
integrations/         BMAD, Spec Kit, ai-memory e o exemplo para criar outras
docs/                 os guias
tests/                os testes e o lint
```

## Testes

```bash
./tests/run.sh          # todos
./tests/run.sh tema     # só os que têm "tema" no nome
./tests/lint.sh         # shellcheck em todos os scripts
```

Os testes precisam do `tmux` e do `git`, e o lint do `shellcheck`. Nada toca a
sua máquina: cada teste roda num HOME descartável, com o tmux num servidor
isolado, e testa a árvore de trabalho atual, inclusive o que ainda não foi
commitado.

Cada arquivo `tests/*.test.sh` tem funções `teste_*`. As funções de apoio
(`instalar`, `afirmar`, `afirmar_contem`, `esperar`, `abrir_work_num_terminal`…)
estão em `tests/lib.sh`. Corrigiu um bug? Escreva o teste que teria pegado.

O CI roda o lint e os testes no Ubuntu e no macOS a cada push e pull request.
No macOS os testes usam o `/bin/bash` do sistema, a versão 3.2, então evite
recursos de bash 4 ou mais novo, como `mapfile`, `declare -A` e `${var,,}`.

## Ao testar à mão

Nunca instale numa conta real para testar. Use um HOME descartável e o
`--no-reload`, senão o instalador recarrega o tmux da sessão que está aberta:

```bash
HOME="$(mktemp -d)" ./install.sh --yes --no-deps --no-reload
```

## Estilo

- Mensagens, documentação e nomes em português, sem primeira pessoa.
- Scripts em bash, com `set -euo pipefail` e funções pequenas.
- Tudo o que o instalador escreve fica entre os marcadores `# >>> workdeck >>>`
  e tem como ser desfeito pelo `uninstall.sh`.
- Uma mudança que o usuário percebe ganha uma linha no `CHANGELOG.md`.
