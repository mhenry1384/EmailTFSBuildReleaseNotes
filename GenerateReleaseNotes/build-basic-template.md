[](This is checked into $\Shared Tools\BuildTools\GenerateReleaseNotes)
# Build notes for $teamproject $($build.buildnumber) 
**Build Number**  : $($build.buildnumber)    
**Build started** : $("{0:MM/dd/yyyy HH:mm:ss}" -f [datetime]$build.startTime) ET  
**Source Branch** : $($build.sourceBranch)  
**Build Definition** : $defname
**Build Time** : $("{0:n1}" -f ((Get-Date) - ([datetime]$build.startTime)).TotalMinutes) minutes  
**SiteBuilder Version** : SITEBUILDER_VERSION_INFO
  
### Associated work items  
@@WILOOP@@  
* **$($widetail.fields.'System.WorkItemType') $($widetail.id)** [Assigned to: $($widetail.fields.'System.AssignedTo') | [details]($($widetail._links.html.href))] $($widetail.fields.'System.Title') 
@@WILOOP@@  
  
### Associated commits  
@@CSLOOP@@  
* **ID $($csdetail.changesetid)$($csdetail.commitid)** [$($csdetail.author.name) | $(([datetime]$csdetail.author.date).ToString('yyyy-MM-dd hh:mm tt')) | [details]($($csdetail.remoteUrl.Replace(' ', '%20')))] $($csdetail.comment)     
@@CSLOOP@@  