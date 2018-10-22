
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$here\$sut"

try {
    InModuleScope -ModuleName Team -ScriptBlock {
 
        Describe "Team" {
            . ./Get-GameData
            BeforeEach {
                $TestTeam = [Team]::new('TestTeamName')
                [System.Collections.Generic.List[Player]]$players = New-Object System.Collections.Generic.List[Player]
                (Get-GameData '../u8Lineup.data.json').players | ForEach-Object {
                    $players.Add([Player]::new($_.firstName, $_.lastName, $_.playerPositionPreference))
                }
                $TestTeam.Players += $players;
            }
            it 'Returns a list of Players with their favorite position' {
                $TestTeam.GetPlayersWithFavoritePosition() | Should -Not -Be $null
            }
        }
    } 
} 
finally{
    
}