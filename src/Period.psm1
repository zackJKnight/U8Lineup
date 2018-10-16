class Period {
    [int]$Number
    [int]$DurationMinutes
    $PeriodEvents
    $Positions 
    
    Period([int]$number, [int]$durationMinutes) {
        $this.Number = $number
        $this.DurationMinutes = $durationMinutes
    }

    [System.Object[]]GetStartingPlayers() {
        return $this.Positions | Select-Object -ExpandProperty StartingPlayer
    }
}