Using module ./Game.psm1
Using module ./Period.psm1
Using module ./Player.psm1
Using module ./Position.psm1
Using module ./Event.psm1
Using module ./DecisionMethod.psm1

# Zack Knight 2108 - Youth Soccer Lineup

# keeps track of positions played in game? no, but it can get a history from games it has played in, which stores that in the period
# game keeps track of periods, periods keep track of positions.
# coach's rank for player ability in a position
# configurable selection - maximize rotation, equal play time, by player pref, to win
# does a sub penalize the player that needed to come out?
# im starting to question whether I should pick the position for the player rather than the player for the position.
# if you pick the position for the player, you end up having to iterate the players in some order, which will affect the assignment.

[CmdletBinding()]
Param(
    $TotalPeriods = 4,
    $PeriodDurationMinutes = 12,
    $TotalPositions = 7,
    $TotalPositionsRanked = 4,
    $RefereeName = 'TestRef',
    $DataFilePath = './u8Lineup.data.json'
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
    [System.Collections.Generic.List[Position]]$positions = New-Object System.Collections.Generic.List[Position]

    #Room for improvement. This is the most basic layout. We can introduce configurable positions later, but I want to work out how to fill a given set of positions.
    $position = [Position]::new()
    $position.Name = 'Goalie'         
    $positions.Add($position)    
    $position = [Position]::new()
    $position.Name = 'Defense' 
    $positions.Add($position)
    $position = [Position]::new()
    $position.Name = 'Defense' 
    $positions.Add($position)
    $position = [Position]::new()
    $position.Name = 'Mid' 
    $positions.Add($position)
    $position = [Position]::new()
    $position.Name = 'Mid' 
    $positions.Add($position)
    $position = [Position]::new()
    $position.Name = 'Forward' 
    $positions.Add($position)
    $position = [Position]::new()
    $position.Name = 'Forward' 
    $positions.Add($position)

    $positions
}

Function Set-StartingPlayer {
    [OutputType([Player])]
    Param(
        [Game]$CurrentGame,
        [System.Collections.Generic.List[Player]]$AvailablePlayers,
        [Position]$CurrentPosition
    )

    $CurrentPeriod = $CurrentGame.Periods | Where-Object {
        $CurrentPosition.Id -in ($_.Positions | Select-Object -ExpandProperty Id)
    }
        
    [Player[]]$playersWhoPreferCurrentPosition
    [Player[]]$playersThatHaventPlayedYet 
    $PlayersInPosition = $CurrentGame.Periods | Select-Object -ExpandProperty Positions | ForEach-Object {
        if (($null -ne $_.StartingPlayer)) {
            $_
        }
    }| Select-Object StartingPlayer

    $PlayersInPositionLastPeriod = $CurrentGame.Periods | Select-Object -ExpandProperty Positions | Where-Object{$_.Number -eq ($CurrentPosition.Number - 1)}
    ForEach-Object {
        if (($null -ne $_.StartingPlayer)) {
            $_
        }
    }| Select-Object -ExpandProperty StartingPlayer
    
    $playersThatHaventPlayedYet = $AvailablePlayers |
        Where-Object {
        $_ -notin ($PlayersInPosition | Select-Object -ExpandProperty StartingPlayer )
    }

    $playersComingOffBench = $AvailablePlayers | Where-Object {
        $_ -notin $PlayersInPositionLastPeriod
    }
            
    $i = 1

    DO {    
        $playersWhoPreferCurrentPosition = $AvailablePlayers | Where-Object {
            $_.PostionPrefRank -match "$($CurrentPosition.Name)=$($i)" -and
            $_ -notin ($CurrentPeriod.Positions | Select-Object -ExpandProperty StartingPlayer)
        }
        $i++
    } Until(($playersWhoPreferCurrentPosition -eq $true -or $playersWhoPreferCurrentPosition.Length -gt 0) -or $i -gt $TotalPositionsRanked)

    [Player]$GoodFitPlayer = $playersWhoPreferCurrentPosition | Where-Object {$_ -in $playersComingOffBench} | Get-Random
    
    if($null -eq $GoodFitPlayer){
    $GoodFitPlayer = $playersWhoPreferCurrentPosition |Get-Random -SetSeed 2 #this isn't good random. you've done it in the past. do it again.
    }
    #-and $GoodFitPlayer -in $playersThatHaventPlayedYet

    if ($null -ne $GoodFitPlayer) {
        $GoodFitPlayer
    }
    else {
        $GoodFitPlayer = $playersThatHaventPlayedYet | Get-Random
        $GoodFitPlayer
        #throw "No Player Found to Fill Position: $($CurrentPosition.Name) in Period: $($CurrentPeriod.Number)"
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
    $_.Positions = New-PositionList
}

$game.Periods | ForEach-Object {
    $PeriodPositions = $_ | Select-Object -ExpandProperty Positions 

    $PeriodPositions | ForEach-Object {
        #TODO Sometimes the starting player will be set, but I'll find a reason to change it as the positions fill in.
            
        if (($null -eq $_.StartingPlayer) -and $($_.Name) -ne 'Bench') {
            # TODO Learn why your pipeline has an object array with an empty first index
            $StartingPlayer = Set-StartingPlayer -CurrentGame $game -AvailablePlayers $players -CurrentPosition $_ | Where-Object {$null -ne $_}
            if ($StartingPlayer) {
                $_.StartingPlayer = $StartingPlayer 
            }
        }
    }
}

$game.Periods | ForEach-Object {
    $periodNumber = $_.Number
    $_.Positions | ForEach-Object {
        "Period: $($periodNumber) - Position: $($_.Name) - Player: $($_.StartingPlayer.FirstName)"
    }
    "================================================="
    [System.Environment]::NewLine
}