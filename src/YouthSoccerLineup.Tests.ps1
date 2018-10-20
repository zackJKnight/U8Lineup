
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "YouthSoccerLineup" {

    $result = YouthSoccerLineup

    It "Does not bench a player more than twice" {
        
        $team = $result | Select-Object * | Where-Object{ $null -ne $_.Games }
        $team.Games[0].Periods | Select-Object -expandproperty Positions | Where-Object {
            $_.Name -match 'Bench'
        } | Select-Object -expandproperty StartingPlayer `
            | Group-Object firstname `
            | Select-Object -ExpandProperty count `
            | Sort-Object -Descending `
            | Select-Object -first 1 `
            | Should -BeLessThan 3
    }

    It "Plays each player in their top ranked position at least once" {
        $playersFavoritePosition = $result.GetPlayersWithFavoritePosition
        $result.Games[0].Periods | Select-Object -expandproperty Positions | Where-Object {
            $_.Name -notmatch 'Bench'
        } `
        | Select-Object -expandproperty StartingPlayer `
        | Should -Be $true
    }
}
