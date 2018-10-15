class Player {
    $FirstName
    $LastName
    $PostionPrefRank
    Player([string]$firstName, [string]$lastName, $positionPreference) {
        $this.FirstName = $firstName
        $this.LastName = $lastName
        $this.PostionPrefRank = $positionPreference
    }
}