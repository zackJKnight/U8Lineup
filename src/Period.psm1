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
        $OpenPositions = $this.Positions | Where-Object {$_.Name -ne 'Bench' -and $_.StartingPlayer -eq $null} 
        
        return ($OpenPositions.Count -eq 0)
    }
}