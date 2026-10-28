# Segurança

## Como relatar

Se você encontrou uma falha de segurança, **não abra uma issue pública**. Use o
[relato privado de vulnerabilidade](https://github.com/thiagofeliperibeiro/workdeck/security/advisories/new)
do GitHub, com os passos para reproduzir e o impacto que você enxerga.

A resposta vem assim que possível, e a correção sai numa versão nova, com a
falha descrita no `CHANGELOG.md` depois de publicada.

## O que o instalador faz

A instalação recomendada é `curl … | bash`. Para ler o script antes:

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh -o instalar.sh
less instalar.sh && bash instalar.sh
```

- **Onde escreve:** só dentro do seu HOME, e nos seus arquivos
  (`.zshrc`, `.tmux.conf`, `kitty.conf`) apenas entre os marcadores
  `# >>> workdeck >>>`.
- **Antes de escrever:** guarda uma cópia de cada arquivo em
  `~/.config/workdeck/.backups/` e anota tudo num manifesto, que o
  `uninstall.sh` usa para desfazer.
- **Quando pede senha:** só para instalar o tmux pelo gerenciador de pacotes
  do Linux (`sudo`) e, se você aceitar, para trocar o shell padrão (`chsh`). O
  kitty e a fonte são instalados sem sudo.
- **O que baixa:** o próprio workdeck do GitHub, o kitty pelo instalador
  oficial, a fonte JetBrains Mono das releases oficiais e, se você aceitar, o
  oh-my-zsh e o zinit dos repositórios deles.
- **O que não faz:** não envia dados para lugar nenhum, não guarda tokens e não
  roda nada em segundo plano além da checagem de versão nova, uma vez por dia,
  com `git fetch`.

## Painéis e integrações

Painéis são programas seus, rodados a cada ciclo do painel. Não ponha tokens
neles: leia de um arquivo em `~/.config/workdeck/` (veja
[docs/paineis.md](docs/paineis.md)). As integrações (BMAD, Spec Kit, ai-memory)
são de terceiros; o workdeck só mostra como instalá-las.
