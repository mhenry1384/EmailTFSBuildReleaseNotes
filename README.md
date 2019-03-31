 - `raw.githubusercontent.com/mhenry1384/EmailTFSBuildReleaseNotes/master/EmailExample.png?sanitize=true&raw=true`
 
Works with
https://marketplace.visualstudio.com/items?itemName=richardfennellBM.BM-VSTS-GenerateReleaseNotes-Task to generate and email out build release notes.

I would prefer the name "build notes" not "release notes", since release notes implies an Octopus Deployment release, but that's what the TFS task is called.

The last two build steps should be
* "Generate Release Notes", with an Output file of 
	$(Build.StagingDirectory)\ReleaseNotes.md
	and a Template file of 
	\\TFSBuilds\Builds\_Tools\build-basic-template.md
* PowerShell, with a script filename of 
	\\TFSBuilds\Builds\_Tools\EmailReleaseNotes.ps1
	and argument of 
	-to "$(ToEmail)" -releaseNotesPath $(Build.StagingDirectory)\ReleaseNotes.md
	
Set a ToEmail variable with a semicolon-delimited list of email addresses.

powershellMarkdown/MarkdownSharp is checked in at https://github.com/mhenry1384/posh-markdown
