#!/bin/bash
# Baixa videos do YouTube (video+audio, melhor qualidade) a partir de link(s) passado(s) como argumento
# Uso: ./baixar_youtube.sh <link1> [link2] [link3] ...
# Ou: ./baixar_youtube.sh arquivo.txt  (arquivo com um link por linha)

set -e

DEST="$HOME/Downloads/YouTube"
mkdir -p "$DEST"

if [ "$#" -eq 0 ]; then
    echo "Uso: $0 <link1> [link2] ... | arquivo.txt"
    exit 1
fi

baixar() {
    local url="$1"
    yt-dlp \
        -f "bv*+ba/b" \
        --merge-output-format mp4 \
        -o "$DEST/%(title)s.%(ext)s" \
        --no-playlist \
        "$url"
}

# se passou um unico arquivo .txt, le links dele
if [ "$#" -eq 1 ] && [ -f "$1" ]; then
    while IFS= read -r link; do
        [ -z "$link" ] && continue
        echo ">> Baixando: $link"
        baixar "$link"
    done < "$1"
else
    for link in "$@"; do
        echo ">> Baixando: $link"
        baixar "$link"
    done
fi

echo "Pronto. Arquivos em: $DEST"
