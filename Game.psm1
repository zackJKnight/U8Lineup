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

    WriteGame() {
        $this.Periods | ForEach-Object {
            $periodNumber = $_.Number
            $_.Positions | ForEach-Object {
                Write-Output "Period: $($periodNumber) - Position: $($_.Name) - Player: $($_.StartingPlayer.FirstName)"
            }
            Write-Output "================================================="
            Write-Output [System.Environment]::NewLine
        }
    }
}