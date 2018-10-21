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
        | %{ @{'FavPosition' = ($_ | select PositionPrefRank `
        |  %{$_.psobject.properties | %{$_.Value.psobject.properties | ?{$_.value -eq 1}}
    } | select -exp Name); 'Player' = $_} }

        return $prefranks
    }
}