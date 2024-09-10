# Checks if the AzureAD module is installed an imported
# Check if a current connection to AzureAD exists
if(!(Get-Module -Name "AzureAD")){
    Write-Host "Installing and importing the AzureAD module" -ForegroundColor Yellow
    try{Install-Module AzureAD}
    catch{Write-Host "Could not install AzureAD module. Please try again." -ForegroundColor Red}
    try{Import-Module AzureAD}
    catch{Write-Host "Could not import AzureAD module. Please try again." -ForegroundColor Red}
    Write-Host "AzureAD module has installed imported successfully" -ForegroundColor Green
}

try{
    Write-Host "Connecting to AzureAD - please see the login prompt" -ForegroundColor Yellow
    Connect-AzureAD -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
    Write-Host "Connected to AzureAD" -ForegroundColor Green
}catch{
    Write-Host "Could not connect to AzureAD. Please try again." -ForegroundColor Red
    exit
}

# Set the date for 30 days
$date = (get-date).AddDays(-30).ToString('yyy-MM-dd hh:mm:ss')

# Get all active guest accounts
$guestAccounts = Get-AzureADUser -All $true -Filter "UserType eq 'Guest'"

# Loop through each guest account and check if it meets the threshold for deletion
ForEach ($guestAccount in $guestAccounts){
    if(($guestAccount.UserState -eq "PendingAcceptance") -and ($guestAccount.ExtensionProperty.createdDateTime -gt "$date")){

        # Get the key/value pairs for the Name and Expression properties of each object iteration (N is short for 'Name' and E is short for 'Expression')
        $deletedUser = Get-AzureADUser -ObjectID $guestAccount.UserPrincipalName | Select-Object @{N='CreatedDateTime';E={$_.ExtensionProperty.createdDateTime}}, @{N='UserPrincipalName';E={$_.UserPrincipalName}}, @{N='DisplayName';E={$_.DisplayName}}, @{N='UserType';E={$_.UserType}}, @{N='UserStateChangedOn';E={$_.UserStateChangedOn}}

        # Export the results to .csv format
        $deletedUser | Export-Csv -Path C:/temp/PendingGuestAccounts.csv -NoTypeInformation -Append
    }
}