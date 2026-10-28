# Integrações

Nada aqui é instalado por padrão. Cada integração é uma peça de terceiros que
você pode querer ou não. Na primeira instalação, o `install.sh` lista as que
existem aqui e pergunta quais você usa; depois disso, só mexe nelas quando você
pede:

```bash
./install.sh --with ai-memory          # uma
./install.sh --with ai-memory,mcp-git  # várias
./install.sh --list-integrations       # ver o que existe
```

Cada arquivo `<nome>.sh` aqui é um script com três funções: `descrever`,
`verificar` e `instalar`. O instalador chama as duas primeiras antes de
perguntar qualquer coisa, e a terceira só depois de você confirmar.

Uma quarta, `usar`, é opcional: explica como deixar a integração funcionando
com a IA (o que pôr no `CLAUDE.md`, por exemplo). O instalador a mostra depois
de `instalar` e também quando a integração já estava instalada.

## Escrevendo uma

Copie `exemplo.sh` e preencha:

```bash
descrever() {
  echo "Nome curto"
  echo "Uma ou duas linhas sobre o que faz e de quem é."
  echo "https://link-do-projeto"
}

verificar() {           # 0 = já está instalado
  command -v minha-ferramenta >/dev/null
}

instalar() {            # o que fazer; pode pedir confirmação do usuário
  echo "rodando o instalador oficial…"
  # ...
}

usar() {                # opcional: como usar depois de instalada
  echo "aponte para ela no CLAUDE.md do projeto"
}
```

Mantenha `instalar()` honesta: se a integração baixa algo da internet, diga de
onde. Se precisa de uma chave de API, diga antes, não depois.

## Por que separado

O workdeck é um workflow, não um gerenciador de pacotes. Estas integrações
existem porque aparecem muito em fluxo de trabalho com agentes de IA — não
porque o projeto as endossa, as mantém ou as auditou. Leia o que cada uma faz
antes de rodar.
