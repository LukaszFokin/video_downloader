#!/bin/bash
# Baixa videos do YouTube, TikTok, Instagram (video+audio, melhor qualidade) a partir de link(s)
# Organiza em subpastas por plataforma dentro do destino
# Pula links ja baixados antes (controle em .baixados.json), a menos que passe --force
# Uso: ./baixar.sh [--force] <link1> [link2] [link3] ...
# Ou: ./baixar.sh [--force] arquivo.txt  (arquivo com um link por linha, fontes misturadas)

set -e

DEST="$HOME/Downloads/YouTube"
CONTROLE="$DEST/.baixados.json"

mkdir -p "$DEST"
[ -f "$CONTROLE" ] || echo "{}" > "$CONTROLE"

FORCE=0
args=()
for arg in "$@"; do
    if [ "$arg" = "--force" ]; then
        FORCE=1
    else
        args+=("$arg")
    fi
done
set -- "${args[@]}"

if [ "$#" -eq 0 ]; then
    echo "Uso: $0 [--force] <link1> [link2] ... | arquivo.txt"
    exit 1
fi

detectar_plataforma() {
    local url="$1"
    case "$url" in
        *youtube.com*|*youtu.be*) echo "YouTube yt" ;;
        *tiktok.com*) echo "TikTok tk" ;;
        *instagram.com*) echo "Instagram ig" ;;
        *) echo "Outros ot" ;;
    esac
}

ja_baixado() {
    local url="$1"
    jq -e --arg u "$url" '.[$u] != null' "$CONTROLE" > /dev/null 2>&1
}

marcar_baixado() {
    local url="$1" arquivo="$2" plataforma="$3" timestamp="$4"
    local tmp
    tmp=$(mktemp)
    jq --arg u "$url" --arg a "$arquivo" --arg p "$plataforma" --arg t "$timestamp" \
        '.[$u] = {arquivo: $a, plataforma: $p, baixado_em: $t}' \
        "$CONTROLE" > "$tmp" && mv "$tmp" "$CONTROLE"
}

baixar() {
    local url="$1"
    local plataforma prefixo timestamp arquivo

    if [ "$FORCE" -ne 1 ] && ja_baixado "$url"; then
        echo ">> Ja baixado, pulando (use --force pra baixar de novo): $url"
        return
    fi

    read -r plataforma prefixo <<< "$(detectar_plataforma "$url")"
    mkdir -p "$DEST/$plataforma"
    timestamp=$(date +%Y%m%d%H%M%S)
    arquivo="${prefixo}_${timestamp}.mp4"

    echo ">> Baixando: $url"
    yt-dlp \
        -f "bv*+ba/b" \
        -S "codec:h264:m4a,res,fps,br" \
        --merge-output-format mp4 \
        -o "$DEST/$plataforma/${prefixo}_${timestamp}.%(ext)s" \
        --no-playlist \
        "$url"

    marcar_baixado "$url" "$plataforma/$arquivo" "$plataforma" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

# se passou um unico arquivo .txt, le links dele
if [ "$#" -eq 1 ] && [ -f "$1" ]; then
    while IFS= read -r link; do
        [ -z "$link" ] && continue
        baixar "$link"
    done < "$1"
else
    for link in "$@"; do
        baixar "$link"
    done
fi

echo "Pronto. Arquivos em: $DEST"
