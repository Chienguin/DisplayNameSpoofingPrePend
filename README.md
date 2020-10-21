# DisplayNameSpoofingPrePend

Grabs the Display Names for all users in each tenant, checks to see if the specified rule is already created, and will either update the rule with new users or creates the rule with all the Display Names for users for that tenant. 

The transport rule created is as follows

IF

1) The sender is Not In The Organization

AND

2) The FROM header matches the display name of any user in the tenant

THEN

1) Pre-pend the email with a warning message stating that the email was sent from outside the organization and to be careful about clicking links



Pre-Requisites: 
1) If you are not running Windows 10, install the 64-bit version of the Microsoft Online Services Sign-in Assistant
2) Microsoft Azure Active Directory Module for Windows PowerShell must be installed
3) The Microsoft Azure Active Directory Module for Windows PowerShell requires that the Microsoft .NET Framework 3.5.x feature is enabled
