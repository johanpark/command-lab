# 엑셀 월별 시트 합쳐서 보고서 만들기

영업팀이 3분기 매출 엑셀 `~/data/sales_2026Q3.xlsx` 를 보내 왔어요. **7월, 8월, 9월 시트**에 거래가 한 줄씩 있어요. 팀장님은 **분기 전체의 지점별 매출 합계**가 담긴 엑셀을 원해요.

예전 담당자가 만든 `~/tools/report.py` 가 있긴 한데...
```
$ python3 ~/tools/report.py
Traceback (most recent call last):
  ...
ValueError: invalid literal for int() with base 10: '1,250,000'
```

## 목표
1. `~/out/summary.xlsx` 를 만드세요.
   - 시트 이름: **`지점별`**
   - 1행은 머리글 **`지점`**, **`매출합계`**
   - 2행부터 지점마다 한 줄, **매출합계가 큰 순서**로. 매출합계는 **숫자**(텍스트 말고)
   - **7·8·9월 시트 전부**의 금액을 합쳐야 해요. (`설명` 시트는 데이터가 아니에요)
2. 분기 매출 **1등 지점 이름**을 `~/answer.txt` 에 저장하세요.

`report.py` 를 고쳐 써도 되고, 새로 만들어도 돼요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `python3 ~/tools/report.py` | 스크립트 실행 |
| `python3` | 대화형 파이썬 (한 줄씩 시험해 보기, `exit()` 로 종료) |
| `nano ~/tools/report.py` | 고치기 |

## openpyxl 한 줄 사전
| 코드 | 뜻 |
|---|---|
| `wb = load_workbook("파일.xlsx")` | 엑셀 열기 |
| `wb.sheetnames` | 시트 이름 목록 |
| `wb.active` | **처음 열리는 시트 하나** |
| `wb["7월"]` | 이름으로 시트 고르기 |
| `ws.iter_rows(min_row=2, values_only=True)` | 2행부터 한 줄씩 (값만) |
| `wb = Workbook(); ws = wb.active; ws.title = "이름"` | 새 엑셀 |
| `ws.append(["a", 1])` | 한 줄 추가 |
| `wb.save("파일.xlsx")` | 저장 |
