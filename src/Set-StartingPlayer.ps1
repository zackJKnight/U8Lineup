function Set-StartingPlayer {
    [OutputType([Player])]
    Param(
        [Player[]]$PlayersWhoPreferCurrentPosition,
        [Position]$CurrentPosition,
        [Player[]]$PlayersComingOffBench,
        [Player[]]$PlayersThatHaventPlayedYet
    )
    
    #bench players may not prefer the first three positions, which leaves them at the end of the line.
    if ($null -ne $PlayersComingOffBench) {
        $GoodFitPlayer = $PlayersComingOffBench | Get-Random
    }

    if ($null -eq $GoodFitPlayer -and $null -ne $PlayersWhoPreferCurrentPosition) {
        $GoodFitPlayer =  $PlayersWhoPreferCurrentPosition | Get-Random
    }

    if ($null -ne $GoodFitPlayer) {
        $GoodFitPlayer
    }
    elseif($null -ne $PlayersThatHaventPlayedYet) {
        $GoodFitPlayer = $PlayersThatHaventPlayedYet | Get-Random
        $GoodFitPlayer
    }
}