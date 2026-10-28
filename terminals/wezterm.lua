-- workdeck no WezTerm: tema, fonte e atalhos cmd traduzidos para o tmux.
-- Cole dentro da sua config, em ~/.wezterm.lua, ou use como ponto de partida.
-- \x02 é o Ctrl+b; o caractere depois dele é a tecla do workdeck.
-- No Linux, tire a parte de keys: lá o tmux já recebe tudo.

local wezterm = require 'wezterm'
local act = wezterm.action

local function tmux(tecla)
  return act.SendString('\x02' .. tecla)
end

return {
  color_scheme = 'Catppuccin Mocha',
  font = wezterm.font_with_fallback { 'JetBrains Mono', 'Menlo' },
  font_size = 13.0,
  line_height = 1.1,
  window_padding = { left = 8, right = 8, top = 8, bottom = 8 },
  hide_tab_bar_if_only_one_tab = true,
  send_composed_key_when_left_alt_is_pressed = false,

  keys = {
    { key = 'h', mods = 'CMD', action = tmux('h') },
    { key = 'Enter', mods = 'CMD', action = tmux('\r') },
    { key = 't', mods = 'CMD', action = tmux('c') },
    { key = '1', mods = 'CMD', action = tmux('1') },
    { key = '2', mods = 'CMD', action = tmux('2') },
    { key = '3', mods = 'CMD', action = tmux('3') },
    { key = '4', mods = 'CMD', action = tmux('4') },
    { key = '5', mods = 'CMD', action = tmux('5') },
    { key = '6', mods = 'CMD', action = tmux('6') },
    { key = '7', mods = 'CMD', action = tmux('7') },
    { key = '8', mods = 'CMD', action = tmux('8') },
    { key = '9', mods = 'CMD', action = tmux('9') },
    { key = '[', mods = 'CMD', action = tmux('p') },
    { key = ']', mods = 'CMD', action = tmux('n') },
    { key = 'd', mods = 'CMD', action = tmux('v') },
    { key = 'd', mods = 'CMD|SHIFT', action = tmux('-') },
    { key = 'Enter', mods = 'CMD|SHIFT', action = tmux('z') },
    { key = 'w', mods = 'CMD|SHIFT', action = tmux('x') },
    { key = 'r', mods = 'CMD|SHIFT', action = tmux(',') },
    { key = 'e', mods = 'CMD|SHIFT', action = tmux('d') },
  },
}
