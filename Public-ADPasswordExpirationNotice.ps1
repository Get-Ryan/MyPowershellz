<#
.Description
 This script obtains AD accounts with passwords nearing expiration and sends notification emails on certain days prior to expiration.
 Currently, it only sends emails if the password age matches the exact date frame out from expiration.
 There is no check to see if an account was missed by the script not being run on a particular day.
.Notes
 AUTHOR: Ryan Simeone
 LASTEDIT: 7/29/2015 9:15 PM UTC

#>

$ErrorActionPreference = "Stop"

Function CheckPasswordAge() {

### Obtain max password age set in default domain policy

    $maxPwdAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days

### Set variables at desired timeframes to send reminder emails

    $14days = (get-date).AddDays(14 - $maxPwdAge)
    $7days = (get-date).AddDays(7 - $maxPwdAge)
    $2days = (get-date).AddDays(2 - $maxPwdAge)
    $1day = (get-date).AddDays(1 - $maxPwdAge)

### List Accounts with PasswordLastSet equal to or older than max password age +14 days in the past

    $Accounts = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} –Properties * | where {($_.PasswordLastSet) -le $14days} | Sort-Object PasswordLastSet

### Determine accounts with password ages at previously set timeframes and email reminders to change their password.
    
    ForEach($Account in $Accounts) {
        
        If($Account.PasswordLastSet.Date -eq $14days.Date) {
            SendNotifcationEmail "in 2 weeks"
        
        }

        ElseIf($Account.PasswordLastSet.Date -eq $7days.Date) {
            SendNotificationEmail "in 1 week"
        
        }

        ElseIf($Account.PasswordLastSet.Date -eq $2days.Date) {
            SendNotificationEmail "in 2 days"
        
        }

        ElseIf($Account.PasswordLastSet.Date -eq $1day.Date) {
            SendNotficationEmail "tomorrow"    
        
        }
    }
}

Function SendNotificationEmail([string]$TimeframeString) {

### Send email with the specified timeframe to the user

    Send-MailMessage -SMTPServer SMTPServer.Domain.com `
    -To $Account.UserPrincipalName `
    -From Address@Domain.com `
    -Cc Address@Domain.com `
    -Subject "Password Notice - Your password will expire $($TimeframeString)" `
    -BodyAsHtml "Hello $($Account.GivenName),<BR>
    <BR>
    This is an automated reminder that your password will be expiring $($TimeframeString)
    on $((Get-Date).AddDays(14).ToShortDateString()).<BR>
    You can press Ctrl+Alt+Del to bring up a screen where you can change your password.<BR>
    <BR>
    Sincerely,<BR>The <Company> IT Team"
        
}

CheckPasswordAge
