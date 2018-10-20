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
        | Where-Object {
             1 -in ($_.PositionPrefRank | %{if($_.Value -eq 1){$_.Key}})
         }
        return $prefranks
    }
}