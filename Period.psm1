class Period {
    [int]$Number
    $DurationMinutes
    $substitutions
    $periodEvents
    $Positions 
    
    Period([int]$number) {
        $this.Number = $number
    }
}