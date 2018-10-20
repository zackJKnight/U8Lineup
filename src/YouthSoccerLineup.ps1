Using module ./Game.psm1
Using module ./Period.psm1
Using module ./Player.psm1
Using module ./Position.psm1
Using module ./Event.psm1
Using module ./DecisionMethod.psm1
Using module ./Team.psm1
. ./Get-PlayersThatPreferPosition
. ./Set-StartingPlayer
. ./Get-GameData
. ./New-PositionList

# Zack Knight 2018 - Youth Soccer Lineup
function YouthSoccerLineup {
[CmdletBinding()]
Param(
    $TeamName = 'The Green Machine',
    $TotalPeriods = 4,
    $PeriodDurationMinutes = 12,
    $TotalPositions = 7,
    $TotalPositionsRanked = 4,
    $RefereeName = 'TestRef',
    $DataFilePath = '../u8Lineup.data.json'
)

$Team = [Team]::new($TeamName)

$GameData = Get-GameData

[Game]$game = [Game]::new((Get-Date))

$game.Ref = $RefereeName

[System.Collections.Generic.List[Player]]$players = New-Object System.Collections.Generic.List[Player]

$GameData.players | ForEach-Object {
    $players.Add([Player]::new($_.firstName, $_.lastName, $_.playerPositionPreference))
}

1..$TotalPeriods | ForEach-Object {
    $game.Periods.Add([Period]::new($_, $PeriodDurationMinutes))
}

$game.Periods | ForEach-Object {
    $_.Positions = New-PositionList $GameData.positions
}

$game.Periods | ForEach-Object {
    $CurrentPeriod = $_
    [Player[]]$playersThatHaventPlayedYet

    $PlayersInAnyPositionThisGame = $game.GetPlayersThatAreInAPosition();
    # use this to rotate players across positions throughout the game
    #$PlayersInPositionLastPeriod = $game.GetPlayersInPositionLastPeriod($CurrentPeriod.Number);
    $PlayersComingOffBench = $game.GetPlayersFromBenchLastPeriod($CurrentPeriod.Number);

    $playersThatHaventPlayedYet = $players |#inst showing bench players
        Where-Object {
        $_ -notin ($PlayersInAnyPositionThisGame | Select-Object -ExpandProperty StartingPlayer )
    }
    
    $PeriodPositions = $_ | Select-Object -ExpandProperty Positions 
    # Does a player coming off bench prefer an open position? give them first dibs.
    
    if ($PlayersComingOffBench) {
        $PlayersComingOffBench | ForEach-Object {
            $currentPlayer = $_; 
            $PeriodPositions | Where-Object {
                $currentPlayer.PostionPrefRank -match "$($_.Name)=1"
            }| ForEach-Object {
                if ($currentPlayer -notin $CurrentPeriod.GetStartingPlayers() ) {
                    $_.StartingPlayer = $currentPlayer
                }
            }
        }
    }

    $PeriodPositions | ForEach-Object {
        #TODO Sometimes the starting player will be set, but I'll find a reason to change it as the positions fill in.
        #need to place our bench players first            
        $CurrentPeriodStartingPlayers = $CurrentPeriod.GetStartingPlayers();
        $CurrentPeriodBenchPlayers = $CurrentPeriod.GetBenchPlayers();
        $AvailablePlayersWhoPreferCurrentPosition = Get-PlayersThatPreferPosition -CurrentPlayerList $players -CurrentPositionName $_.Name -CurrentPeriodStartingPlayers $CurrentPeriodStartingPlayers | Where-Object {$null -ne $_}

        $PlayersFromBenchWhoPreferCurrentPosition = Get-PlayersThatPreferPosition -CurrentPlayerList $PlayersComingOffBench -CurrentPositionName $_.Name -CurrentPeriodStartingPlayers $CurrentPeriodStartingPlayers | Where-Object {$null -ne $_}
        
        if ($CurrentPeriod.PositionsFilled() -eq $true) {
            #positions are full. bench the rest
            $BenchPlayer = $players | Where-Object {
                $_ -notin $CurrentPeriodStartingPlayers -and $_ -notin $CurrentPeriodBenchPlayers
            } | Select-Object -First 1
            if($null -eq $_.StartingPlayer) {
            $_.StartingPlayer = $BenchPlayer 
            }
        }        
        elseif (($null -eq $_.StartingPlayer)) {
            # TODO Learn why your pipeline has an object array with an empty first index
            $StartingPlayer = Set-StartingPlayer -CurrentPosition ($_ | Where-Object {$null -ne $_}) -PlayersWhoPreferCurrentPosition $AvailablePlayersWhoPreferCurrentPosition -PlayersComingOffBench $PlayersFromBenchWhoPreferCurrentPosition -PlayersThatHaventPlayedYet $playersThatHaventPlayedYet
            if ($StartingPlayer) {
                $_.StartingPlayer = $StartingPlayer 
            }
        }
    }
}

$Team.Games += $game;
$Team

}

#YouthSoccerLineup

#$game.WriteGame();