# 모든 pwsh 세션에서 실행된다 (AllUsersAllHosts 프로필)
$envFile = '/opt/cmdlab/run/env'
if (Test-Path $envFile) {
    $vars = @{}
    foreach ($line in Get-Content $envFile) {
        if ($line -match '^(\w+)=(.*)$') {
            # bash printf %q 로 저장된 값의 이스케이프를 대략 풀어 준다
            $vars[$Matches[1]] = ($Matches[2] -replace "^\$'|'$", '' -replace '\\(.)', '$1')
        }
    }
    Write-Host ''
    Write-Host "[$($vars.SCENARIO_ID)] " -ForegroundColor Cyan -NoNewline
    Write-Host $vars.SCENARIO_TITLE
    Write-Host '  task' -ForegroundColor Yellow -NoNewline; Write-Host ' 문제 다시 보기 · ' -NoNewline
    Write-Host 'hint' -ForegroundColor Yellow -NoNewline; Write-Host ' 힌트 · ' -NoNewline
    Write-Host 'check' -ForegroundColor Yellow -NoNewline; Write-Host ' 채점 · ' -NoNewline
    Write-Host 'exit' -ForegroundColor Yellow -NoNewline; Write-Host ' 나가기'
    Write-Host ''
}
