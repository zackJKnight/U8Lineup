
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "YouthSoccerLineup" {
    $result = YouthSoccerLineup
    BeforeEach {
        $resultTeam = $result[13] #clean out the pipeline
        $playersAndTheirFavoritePosition = $resultTeam.GetPlayersWithFavoritePosition()
    }
    It "Does not bench a player more than twice" {
        
        $team = $result | Select-Object * | Where-Object { $null -ne $_.Games }
        $team.Games[0].Periods | Select-Object -expandproperty Positions | Where-Object {
            $_.Name -match 'Bench'
        } | Select-Object -expandproperty StartingPlayer `
            | Group-Object firstname `
            | Select-Object -ExpandProperty count `
            | Sort-Object -Descending `
            | Select-Object -first 1 `
            | Should -BeLessThan 3
    }

    It "Prefers a player's favorite position" {

        $playerPositionAssignments = $result.Games[0].Periods | Select-Object -expandproperty Positions | Where-Object {
            $_.Name -notmatch 'Bench'
        } `
            | Select-Object -property Name, StartingPlayer
        
        $playersThatDidNotGetTheirFavoritePosition = $playerPositionAssignments | ForEach-Object {
            $playerAssignment = @{
                'Player' = $_.Player
                'Position' = $_.Position
            }
            Where-Object {
                $playerAssignment -in $playersAndTheirFavoritePosition
            } | Select-Object -ExpandProperty StartingPlayer
        }
        #TODO Fail until you can finish this test
Should -Be $false
        #$playersThatDidNotGetTheirFavoritePosition | Should -Be $null
    }
}
