# Adaptadores de terminal

**Você não precisa de nada aqui.** O workdeck funciona em qualquer terminal:
os atalhos são do tmux (`Ctrl+b`, `Shift`+setas, mouse).

Estes arquivos deixam o terminal com a cara do workdeck e, no Mac, trazem os
atalhos para o `cmd`:

- **Tema** Catppuccin Mocha, o mesmo da barra do tmux.
- **Fonte** JetBrains Mono, com espaçamento de linha um pouco maior.
- **Option como Alt** no Mac, para os atalhos diretos com Alt.
- **cmd** no Mac: `cmd+h` abre o menu, `cmd+enter` divide a tela, `cmd+1…9`
  vai para a janela, `cmd+d` / `cmd+shift+d` divide ao lado / embaixo,
  `cmd+shift+enter` dá zoom, `cmd+shift+w` fecha o painel.

| Terminal | Arquivo | Instalação |
|---|---|---|
| kitty | `kitty.conf` | `./install.sh --terminal kitty` |
| Ghostty | `ghostty.conf` | cole em `~/.config/ghostty/config` |
| WezTerm | `wezterm.lua` | cole em `~/.wezterm.lua` |
| Alacritty | `alacritty.toml` | cole em `~/.config/alacritty/alacritty.toml` |

Só o kitty é instalado automaticamente, porque é o único que o instalador sabe
editar sem risco de quebrar o resto do arquivo. Os outros são trechos para
colar. O Terminal.app não deixa mapear o `cmd` nem trocar a fonte por arquivo;
nele, use `Ctrl+b` e o mouse.

## A fonte

Os adaptadores pedem a JetBrains Mono. Sem ela, o terminal usa outra fonte
monoespaçada e tudo continua funcionando. Para instalar:

```bash
brew install --cask font-jetbrains-mono        # macOS
sudo apt install fonts-jetbrains-mono          # Debian e Ubuntu
sudo dnf install jetbrains-mono-fonts          # Fedora
```

Depois, feche e abra o terminal.

**Seu terminal não está na lista?** Ele serve para os atalhos `cmd` se tiver
como mapear uma tecla para enviar texto. Procure por "send text", "send string"
ou "send input" na documentação.
