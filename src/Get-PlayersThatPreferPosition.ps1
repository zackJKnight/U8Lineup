Function Get-PlayersThatPreferPosition {
    Param(
        [int]$i = 1,
        $CurrentPositionName,
        $CurrentPlayerList,
        $CurrentPeriodStartingPlayers
    )

    [Player[]]$playersWhoPreferCurrentPosition
    
    DO {    
        $playersWhoPreferCurrentPosition = $CurrentPlayerList | Where-Object {
            $_.PostionPrefRank -match "$($CurrentPositionName)=$($i)" -and
            $_ -notin $CurrentPeriodStartingPlayers
        }
        $i++
    } Until(($playersWhoPreferCurrentPosition -eq $true -or $playersWhoPreferCurrentPosition.Length -gt 0) -or $i -gt $TotalPositionsRanked)

    $playersWhoPreferCurrentPosition
}