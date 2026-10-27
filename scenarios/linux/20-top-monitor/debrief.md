# 해설

```bash
top                         # 몇 초 지켜보기 → P(CPU순), M(메모리순)
ps aux --sort=-rss | head   # 메모리 순 확인
top -b -n 1 > ~/top-report.txt
```

## 함정 포인트: "튀는" CPU
4초 일하고 2초 쉬는 프로세스는 `top` 을 **한 번 찍으면 0% 로 보일 때가 있어요.** 장애 분석에서는 "한 장의 사진"이 아니라 **흐름**을 봐야 합니다.
```bash
top -b -n 5 -d 1 | grep -A 3 PID     # 1초 간격으로 5번
ps -eo pid,comm,time --sort=-time | head   # 누적 CPU 시간이 긴 순 (튀는 프로세스도 잡힘)
```

## 숫자 읽는 법
- **load average** `0.85, 0.60, 0.40` : 1·5·15분 평균으로 "CPU 를 기다리는 작업 수". **코어 수**(`nproc`)보다 계속 크면 과부하예요.
- **%CPU 100** = 코어 1개를 꽉 씀. 코어가 4개면 최대 400% 까지 나와요.
- **RES** : 실제로 메모리를 차지한 양. **VIRT** 는 "예약만 한 것"까지 포함해서 크게 보여요. 보통 RES 를 보면 됩니다.
- **%Cpu(s) 의 wa** : 디스크를 기다리는 시간. 높으면 CPU 가 아니라 디스크가 병목이에요.

## 더 좋은 도구
- `htop` : 색깔, 마우스, 트리 보기 (`sudo apt install htop`)
- `vmstat 1`, `iostat -x 1` : 시스템 전체 흐름
- `pidstat 1` : 프로세스별 CPU 흐름 (sysstat 패키지)
