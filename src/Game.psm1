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

    [string[]]WriteGame() {
        [string[]]$result = @()
        $this.Periods | ForEach-Object {
            $periodNumber = $_.Number
            $_.Positions | ForEach-Object {
                $result += "Period: $($periodNumber) - Position: $($_.Name) - Player: $($_.StartingPlayer.FirstName)"
            }
            $result += "================================================="
            $result += [System.Environment]::NewLine
        }

        return $result
    }
}