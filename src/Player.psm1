class Player {
    $FirstName
    $LastName
    $PositionPrefRank
    Player([string]$firstName, [string]$lastName, $positionPreference) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.PositionPrefRank = $positionPreference
    }
}