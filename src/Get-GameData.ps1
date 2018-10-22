Function Get-GameData {
    Param(
        $DataFilePath
    )
    $data = Get-Content $DataFilePath | ConvertFrom-Json

    $data
}