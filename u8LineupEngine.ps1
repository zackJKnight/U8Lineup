Using module ./Game.psm1
Using module ./Period.psm1
Using module ./Player.psm1
Using module ./Position.psm1
Using module ./Event.psm1
Using module ./DecisionMethod.psm1

# Zack Knight 2108 - U8 Soccer Lineup

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
    $RefereeName = 'TestRef',
    $dataFilePath = './u8Lineup.data.json'
)

Function Get-DecisionMethod ($decideBy) {
    # TODO add selectable decision method
    switch ($decideBy) {
        default { [DecisionMethod]::PLAYER_PREFERENCE }
    }
}
Function Get-GameData {
    $gameData = Get-Content $dataFilePath | ConvertFrom-Json 
    $gameData
}

Function Get-Player {
    Param(
        [Game]$CurrentGame,
        [System.Collections.Generic.List[Player]]$AvailablePlayers
    )

    #get the first period that isn't completely filled. that was my first thought. BUT. Manually, I look at all the periods before I can complete the first period. 
    #and I often try scenarios with all periods full and then change names based on ability/endurance
    #look at number of filled position.
    #if none, find the goalie first. 

    #need to know open positions.
    #need to know filled positions and who fills them.
    $CurrentGame.Periods | ForEach-Object {
    $UnfilledPositions =  
        $_ | Select-Object -ExpandProperty Positions | Where-Object {
            $null -eq $_.StartingPlayer
        }
    

    #TODO - build an abstraction to allow user to define positions.
    $playersWhoPreferGoalie = $AvailablePlayers | Where-Object {$_.PostionPrefRank -match 'goalie=1'}
    $playersWhoPreferDefense = $AvailablePlayers | Where-Object {$_.PostionPrefRank -match 'defense=1'}
    $playersWhoPreferMid = $AvailablePlayers | Where-Object {$_.PostionPrefRank -match 'mid=1'}
    $playersWhoPreferForward = $AvailablePlayers | Where-Object {$_.PostionPrefRank -match 'forward=1'}

    # can you give a player his first pick?
    $UnfilledGoalie = $UnfilledPositions | Where-Object { $_.Name -eq 'Goalie' }
    # can you give a player their second pick?
    # so on
    # so forth
    # When positions are full, fill the bench.
    # Check that a player hasn't been on the bench yet

    }

    [Player]$bestFitPlayer #= $playersWhoPreferGoalie | Select-Object -First 1

    $bestFitPlayer

}

$GameData = Get-GameData

[Game]$game = [Game]::new((Get-Date))

$game.Ref = $RefereeName

[System.Collections.Generic.List[Player]]$players = New-Object System.Collections.Generic.List[Player]

$GameData.players | ForEach-Object {
    $players.Add([Player]::new($_.firstName, $_.lastName, $_.playerPositionPreference))
}

[System.Collections.Generic.List[Position]]$positions = New-Object System.Collections.Generic.List[Position]

1..$TotalPositions | ForEach-Object {
    $positions.Add([Position]::new()) 
}

#TODO Set position names???


1..$TotalPeriods | ForEach-Object {
    $game.Periods.Add([Period]::new($_, $PeriodDurationMinutes))
}

$game.Periods | ForEach-Object {
    $_.Positions = $positions
}

$poZishes = $game.Periods | Select-Object -ExpandProperty Positions 

$poZishes | ForEach-Object {
    $_.StartingPlayer = (Get-Player -CurrentGame $game -AvailablePlayers $players)
}

$game