Using module ./Game.psm1
Using module ./Period.psm1
Using module ./Player.psm1
Using module ./Position.psm1
Using module ./Event.psm1
Using module ./DecisionMethod.psm1

# Zack Knight 2108 - Youth Soccer Lineup

[CmdletBinding()]
Param(
    $TotalPeriods = 4,
    $PeriodDurationMinutes = 12,
    $TotalPositions = 7,
    $TotalPositionsRanked = 4,
    $RefereeName = 'TestRef',
    $DataFilePath = '../u8Lineup.data.json'
)

Function Get-DecisionMethod ($decideBy) {
    # TODO add selectable decision method
    switch ($decideBy) {
        default { [DecisionMethod]::PLAYER_PREFERENCE }
    }
}
Function Get-GameData {
    Get-Content $DataFilePath | ConvertFrom-Json
}

Function New-PositionList {
    Param(
        $GameDataPositions
    )
    [System.Collections.Generic.List[Position]]$positions = New-Object System.Collections.Generic.List[Position]

    $GameDataPositions | ForEach-Object{
        for ($i = 0; $i -lt $_.pitchCount; $i++) {
            $position = [Position]::new()
            $position.Name = $_.name         
            $positions.Add($position)    
        }
    }

    $positions
}

Function Set-StartingPlayer {
    [OutputType([Player])]
    Param(
        [Game]$CurrentGame,
        [System.Collections.Generic.List[Player]]$AvailablePlayers,
        [Position]$CurrentPosition
    )

    [Period]$CurrentPeriod = $CurrentGame.GetPeriodByPositionId($CurrentPosition.Id);
        
    [Player[]]$playersWhoPreferCurrentPosition
    [Player[]]$playersThatHaventPlayedYet

#You're doing this every position, but need only to do it once a period
    $CurrentPeriodStartingPlayers = $CurrentPeriod.GetStartingPlayers();
    $PlayersInAnyPositionThisGame = $CurrentGame.GetPlayersThatAreInAPosition();
#You're doing this every position, but need only to do it once a period
    $PlayersInPositionLastPeriod = $CurrentGame.GetPlayersInPositionLastPeriod($CurrentPeriod.Number);
#You're doing this every position, but need only to do it once a period    
    $playersThatHaventPlayedYet = $AvailablePlayers |
        Where-Object {
        $_ -notin ($PlayersInAnyPositionThisGame | Select-Object -ExpandProperty StartingPlayer )
    }
#You're doing this every position, but need only to do it once a period
    $playersComingOffBench = $CurrentGame.GetPlayersFromBenchLastPeriod($CurrentPeriod.Number);
    #need to place our bench players first            
    $CurrentPlayerList = $AvailablePlayers # set this up to pass in bench players
    $i = 1

    DO {    
        $playersWhoPreferCurrentPosition = $CurrentPlayerList | Where-Object {
            $_.PostionPrefRank -match "$($CurrentPosition.Name)=$($i)" -and
            $_ -notin $CurrentPeriodStartingPlayers
        }
        $i++
    } Until(($playersWhoPreferCurrentPosition -eq $true -or $playersWhoPreferCurrentPosition.Length -gt 0) -or $i -gt $TotalPositionsRanked)
#bench players may not prefer the first three positions, which leaves them at the end of the line.
    [Player]$GoodFitPlayer = $playersWhoPreferCurrentPosition | Where-Object {$_ -in $playersComingOffBench} | Get-Random
    
    if($null -eq $GoodFitPlayer){
    $GoodFitPlayer = $playersWhoPreferCurrentPosition | Get-Random
    }

    if ($null -ne $GoodFitPlayer) {
        $GoodFitPlayer
    }
    else {
        $GoodFitPlayer = $playersThatHaventPlayedYet | Get-Random
        $GoodFitPlayer
    }
}

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
    $PeriodPositions = $_ | Select-Object -ExpandProperty Positions 

    $PeriodPositions | ForEach-Object {
        #TODO Sometimes the starting player will be set, but I'll find a reason to change it as the positions fill in.
            
        if (($null -eq $_.StartingPlayer)) { #-and $($_.Name) -ne 'Bench'
            # TODO Learn why your pipeline has an object array with an empty first index
            $StartingPlayer = Set-StartingPlayer -CurrentGame $game -AvailablePlayers $players -CurrentPosition $_ | Where-Object {$null -ne $_}
            if ($StartingPlayer) {
                $_.StartingPlayer = $StartingPlayer 
            }
        }
    }
}

$Lineup = $game.WriteGame();

$Lineup