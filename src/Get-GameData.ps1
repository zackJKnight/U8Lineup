Function Get-GameData {
    Param(
        $DataFilePath
    )
    Get-Content $DataFilePath | ConvertFrom-Json
}