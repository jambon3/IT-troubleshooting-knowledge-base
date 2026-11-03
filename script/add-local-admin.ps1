# add-local-admin.ps1

$Domain = "CORP"

$Users = @(
    "david.krin",
    "david.krin-adm"
)

foreach ($User in $Users) {
    Add-LocalGroupMember -Group "Administrators" -Member "$Domain\$User"
}

Write-Host "Completed."
