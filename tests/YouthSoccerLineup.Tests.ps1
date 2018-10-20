$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\$sut"

Describe "YouthSoccerLineup" {
    It "Does not bench a player more than twice" {
        YouthSoccerLineup | Should -Be $true
    }
}
