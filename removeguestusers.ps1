Install-Module Microsoft.Graph
Connect-MgGraph -Scopes "User.Read.All"

# Define the date to check (30 days ago)
$checkDate = (Get-Date).AddDays(-30)

# Get all guest users
$guestUsers = Get-MgUser -Filter "userType eq 'Guest'" -All

# Initialize an array to store guests who haven't accepted the invite
$guestsNotAccepted = @()

# Loop through the guest users
foreach ($guest in $guestUsers) {
    # Get the creation date of the user (which is when the invite was sent)
    $createdDate = $guest.CreatedDateTime

    # Check if the guest account is older than 30 days and if the guest has not accepted the invite
    if ($createdDate -lt $checkDate -and $guest.ExternalUserState -ne "Accepted") {
        $guestsNotAccepted += $guest
    }
}

# Output the guest users who have not accepted the invite
$guestsNotAccepted | Select-Object DisplayName, Mail, UserPrincipalName, CreatedDateTime, ExternalUserState
