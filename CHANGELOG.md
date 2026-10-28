# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.0.14

- No fim da instalação e da atualização, um aviso claro: feche e abra o terminal para carregar o zsh e o visual.
- O Terminal.app mantém o tamanho de fonte de cada um; o workdeck troca só a fonte e as cores.

## v1.0.13

- O zsh do workdeck agora é o oh-my-zsh com o tema robbyrussell e o zinit com sugestões, cores e mais Tab, instalado por padrão.
- Quem já tem oh-my-zsh, zinit, Starship ou Powerlevel10k continua como está.

## v1.0.12

- O zsh do workdeck ganha um prompt no estilo do oh-my-zsh: ➜, a pasta e o git:(branch).
- O work update que liga o zsh do workdeck já termina num shell novo.

## v1.0.11

- Quando o zsh do workdeck é ligado, a instalação e a atualização avisam que ele só vale num shell novo.

## v1.0.10

- O work update faz as perguntas novas que você ainda não respondeu (zsh, visual dos terminais), sem precisar de work install.

## v1.0.9

- A instalação oferece o zsh do workdeck: sugestões, cores nos comandos e mais Tab, sem oh-my-zsh.
- No Linux sem zsh, instala o zsh e pergunta antes de trocar o shell padrão.

## v1.0.8

- O workdeck passa a ser só para macOS e Linux; sai a documentação do Windows.

## v1.0.7

- Uma pergunta só aplica o visual nos terminais encontrados: Terminal.app e kitty no Mac, GNOME Terminal e kitty no Linux.
- As cores aplicadas seguem o tema escolhido (--theme), não só o padrão.
- No Linux, o kitty recebe o tema sem os atalhos cmd, que lá roubariam a tecla Super.

## v1.0.6

- No Terminal.app, a instalação oferece aplicar a fonte e as cores do workdeck no perfil; some a borda preta em volta.
- O terminal do painel espera você se conectar para ficar com 8 linhas.
- work uninstall devolve a fonte e as cores que o perfil tinha.

## v1.0.5

- A instalação numa linha termina num shell novo: é só digitar work, sem source.

## v1.0.4

- A instalação baixa a fonte JetBrains Mono para a sua pasta de fontes, sem brew.
- A aba da janela atual não fica mais sublinhada.
- O terminal do painel abre com 8 linhas em qualquer tamanho de janela.
- A verificação de versão nova volta a ser uma vez por dia; work update atualiza na hora.

## v1.0.3

- Depois de atualizar pelo `work`, a sessão já abre com a versão nova.

## v1.0.2

- A aba da janela atual fica sem fundo: só o número em destaque.
- A tela de atualização mostra a versão, o que mudou e as etapas com ✓.
- A verificação de versão nova roda de hora em hora, e o painel avisa sozinho.

## v1.0.1

- Instalação numa linha, sem clonar: curl … instalar.sh | bash.
- `work install` roda a instalação de novo com opções (--theme, --terminal).
- O fundo da tela fica na cor do tema em qualquer terminal, não só no kitty.
- O terminal do painel abre com 8 linhas no tamanho real da janela.
- Corrige o erro "missing or unsuitable terminal: xterm-kitty".
- `work uninstall --all` apaga também a cópia do código.

## v1.0.0

- `work add <caminho>` acrescenta um projeto; fechar a janela tira ele do work.
- O painel abre como janela 1, com o logo, o guia do dia a dia e os projetos.
- `Ctrl+b h` abre o menu com tudo: projetos, IA, revisar, dividir a tela.
- `ai` abre a IA ao lado; `work review` pede a ela um self code review antes do commit.
- `Shift`+setas trocam de janela e de painel; `Ctrl+b Enter` divide a tela.
- `work update` avisa e atualiza quando sai uma versão nova.
