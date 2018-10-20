enum DecisionMethod {
    EQUAL_PLAY_TIME 
    EQUAL_POSITION_ROTATION 
    PLAYER_PREFERENCE 
    WIN_BY_SKILL
}

Function Get-DecisionMethod ($decideBy) {
    # TODO add selectable decision method
    switch ($decideBy) {
        default { [DecisionMethod]::PLAYER_PREFERENCE }
    }
}