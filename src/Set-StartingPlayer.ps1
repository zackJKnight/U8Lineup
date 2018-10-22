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
        $GoodFitPlayer = $PlayersComingOffBench | Get-Random -Count 1
    }

    if ($null -eq $GoodFitPlayer) {
        $GoodFitPlayer = $PlayersWhoPreferCurrentPosition | Get-Random -Count 1
    }

    if ($null -ne $GoodFitPlayer) {
        $GoodFitPlayer
    }
    else {
        $GoodFitPlayer = $PlayersThatHaventPlayedYet | Get-Random -Count 1
        $GoodFitPlayer
    }
}