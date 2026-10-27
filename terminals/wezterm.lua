-- workdeck — atalhos cmd traduzidos para o prefixo do tmux (Ctrl+b = \x02).
-- Cole dentro da sua config do WezTerm, em ~/.wezterm.lua.
-- No Linux e no Windows troque "CMD" por "ALT" — ou não use isto, já que lá
-- os atalhos em Alt do tmux funcionam direto.

local wezterm = require 'wezterm'
local act = wezterm.action

local function tmux(suffix)
  return act.SendString('\x02' .. suffix)
end

return {
  keys = {
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
    { key = 'd', mods = 'CMD', action = tmux('|') },
    { key = 'd', mods = 'CMD|SHIFT', action = tmux('-') },
    { key = 'Enter', mods = 'CMD|SHIFT', action = tmux('z') },
    { key = 'w', mods = 'CMD|SHIFT', action = tmux('x') },
    { key = 'r', mods = 'CMD|SHIFT', action = tmux(',') },
    { key = 'e', mods = 'CMD|SHIFT', action = tmux('d') },
  },
}
