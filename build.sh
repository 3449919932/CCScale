#!/usr/bin/env bash
# CCScale 一键构建：解压后直接运行 ./build.sh
set -e
cd "$(dirname "$0")"

# 1) Theos 路径（按你的实际安装改，或者先 export THEOS=...）
export THEOS="${THEOS:-$HOME/theos}"
if [ ! -d "$THEOS/makefiles" ]; then
  echo "❌ 找不到 Theos：$THEOS"
  echo "   请先 export THEOS=/你的/theos 路径，或修改本脚本第 7 行"
  exit 1
fi
export PATH="$THEOS/bin:$PATH"

# 2) 工具链自检
for t in clang make ldid dpkg-deb; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "❌ 缺少工具：$t（Theos/toolchain 没装完整）"
    exit 1
  fi
done
echo "✅ Theos=$THEOS"

# 3) 编译
make clean >/dev/null 2>&1 || true
make package FINALPACKAGE=1

# 4) 结果
echo
echo "==== 产物 ===="
ls -l packages/*.deb
sha256sum packages/*.deb
