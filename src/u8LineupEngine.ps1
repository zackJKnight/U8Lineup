Using module ./Game.psm1
Using module ./Period.psm1
Using module ./Player.psm1
Using module ./Position.psm1
Using module ./Event.psm1
Using module ./DecisionMethod.psm1

# Zack Knight 2018 - Youth Soccer Lineup

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

Function New-PositionList {
    Param(
        $GameDataPositions
    )
    [System.Collections.Generic.List[Position]]$positions = New-Object System.Collections.Generic.List[Position]

    $GameDataPositions | ForEach-Object {
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
        [Player[]]$PlayersWhoPreferCurrentPosition,
        [Position]$CurrentPosition,
        [Player[]]$PlayersComingOffBench,
        [Player[]]$PlayersThatHaventPlayedYet
    )
    
    #bench players may not prefer the first three positions, which leaves them at the end of the line.
    if ($null -ne $PlayersComingOffBench) {
        $GoodFitPlayer = $PlayersWhoPreferCurrentPosition | Where-Object {$_ -in $PlayersComingOffBench} | Get-Random
    }

    if ($null -eq $GoodFitPlayer) {
        $GoodFitPlayer = $PlayersWhoPreferCurrentPosition | Get-Random
    }

    if ($null -ne $GoodFitPlayer) {
        $GoodFitPlayer
    }
    else {
        $GoodFitPlayer = $PlayersThatHaventPlayedYet | Get-Random
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
    $CurrentPeriod = $_
    [Player[]]$playersThatHaventPlayedYet

    $PlayersInAnyPositionThisGame = $game.GetPlayersThatAreInAPosition();
    # use this to rotate players across positions throughout the game
    $PlayersInPositionLastPeriod = $game.GetPlayersInPositionLastPeriod($CurrentPeriod.Number);
    $PlayersComingOffBench = $game.GetPlayersFromBenchLastPeriod($CurrentPeriod.Number);
    $playersThatHaventPlayedYet = $players |
        Where-Object {
        $_ -notin ($PlayersInAnyPositionThisGame | Select-Object -ExpandProperty StartingPlayer )
    }
    
    $PeriodPositions = $_ | Select-Object -ExpandProperty Positions 

    $PeriodPositions | ForEach-Object {
        #TODO Sometimes the starting player will be set, but I'll find a reason to change it as the positions fill in.
        #need to place our bench players first            
        $CurrentPeriodStartingPlayers = $CurrentPeriod.GetStartingPlayers();
        $CurrentPeriodBenchPlayers = $CurrentPeriod.GetBenchPlayers();
        $AvailablePlayersWhoPreferCurrentPosition = Get-PlayersThatPreferPosition -CurrentPlayerList $players -CurrentPositionName $_.Name -CurrentPeriodStartingPlayers $CurrentPeriodStartingPlayers | Where-Object {$null -ne $_}

        $PlayersFromBenchWhoPreferCurrentPosition = Get-PlayersThatPreferPosition -CurrentPlayerList $PlayersComingOffBench -CurrentPositionName $_.Name -CurrentPeriodStartingPlayers $CurrentPeriodStartingPlayers | Where-Object {$null -ne $_}
        
        if ($null -eq $AvailablePlayersWhoPreferCurrentPosition -and $CurrentPeriod.PositionsFilled() ) {
            #positions are full. bench the rest
            $BenchPlayer = $players | Where-Object {
                $_ -notin $CurrentPeriodStartingPlayers -and $_ -notin $CurrentPeriodBenchPlayers
            } | Select-Object -First 1
            $_.StartingPlayer = $BenchPlayer 
        }        
        elseif (($null -eq $_.StartingPlayer)) {
            # TODO Learn why your pipeline has an object array with an empty first index
            $StartingPlayer = Set-StartingPlayer -CurrentPosition ($_ | Where-Object {$null -ne $_}) -PlayersWhoPreferCurrentPosition $AvailablePlayersWhoPreferCurrentPosition -PlayersComingOffBench $PlayersComingOffBench -PlayersThatHaventPlayedYet $playersThatHaventPlayedYet
            if ($StartingPlayer) {
                $_.StartingPlayer = $StartingPlayer 
            }
        }
    }
}
$game.WriteGame();
