$ruleName = "Warn on external senders with matching display names"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#910A19;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#FDF2F4;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message was sent from outside the company by someone with a display name matching a user in your organisation. Please do not click links or open attachments unless you recognise the source of this email and know the content is safe. <o:p></o:p></span></p></div></td></tr></table>"
 
# Establish a PowerShell session with Office 365. You'll be prompted for your Partner Portal credentials
$Cred = Get-Credential
$customers = Get-MsolPartnerContract
Connect-MsolService -Credential $Cred
Write-Host "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."
 
foreach ($customer in $customers) {
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
           
    Write-Host "Checking transport rule for $($Customer.Name)" -ForegroundColor Green
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $Session = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $Cred -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $Session -CommandName Get-Mailbox, Get-TransportRule, New-TransportRule, Set-TransportRule -AllowClobber
      
    $rule = Get-TransportRule | Where-Object {$_.Idetity -contains $ruleName}
    $displayNames = (Get-Mailbox -ResultSize Unlimited).DisplayName
     
    if (!$rule) {
        Write-Host "Rule not found, creating Rule" -ForegroundColor Yellow
        New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml 
    }
    else {
        Write-Host "Rule found, updating Rule" -ForegroundColor Yellow
        Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
    }
     
    Remove-PSSession $Session
}
