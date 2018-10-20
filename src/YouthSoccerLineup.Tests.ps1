
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "YouthSoccerLineup" {
    It "Does not bench a player more than twice" {
        $result = YouthSoccerLineup
        $result.Periods | Select-Object -expandproperty Positions | Where-Object {
            $_.Name -match 'Bench'
        } | Select-Object -expandproperty StartingPlayer `
            | Group-Object firstname `
            | Select-Object -ExpandProperty count `
            | Sort-Object -Descending `
            | Select-Object -first 1 `
            | Should -BeLessThan 3
    }
}
