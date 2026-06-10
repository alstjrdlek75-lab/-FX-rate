#!/bin/bash

# 스크립트 실행 위치로 이동
cd "$(dirname "$0")"

echo "====================================================="
echo "👀 [자동 배포 시스템] 파일 변경 감시 시작..."
echo "====================================================="

# 파일의 해시(MD5)를 모니터링하여 변경 감지 (macOS 기본 md5 명령어 활용)
LAST_HASH=""

if [ ! -d ".git" ]; then
  echo "⚠️ 경고: 이 디렉토리는 아직 Git 저장소로 초기화되지 않았습니다."
  echo "먼저 터미널에서 'git init' 및 원격 저장소 설정을 마쳐주세요."
fi

while true; do
  if [ -f "index.html" ]; then
    CURRENT_HASH=$(md5 -q index.html)
    
    if [ "$LAST_HASH" != "" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
      echo "✨ index.html 변경 감지! [$(date '+%Y-%m-%d %H:%M:%S')]"
      
      # Git 명령어 순차 실행
      git add index.html images/
      git commit -m "Auto-update lesson: $(date '+%Y-%m-%d %H:%M:%S')"
      git push origin main
      
      if [ $? -eq 0 ]; then
        echo "🚀 깃허브 배포 완료!"
      else
        echo "❌ 깃허브 푸시 실패. 네트워크 상태나 Git 권한을 확인하세요."
      fi
      echo "-----------------------------------------------------"
    fi
    LAST_HASH=$CURRENT_HASH
  fi
  
  # 5초 간격으로 파일 변경점 체크
  sleep 5
done
