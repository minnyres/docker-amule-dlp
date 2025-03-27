docker manifest create minnyres/amule-dlp:official-2.3.3 minnyres/amule-dlp:official-2.3.3-arm64-v8 minnyres/amule-dlp:official-2.3.3-s390x   minnyres/amule-dlp:official-2.3.3-arm-v6  minnyres/amule-dlp:official-2.3.3-arm-v7  minnyres/amule-dlp:official-2.3.3-amd64  minnyres/amule-dlp:official-2.3.3-ppc64le minnyres/amule-dlp:official-2.3.3-riscv64 minnyres/amule-dlp:official-2.3.3-loong64  minnyres/amule-dlp:official-2.3.3-mips64le --amend

docker manifest create minnyres/amule-dlp:latest minnyres/amule-dlp:dlp-arm64-v8 minnyres/amule-dlp:dlp-s390x   minnyres/amule-dlp:dlp-arm-v6  minnyres/amule-dlp:dlp-arm-v7  minnyres/amule-dlp:dlp-amd64  minnyres/amule-dlp:dlp-ppc64le minnyres/amule-dlp:dlp-riscv64 minnyres/amule-dlp:dlp-loong64 minnyres/amule-dlp:official-2.3.3-mips64le --amend

docker manifest push minnyres/amule-dlp:official-2.3.3

docker manifest push minnyres/amule-dlp:latest