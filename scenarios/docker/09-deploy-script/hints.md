`cat ~/deploy.sh` 로 스크립트를 보세요. `docker run --name web` 만 있고, 기존 `web` 을 정리하는 단계가 없어요.
---
흔히 `docker run` 앞에 `docker stop web` 과 `docker rm web` 을 넣어요. 1.1 배포는 될 거예요. 그런데 `web` 이 **없을 때** 실행하면? `docker stop` 이 "No such container" 로 실패하고, `set -e` 때문에 스크립트가 거기서 멈춰요. `docker rm -f web; ./deploy.sh 1.1` 로 시험해 보세요.
---
"없어도 괜찮은" 실패는 `|| true` 로 감싸요: `docker rm -f web 2>/dev/null || true`. (최신 Docker 의 `docker rm -f` 는 없는 컨테이너여도 성공 코드를 돌려주지만, 옛 버전이나 `stop`·`rm` 은 실패해요. `|| true` 를 붙여 두면 어디서나 안전해요)
---
고친 뒤 `./deploy.sh 1.1` 을 두 번 연속 실행해 보고, `docker rm -f web` 후에도 한 번 더 실행해서 모두 성공하는지 확인하세요.
