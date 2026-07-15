#!/usr/bin/env bash
# image/etc/nftables.conf の構文チェック。
#
# image/etc/nftables.conf は絶対パス /etc/nftables.d/*.conf をincludeするため、
# 開発ホストでそのまま `nft -c -f` にかけるとホスト自身の/etc/nftables.d
# (通常空、または無関係な内容)を見てしまい、本リポジトリのallow-listドロップインを
# 検証しないまま素通りしうる。そのためパスを本リポジトリ内へ差し替えた
# 一時ファイルで検証する。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_CONF="$(mktemp)"
trap 'rm -f "$TMP_CONF"' EXIT

sed "s#/etc/nftables.d#${REPO_ROOT}/image/etc/nftables.d#" \
  "$REPO_ROOT/image/etc/nftables.conf" > "$TMP_CONF"

echo "==> nft -c -f (ドロップイン差し替え版)"
nft -c -f "$TMP_CONF"
echo "OK: 構文エラーなし"
echo
echo "注意: 本チェックはCAP_NET_ADMINを要する(コンテナ/一部サンドボックスでは"
echo "'Operation not permitted' になりうる。実機/sudoで実行すること)。"
echo "唯一の確定的な検証は、実際にビルドしたVM上で"
echo "  sudo nft -c -f /etc/nftables.conf"
echo "を実行すること。"
