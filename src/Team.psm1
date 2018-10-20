Using module ./Game.psm1
Using module ./Player.psm1

class Team {
    [string]$Name;
    [Player[]]$Players;
    [Game[]]$Games;

    Team([string]$name) {
        $this.Name = $name;
        $this.Games;
    }

    [System.Object[]]GetPlayersWithFavoritePostion() {
        return $this.Players | Select-Object Name, (PositionPrefRank | Where-Object {
            $_ -like '*=1'} )
    }
}