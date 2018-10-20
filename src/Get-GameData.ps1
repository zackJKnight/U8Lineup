Function Get-GameData {
    Get-Content $DataFilePath | ConvertFrom-Json
}