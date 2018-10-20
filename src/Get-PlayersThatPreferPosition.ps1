Function Get-PlayersThatPreferPosition {
    Param(
        [int]$i = 1,
        $CurrentPositionName,
        $CurrentPlayerList,
        $CurrentPeriodStartingPlayers
    )

    [Player[]]$playersWhoPreferCurrentPosition
    if($null -ne $CurrentPlayerList -and $CurrentPositionName -ne 'Bench') {
    DO {    
        $playersWhoPreferCurrentPosition = $CurrentPlayerList | Where-Object {
            $null -ne $_.PositionPrefRank -and `
            ($_.PositionPrefRank | select -ExpandProperty $CurrentPositionName.ToLower()) -eq $i -and `
            $_ -notin $CurrentPeriodStartingPlayers
        }
        $i++
    } Until(($playersWhoPreferCurrentPosition -eq $true -or $playersWhoPreferCurrentPosition.Length -gt 0) -or $i -gt $TotalPositionsRanked)
    }
    $playersWhoPreferCurrentPosition
}