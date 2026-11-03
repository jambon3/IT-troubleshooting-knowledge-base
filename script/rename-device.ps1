Set-ExecutionPolicy RemoteSigned

Clear-Host

Write-Host "================================="
Write-Host " Computer Rename Utility"
Write-Host "================================="
Write-Host ""

$NewName = Read-Host "Enter the desired computer name"

Rename-Computer -NewName $NewName -Force

Write-Host ""
Write-Host "Successfully renamed computer to: $NewName"
Write-Host "Restart required to apply changes."
