# baixar.sh

Script para baixar vídeos do YouTube, TikTok e Instagram a partir de link(s), em qualidade máxima, com controle de duplicados.

## Requisitos

Instale via [Homebrew](https://brew.sh):

```bash
brew install yt-dlp ffmpeg jq
```

- **yt-dlp** — faz o download dos vídeos (suporta YouTube, TikTok, Instagram e outros sites nativamente)
- **ffmpeg** — junta os streams de vídeo e áudio no arquivo final `.mp4`
- **jq** — lê/escreve o arquivo de controle `.baixados.json`

Verifique se está tudo instalado:

```bash
yt-dlp --version
ffmpeg -version
jq --version
```

## Passo a passo (primeiro uso)

1. Instale as dependências (veja [Requisitos](#requisitos)):
   ```bash
   brew install yt-dlp ffmpeg jq
   ```
2. Clone o repositório e entre na pasta:
   ```bash
   git clone https://github.com/LukaszFokin/video_downloader.git
   cd video_downloader
   ```
3. Dê permissão de execução ao script (só precisa fazer isso uma vez):
   ```bash
   chmod +x baixar.sh
   ```
4. Rode passando o(s) link(s) que quer baixar:
   ```bash
   ./baixar.sh "https://www.youtube.com/shorts/xxxxxxxxx"
   ```
5. Confira o resultado na pasta de destino (veja [Onde os vídeos são salvos](#onde-os-vídeos-são-salvos)).

Dica: sempre coloque o link entre aspas (`"..."`) pra evitar que o Terminal interprete caracteres como `?`, `&` e `=` como comandos.

## Como usar

```bash
./baixar.sh <link1> [link2] [link3] ...
```

Ou passando um arquivo `.txt` com um link por linha (pode misturar links de plataformas diferentes):

```bash
./baixar.sh links.txt
```

Para baixar de novo um link que já foi baixado antes (por padrão ele é pulado):

```bash
./baixar.sh --force <link1> [link2] ...
```

## O que o script faz

1. Detecta a plataforma pelo domínio do link: `youtube.com`/`youtu.be` → YouTube, `tiktok.com` → TikTok, `instagram.com` → Instagram (qualquer outro domínio vai para `Outros`).
2. Confere no arquivo de controle `.baixados.json` se aquele link já foi baixado antes. Se já foi, pula (a menos que use `--force`).
3. Baixa o vídeo com `yt-dlp`, escolhendo a melhor qualidade disponível, priorizando o codec **H.264 + AAC** (garante que o arquivo abra em qualquer player — QuickTime, Preview, etc. não tocam vídeo em VP9/AV1 dentro de `.mp4`, mesmo que o arquivo pareça válido).
4. Salva o arquivo final em `<destino>/<Plataforma>/<prefixo>_<timestamp>.mp4`, onde o prefixo é `yt`, `tk` ou `ig` e o timestamp é a data/hora do download (`AAAAMMDDHHMMSS`).
5. Registra o link no `.baixados.json` para não baixar de novo nas próximas execuções.

## Onde os vídeos são salvos

Por padrão o destino é `~/Downloads/YouTube` (definido pela variável `DEST` no início do `baixar.sh`) — pasta separada de onde o script está instalado/clonado. Pra mudar o destino, edite essa variável no script.

```
~/Downloads/YouTube/
├── .baixados.json          # controle de links já baixados (não editar manualmente)
├── YouTube/
│   └── yt_20260911133045.mp4
├── TikTok/
│   └── tk_20260911134210.mp4
└── Instagram/
    └── ig_20260911104425.mp4
```

## Arquivo de controle (.baixados.json)

Guarda um mapa de link → informações do download:

```json
{
  "https://www.youtube.com/shorts/ABCvJQAZqbI": {
    "arquivo": "YouTube/yt_20260911133045.mp4",
    "plataforma": "YouTube",
    "baixado_em": "2026-09-11T16:30:47Z"
  }
}
```

Se quiser "esquecer" um link específico (forçar novo download sem usar `--force` em todos), edite esse arquivo e remova a entrada correspondente, ou apague o arquivo inteiro para resetar o controle completo.
