class Game {
    [System.DateTime]$PlayDate
    $Opponent
    $StartTime
    $Ref
    [System.Collections.Generic.List[System.Object]]$Periods
    $Events
    Game([System.DateTime]$playDate) {
        $this.PlayDate = $playDate
        $this.Periods = New-Object System.Collections.Generic.List[System.Object]
    }
}