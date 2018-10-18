class Period {
    [int]$Number
    [int]$DurationMinutes
    $PeriodEvents
    $Positions 
    
    Period([int]$number, [int]$durationMinutes) {
        $this.Number = $number
        $this.DurationMinutes = $durationMinutes
    }

    [System.Object[]]GetBenchPlayers() {
        return $this.Positions | Where-Object {$_.Name -eq 'Bench'} | Select-Object -ExpandProperty StartingPlayer
    }

    [System.Object[]]GetStartingPlayers() {
        return $this.Positions | Select-Object -ExpandProperty StartingPlayer
    }

    [bool]PositionsFilled() {
        $StartingPlayers = $this.Positions | Where-Object {$_.Name -ne 'Bench'} | Select-Object -ExpandProperty StartingPlayer
        #TODO - always true? verify
        return $null -notin $StartingPlayers
    }
}