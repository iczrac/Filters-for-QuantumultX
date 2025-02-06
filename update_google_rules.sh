#!/bin/bash

# 设置下载链接
GOOGLE_RULES="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/QuantumultX/Google/Google.list"
GOOGLE_DRIVE_RULES="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/QuantumultX/GoogleDrive/GoogleDrive.list"
GOOGLE_EARTH_RULES="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/QuantumultX/GoogleEarth/GoogleEarth.list"

# 创建临时文件
TMP_DIR="/tmp/google_rules_update"
mkdir -p $TMP_DIR

echo "开始下载规则文件..."

# 下载规则文件
curl -s "$GOOGLE_RULES" > "$TMP_DIR/google.list"
curl -s "$GOOGLE_DRIVE_RULES" > "$TMP_DIR/googledrive.list"
curl -s "$GOOGLE_EARTH_RULES" > "$TMP_DIR/googleearth.list"

echo "处理规则文件..."

# 提取规则并保持原有格式，统一标记为Google
cat "$TMP_DIR/google.list" "$TMP_DIR/googledrive.list" "$TMP_DIR/googleearth.list" | \
    grep -E "^HOST|^HOST-SUFFIX|^HOST-KEYWORD|^IP-CIDR|^IP6-CIDR|^USER-AGENT" | \
    sed 's/HOST-SUFFIX/DOMAIN-SUFFIX/g' | \
    sed 's/HOST/DOMAIN/g' | \
    sed 's/,GoogleDrive$/,Google/g' | \
    sed 's/,GoogleEarth$/,Google/g' | \
    sort -u > "$TMP_DIR/combined_rules.list"

# 创建新的规则文件
cat > "Google_Services.list" << EOL
# Google Services Rules
# 自动更新时间：$(date '+%Y-%m-%d %H:%M:%S')
# 规则来源：blackmatrix7
# 原始链接：
# - ${GOOGLE_RULES}
# - ${GOOGLE_DRIVE_RULES}
# - ${GOOGLE_EARTH_RULES}

# Google Basic Services
EOL

# 添加基础服务规则
grep -E "google\.com|gmail|googlemail|gstatic|googleapis" "$TMP_DIR/combined_rules.list" >> "Google_Services.list"

echo "# Google Drive & Docs" >> "Google_Services.list"
grep -E "googledrive|docs\.google" "$TMP_DIR/combined_rules.list" >> "Google_Services.list"

echo "# Google Earth" >> "Google_Services.list"
grep -E "earth\.google|kh\.|khm\.|earth-pa" "$TMP_DIR/combined_rules.list" >> "Google_Services.list"

echo "# YouTube" >> "Google_Services.list"
grep -E "youtube|ytimg|youtu\.be" "$TMP_DIR/combined_rules.list" >> "Google_Services.list"

echo "# Other Google Services" >> "Google_Services.list"
grep -v -E "google\.com|gmail|googlemail|gstatic|googleapis|googledrive|docs\.google|earth\.google|kh\.|khm\.|earth-pa|youtube|ytimg|youtu\.be" "$TMP_DIR/combined_rules.list" >> "Google_Services.list"

# 清理临时文件
rm -rf "$TMP_DIR"

echo "规则更新完成！" 