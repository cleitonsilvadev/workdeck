# Adaptadores de terminal

**Você não precisa de nada aqui.** Os atalhos do workdeck são `Alt`, e quem os
interpreta é o tmux — funcionam em qualquer terminal, em qualquer sistema.

Estes arquivos existem para um caso só: no macOS, `cmd` nunca chega ao tmux,
porque o sistema intercepta antes. Se você quer `cmd+1` em vez de `Alt+1`, o
terminal precisa traduzir. É isso que cada arquivo faz.

| Terminal | Arquivo | Instalação |
|---|---|---|
| kitty | `kitty.conf` | `./install.sh --terminal kitty` |
| WezTerm | `wezterm.lua` | copie o trecho para o seu `~/.wezterm.lua` |
| Alacritty | `alacritty.toml` | copie o trecho para o seu `~/.config/alacritty/alacritty.toml` |

Só o kitty é instalado automaticamente, porque é o único que o instalador sabe
editar sem risco de quebrar o resto do seu arquivo. Os outros são trechos para
colar — eles mudam de formato (Lua, TOML) e costumam conviver com configuração
que o instalador não deveria mexer.

**Linux e WSL:** aqui `Alt` chega ao tmux normalmente, então não há o que
adaptar. Use os atalhos padrão.

**Seu terminal não está na lista?** Ele serve se tiver como mapear uma tecla
para enviar texto arbitrário. Procure por "send text", "send string" ou
"send input" na documentação. GNOME Terminal e Konsole não têm esse recurso —
nesses, os atalhos em `Alt` são o caminho, e funcionam igual.
