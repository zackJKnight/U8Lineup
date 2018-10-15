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

    [System.Object]GetPeriodByPositionId([guid]$CurrentPositionId) {
        return $this.Periods | Where-Object {
            $CurrentPositionId -in ($_.Positions | Select-Object -ExpandProperty Id)
        } | Select-Object -First 1
    }

    [System.Object[]]GetPlayersFromBenchLastPeriod($CurrentPeriodNumber) {
        return $this.Periods | Select-Object -ExpandProperty Positions | Where-Object {
            $_.Number -eq ($CurrentPeriodNumber - 1)
        }
        ForEach-Object {
            if (($null -ne $_.StartingPlayer) -and $_.Name -eq 'Bench') {
                $_
            }
        }| Select-Object -ExpandProperty StartingPlayer
    }

    [System.Object[]]GetPlayersInPositionLastPeriod($CurrentPeriodNumber) {
        return $this.Periods | Select-Object -ExpandProperty Positions | Where-Object {$_.Number -eq ($CurrentPeriodNumber - 1)}
        ForEach-Object {
            if (($null -ne $_.StartingPlayer)) {
                $_
            }
        }| Select-Object -ExpandProperty StartingPlayer
    }

    [System.Object[]]GetPlayersThatAreInAPosition() {
        return $this.Periods | Select-Object -ExpandProperty Positions | ForEach-Object {
            if (($null -ne $_.StartingPlayer)) {
                $_
            }
        }| Select-Object StartingPlayer
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