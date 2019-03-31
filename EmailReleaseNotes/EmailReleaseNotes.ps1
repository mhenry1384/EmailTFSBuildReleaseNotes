# Meant to email release notes from GenerateReleaseNotes.
param (
    [Parameter(Mandatory=$true)][string]$to,
	[Parameter(Mandatory=$true)][string]$releaseNotesPath,
	[Parameter(Mandatory=$false)][string]$batNameSuffix = ''
)

import-module "$PSScriptRoot\powershellMarkdown.dll"
$ErrorActionPreference = "Stop" 

function MarkdownToHtml {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        [PSObject[]]$InputObject
        )

	Foreach ($item in $InputObject) {
		$out = $item | ConvertFrom-Markdown -AutoHyperlink -AutoNewlines -EncodeProblemUrlCharacters -LinkEmails -StrictBoldItalic -Verbose
		$HtmlOutput = @"
            <!DOCTYPE HTML>
            <html lang="en-US">
            <body style="background-color: #f9f9FF">
            <div id="wrapper">
            $out
            </div>
            </body>
            </html>
"@
		Write-Output $HtmlOutput

		}
}

function FixMarkdown($markdownText)
{
	# Sometimes the TFS "Associated change sets" section has an indented set of bullets that start with a "-" instead of a "*".  
	# We'll keep those as dashes by prefixing the lines with double spaces, which tells markdown to keep the original content.
	$markdownText = $markdownText -replace("`n *-([^`r`n]*)", "`n  -`$1")
	# Remove the blank line that appears above the indented bullet points - it exists in Visual Studio but I think the list looks better without it.
	$markdownText = $markdownText -replace("`n`r`n  -", "`n  -")
	# Remove the email address or domainn name in the "Assigned to:" of the work items.  It doesn't add anything and it looks ugly.
	$markdownText = $markdownText -replace(" <[^`r`n]*\\[^`r`n]*>", "]")
	# strip the commit IDs down to 7 digits, that's the standard for a short SHA
	$markdownText = $markdownText -replace 'ID ([0-9a-fA-F]{7})[0-9a-fA-F]{33}', 'ID $1'
	# Github's markdown converter can't handle curly quotation marks.  I bet it could if we escaped them in the JSON, or converted them to their HTML equivalents before sending them over.  let's just change them to standard ASCII double quotes.
	$markdownText = $markdownText -replace '[\u201C\u201D]', '"'
	# Say None instead of just leaving a blank space if there are no associated work items.
	$markdownText = $markdownText -replace '### Associated work items\s*###', "### Associated work items`r`n`r`n*None*`r`n`r`n###"
	# Convert any blank lines in "associated change sets" to indented bullet points
	$newMarkdownText = ""
	$foundAssociatedCommits = $false
	$markdownText -split '\r?\n' | ForEach-Object {
		if ($_.StartsWith("### Associated commits")) {
			$foundAssociatedCommits = $true
			$newMarkdownText += $_
			$newMarkdownText += [Environment]::NewLine
		}
		elseif (!([string]::IsNullOrEmpty($_))) {
			if ($foundAssociatedCommits -and !($_.StartsWith("*")) -and !($_ -match '^\s*-')) {
				$newMarkdownText += "  * " + $_
			}
			else {
				$newMarkdownText += $_
			}
			$newMarkdownText += [Environment]::NewLine
		}
	}
	
	return $newMarkdownText
}

echo "Generating HTML email"
$markdownText = Get-Content -Path $releaseNotesPath -Raw
$originalMarkdownText = $markdownText
$markdownText = FixMarkdown $markdownText
if ($Env:SYSTEM_TEAMPROJECT -eq $null)
{
	# must not be called during a build so I guess we're testing the script.
	$Env:SYSTEM_TEAMPROJECT = "TEST-PROJECT" 
	$ENV:BUILD_BUILDNUMBER = "TEST-BUILD_NUMBER"
}
$teamproject = $Env:SYSTEM_TEAMPROJECT -replace "[() ]", ""
$markdownText = "To deploy this build now, do some stuff`r`n"+$markdownText
$htmlText = $markdownText | MarkdownToHtml

$subject = "Build - $($ENV:SYSTEM_TEAMPROJECT) $($ENV:BUILD_BUILDNUMBER)"
echo "Sending email with subject `"$subject`" to $to"
Send-MailMessage -From TFS@foo.com -To $to.Split("{;,}") -SmtpServer foo-com.mail.protection.outlook.com -Subject $subject -Body $htmlText -BodyAsHtml

# Send the markdown to me for testing
#Send-MailMessage -From CNAdmin@foobounces.onmicrosoft.com -To mhenry@foo.com -SmtpServer foo-com.mail.protection.outlook.com -Subject $subject -Body ($originalMarkdownText)