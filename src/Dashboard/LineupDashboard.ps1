# Playing with Universal Dashboard

. ../YouthSoccerLineup.ps1

$LineupDashboard = New-UDDashboard -Title "Lineup"

$cards = $players | % {
New-UDCard -Title $_ -Text $_
}