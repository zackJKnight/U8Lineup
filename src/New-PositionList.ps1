function New-PositionList {
    Param(
        $GameDataPositions
    )
    [System.Collections.Generic.List[Position]]$positions = New-Object System.Collections.Generic.List[Position]

    $GameDataPositions | ForEach-Object {
        for ($i = 0; $i -lt $_.pitchCount; $i++) {
            $position = [Position]::new()
            $position.Name = $_.name         
            $positions.Add($position)    
        }
    }

    $positions
}