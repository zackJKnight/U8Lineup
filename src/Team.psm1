Using module ./Game.psm1
Using module ./Player.psm1

class Team {
    [string]$Name;
    $Players;
    $Games;

    Team([string]$name) {
        $this.Name = $name;
        $this.Games;
    }

    [System.Object[]]GetPlayersWithFavoritePosition() {
        $prefranks = $this.Players `
        | select PositionPrefRank `
        | Where-Object {
             1 -eq $_.value
         } | select key
        return $prefranks
    }
}