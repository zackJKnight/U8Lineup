Using module .\Player.psm1

class Position {
    [guid]$Id
    [string]$Name
    [int]$SpeedRequirement
    [int]$StaminaRequirement
    [Player]$StartingPlayer
    [Player[]]$SubbedPlayers
    [string[]]$PositionNames = @('Bench', 'Goalie', 'Defense', 'Mid', 'Forward')

    Position() {
        $this.Id = New-Guid
    }

    [void] SetName ([string]$name) {
        $this.Name = $name
    }

    [void] SubPlayer ([Player]$player) {
        ($this.SubbedPlayers).Add($player)
    }
}
