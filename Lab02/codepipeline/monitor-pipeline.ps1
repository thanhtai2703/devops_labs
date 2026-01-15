# PowerShell script to monitor CodePipeline execution

$ErrorActionPreference = "Stop"

$PIPELINE_NAME = "cfn-pipeline-pipeline"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Monitoring Pipeline Execution" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Get-PipelineStatus {
    $status = aws codepipeline get-pipeline-state --name $PIPELINE_NAME --query 'stageStates[*].[stageName,latestExecution.status]' --output text 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pipeline Status at $(Get-Date -Format 'HH:mm:ss'):" -ForegroundColor Yellow
        Write-Host "----------------------------------------" -ForegroundColor Gray
        
        $lines = $status -split "`n"
        foreach ($line in $lines) {
            $parts = $line -split "`t"
            if ($parts.Count -eq 2) {
                $stageName = $parts[0]
                $stageStatus = $parts[1]
                
                $color = switch ($stageStatus) {
                    "Succeeded" { "Green" }
                    "InProgress" { "Yellow" }
                    "Failed" { "Red" }
                    default { "White" }
                }
                
                $icon = switch ($stageStatus) {
                    "Succeeded" { "✅" }
                    "InProgress" { "⏳" }
                    "Failed" { "❌" }
                    default { "⚪" }
                }
                
                Write-Host "  $icon $stageName : " -NoNewline
                Write-Host "$stageStatus" -ForegroundColor $color
            }
        }
        Write-Host ""
        return $true
    } else {
        Write-Host "❌ Could not get pipeline status" -ForegroundColor Red
        return $false
    }
}

# Monitor loop
Write-Host "🔄 Monitoring pipeline (press Ctrl+C to stop)...`n" -ForegroundColor Cyan

$iteration = 0
$maxIterations = 60  # Monitor for up to 30 minutes (60 * 30 seconds)

while ($iteration -lt $maxIterations) {
    $success = Get-PipelineStatus
    
    if (-not $success) {
        break
    }
    
    $iteration++
    Start-Sleep -Seconds 30
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "• View pipeline in console:" -ForegroundColor Yellow
Write-Host "  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/$PIPELINE_NAME/view`n" -ForegroundColor White

Write-Host "• Get detailed execution:" -ForegroundColor Yellow
Write-Host "  aws codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id <ID>`n" -ForegroundColor White

Write-Host "• View CodeBuild logs:" -ForegroundColor Yellow
Write-Host "  aws codebuild batch-get-builds --ids <BUILD_ID>`n" -ForegroundColor White

Write-Host "• Check deployed infrastructure stack:" -ForegroundColor Yellow
Write-Host "  aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure`n" -ForegroundColor White
