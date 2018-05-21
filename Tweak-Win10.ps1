#requires -RunAsAdministrator
[cmdletbinding(DefaultParametersetName="Preset")]
param(
[ValidateSet("Host","Log","Pipe")]$RedirectOutput = "Pipe",
[Parameter(ParameterSetName='Preset')]
[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]$PresetFile,
[Parameter(ParameterSetName='Preset')]$Delimiter = ",",
[Parameter(ParameterSetName='Select')][switch]$SelectTweaks,
#[Parameter(ParameterSetName='Select')][switch]$ExportTweaks,
[switch]$WaitForKey,
[switch]$RestartComputer
)
<#
.SYNOPSIS
    .
.DESCRIPTION
    Apply various Windows 10 / 2016 settings
.PARAMETER PresetFile
    The file with tweaks to apply
	Create comma delimited file with name of Tweak to apply followed by parameter and parameter option
	for example: "Set-TweakName","Status","Disabled"
.PARAMETER SelectTweaks
	showing gridview to select tweak(s) to apply
	a prompt for parameter option will be shown per tweak as they are mandatory
.PARAMETER RedirectOutput
    Different output options:
		Host writes output (immediately) to host
		Log saves output to log file in temp folder
		Pipe returns output at end of script to the pipeline
.PARAMETER WaitForKey
	script will pause until (any) key is entered in console
.PARAMETER RestartComputer
	some tweaks need a restart of the computer / shell to be applied
.EXAMPLE
    PS>
.NOTES
    Author: Chris Kenis
    Date:   19 may 2018
	Version: 5.0
	Most tweaks need Admin rights to run successfully
.LINK
	https://github.com/chriskenis/Win10-TweakCollection
#>

process{
# Load Tweak names from selection grid or a preset file
switch ($PsCmdlet.ParameterSetName){
	"Preset" { $Tweaks = Test-Tweak -Tweaks $( Import-Csv -Path $PresetFile -Delimiter $Delimiter -Header $TweakHdr ) }
	"Select" { $Tweaks = $Tweaks | Out-GridView -Title "Select Tweaks to apply" -PassThru }
	}
foreach ($Tweak in $Tweaks){
	$error.clear()
	if ( $Tweak.Validation -eq "Valid" ){
		switch ($PsCmdlet.ParameterSetName){
			"Preset" { Invoke-Expression "$($Tweak.Tweak) -$($Tweak.Parameter) $($Tweak.ParameterOption)" }
			"Select" { Invoke-Expression $Tweak.Tweak }
			}
		if ( $error ){ $Tweak.Applied = $False } else { $Tweak.Applied = $True }
		}
	else { Out-put "Failed to find $($Tweak.Tweak) in script functions" }
	}
if ($WaitForKey) {
	Write-Host "Press any key to continue..." -ForegroundColor Black -BackgroundColor White
	[Console]::ReadKey($true) | Out-Null
	}
if ($RestartComputer){ Restart-Computer }
}

begin {
$nl = [Environment]::NewLine
#properties of custom tweak object
$TweakHdr = @("Tweak","Parameter","ParameterOption","Scope","Validation","Applied")
# Default preset
$Tweaks = @"
"Set-Telemetry","Status","Enabled,Disabled","SpyWare","Valid"
"Set-WiFiSense","Status","Enabled,Disabled","OS","Valid"
"Set-SmartScreen","Status","Enabled,Disabled","Security","Valid"
"Set-WebSearch","Status","Enabled,Disabled","Search","Valid"
"Set-AppSuggestions","Status","Enabled,Disabled","BloatWare","Valid"
"Set-ActivityHistory","Status","Enabled,Disabled","SpyWare","Valid"
"Set-StartSuggestions","Status","Enabled,Disabled","BloatWare","Valid"
"Set-BackgroundApps","Status","Enabled,Disabled","OS","Valid"
"Set-LockScreenSpotlight","Status","Enabled,Disabled","Advertising","Valid"
"Set-LocationTracking","Status","Enabled,Disabled","SpyWare","Valid"
"Set-MapUpdates","Status","Enabled,Disabled","OS","Valid"
"Set-Feedback","Status","Enabled,Disabled","SpyWare","Valid"
"Set-TailoredExperiences","Status","Enabled,Disabled","SpyWare","Valid"
"Set-AdvertisingID","Status","Enabled,Disabled","Advertising","Valid"
"Set-WebLangList","Status","Enabled,Disabled","OS","Valid"
"Set-Cortana","Status","Enabled,Disabled","Search","Valid"
"Set-ErrorReporting","Status","Enabled,Disabled","SpyWare","Valid"
"Set-P2PUpdate","Status","Local,Internet","OS","Valid"
"Set-CastToDevice","Status","Enabled,Disabled","OS","Valid"
"Set-AutoLogger","Status","Enabled,Disabled","SpyWare","Valid"
"Set-DiagTrack","Status","Enabled,Disabled","SpyWare","Valid"
"Set-WAPPush","Status","Enabled,Disabled","OS","Valid"
"Set-UAClevel","Status","Low,High","Security","Valid"
"Set-SharingMappedDrives","Status","Enabled,Disabled","OS","Valid"
"Set-AdminShares","Status","Enabled,Disabled","OS","Valid"
"Set-SMBv1","Status","Enabled,Disabled","OS","Valid"
"Set-SMBServer","Status","Enabled,Disabled","OS","Valid"
"Set-LLMNR","Status","Enabled,Disabled","OS","Valid"
"Set-CurrentNetworkProfile","Status","Private,Public","OS","Valid"
"Set-UnknownNetworkProfile","Status","Private,Public","OS","Valid"
"Set-NetDevicesAutoInst","Status","Enabled,Disabled","OS","Valid"
"Set-FolderAccessControl","Status","Enabled,Disabled","Security","Valid"
"Set-Firewall","Status","Enabled,Disabled","Security","Valid"
"Set-WindowsDefender","Status","Enabled,Disabled","Security","Valid"
"Set-WindowsDefenderCloud","Status","Enabled,Disabled","Security","Valid"
"Set-F8BootMenu","Status","Legacy,Standard","OS","Valid"
"Set-DEPOption","Status","OptIn,OptOut","Security","Valid"
"Set-CIMemoryIntegrity","Status","Enabled,Disabled","Security","Valid"
"Set-DotNetStrongCrypto","Status","Enabled,Disabled","Security","Valid"
"Set-ScriptHost","Status","Enabled,Disabled","Security","Valid"
"Set-MeltdownCompatFlag","Status","Enabled,Disabled","OS","Valid"
"Set-UpdateMSRT","Status","Enabled,Disabled","Security","Valid"
"Set-UpdateDrivers","Status","Enabled,Disabled","OS","Valid"
"Set-UpdateRestart","Status","Enabled,Disabled","OS","Valid"
"Set-WindowsUpdateAlert","Status","Enabled,Disabled","OS","Valid"
"Set-HomeGroupServices","Status","Enabled,Disabled","OS","Valid"
"Set-SharedExperiences","Status","Enabled,Disabled","SpyWare","Valid"
"Set-RemoteAssistance","Status","Enabled,Disabled","OS","Valid"
"Set-RemoteDesktop","Status","Enabled,Disabled","OS","Valid"
"Set-AutoPlay","Status","Enabled,Disabled","Security","Valid"
"Set-AutoRun","Status","Enabled,Disabled","Security","Valid"
"Set-StorageSense","Status","Enabled,Disabled","OS","Valid"
"Set-Defragmentation","Status","Enabled,Disabled","OS","Valid"
"Set-SuperFetch","Status","Enabled,Disabled","OS","Valid"
"Set-Indexing","Status","Enabled,Disabled","Search","Valid"
"Set-BIOSTimeZone","Status","UTC,Local","OS","Valid"
"Set-Hibernation","Status","Enabled,Disabled","OS","Valid"
"Set-SleepButton","Status","Enabled,Disabled","OS","Valid"
"Set-SleepTimeout","Status","Enabled,Disabled","OS","Valid"
"Set-FastStartUp","Status","Enabled,Disabled","OS","Valid"
"Set-ActionCenter","Status","Enabled,Disabled","OS","Valid"
"Set-AccountProtectionWarning","Status","Enabled,Disabled","Security","Valid"
"Set-LockScreen","Status","Enabled,Disabled","Security","Valid"
"Set-LockScreenRS1","Status","Enabled,Disabled","Security","Valid"
"Set-LockScreenNetworkConnection","Status","Enabled,Disabled","Security","Valid"
"Set-LockScreenShutdownMenu","Status","Enabled,Disabled","Security","Valid"
"Set-StickyKeys","Status","Enabled,Disabled","Explorer","Valid"
"Set-TaskManagerDetails","Status","Enabled,Disabled","Explorer","Valid"
"Set-FileOperationsDetails","Status","Enabled,Disabled","Explorer","Valid"
"Set-FileDeleteConfirm","Status","Enabled,Disabled","Explorer","Valid"
"Set-PreviousFileVersions","Status","Enabled,Disabled","Explorer","Valid"
"Set-IncludeInLibrary","Status","Enabled,Disabled","Explorer","Valid"
"Set-PinToStart","Status","Enabled,Disabled","Explorer","Valid"
"Set-PinToQuickAccess","Status","Enabled,Disabled","Explorer","Valid"
"Set-RecentItemsInQuickAccess","Status","Show,Hidden,Removed","Explorer","Valid"
"Set-FrequentFoldersInQuickAccess","Status","Enabled,Disabled","Explorer","Valid"
"Set-WindowsContentWhileDragging","Status","Enabled,Disabled","Explorer","Valid"
"Set-ShareWith","Status","Enabled,Disabled","Explorer","Valid"
"Set-SendTo","Status","Enabled,Disabled","Explorer","Valid"
"Set-OpenWithStoreApp","Status","Enabled,Disabled","Explorer","Valid"
"Set-WinXPowerShell","Status","Enabled,Disabled","Explorer","Valid"
"Set-BatteryIcon","Status","NewStyle,OldStyle","Explorer","Valid"
"Set-ClockIcon","Status","NewStyle,OldStyle","Explorer","Valid"
"Set-VolumeIcon","Status","NewStyle,OldStyle","Explorer","Valid"
"Set-TaskbarSearchOption","Status","Box,Icon,Hidden","Explorer","Valid"
"Set-TaskViewButton","Status","Enabled,Disabled","Explorer","Valid"
"Set-TaskbarIconSize","Status","Small,Large","Explorer","Valid"
"Set-TaskbarCombineTitles","Status","WhenFull,Never,Always","Explorer","Valid"
"Set-TaskbarPeopleIcon","Status","Enabled,Disabled","Explorer","Valid"
"Set-MultiDisplayTaskbar","Status","Enabled,Disabled","Explorer","Valid"
"Set-TrayIcons","Status","Enabled,Disabled","Explorer","Valid"
"Set-DisplayTaskbarButtons","Status","All,Open,MainAndOpen","Explorer","Valid"
"Set-DisplayKnownExtensions","Status","Enabled,Disabled","Explorer","Valid"
"Set-LastActiveClick","Status","Enabled,Disabled","Explorer","Valid"
"Set-ShowHiddenSystemFiles","Status","None,Hidden,System","Explorer","Valid"
"Set-SelectCheckboxes","Status","Enabled,Disabled","Explorer","Valid"
"Set-ShowSyncNotifications","Status","Enabled,Disabled","Explorer","Valid"
"Set-ShowRecentShortcuts","Status","Enabled,Disabled","Explorer","Valid"
"Set-SetExplorerDefaultView","Status","ThisPC,QuickAccess","Explorer","Valid"
"Set-ThisPCIconOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-ShowUserFolderOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-DesktopInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-DesktopIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-DocumentsIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-DocumentsIconInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-DownloadsIconInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-DownloadsIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-MusicIconInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-MusicIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-PicturesIconInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-PicturesIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-VideosIconInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-VideosIconInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-3DObjectsInThisPC","Status","Enabled,Disabled","Explorer","Valid"
"Set-3DObjectsInExplorer","Status","Enabled,Disabled","Explorer","Valid"
"Set-NetworkOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-RecycleBinOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-UsersFolderOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-ControlPanelOnDesktop","Status","Enabled,Disabled","Explorer","Valid"
"Set-MostUsedAppsInStartMenu","Status","Enabled,Disabled","Explorer","Valid"
"Set-RecentItemsInStartMenu","Status","Enabled,Disabled","Explorer","Valid"
"Set-VisualFX","Status","Performance,Quality","Explorer","Valid"
"Set-ShowThumbnails","Status","Enabled,Disabled","Explorer","Valid"
"Set-LocalThumbnailsDB","Status","Enabled,Disabled","Explorer","Valid"
"Set-NetworkThumbnailsDB","Status","Enabled,Disabled","Explorer","Valid"
#set desired parameter KeyboardLayout to add or remove!!!,,,,"Comment"
"Set-KeyboardLayout","Status","Add,Remove","OS","Valid"
"Set-Numlock","Status","Enabled,Disabled","OS","Valid"
"Set-OneDriveStartUp","Status","Enabled,Disabled","OS","Valid"
"Set-OneDriveProvisioning","Status","Enabled,Disabled","OS","Valid"
"Set-ProvisionedPackages","Status","Enabled,Disabled","BloatWare","Valid"
"Set-Provisioned3PartyPackages","Status","Enabled,Disabled","BloatWare","Valid"
"Set-WindowsStoreProvisioning","Status","Enabled,Disabled","BloatWare","Valid"
"Set-ConsumerApps","Status","Enabled,Disabled","BloatWare","Valid"
"Set-XboxFeature","Status","Enabled,Disabled","BloatWare","Valid"
"Set-AdobeFlash","Status","Enabled,Disabled","Browser","Valid"
"Set-WindowsFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-MediaPlayerFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-PDFprinter","Status","Enabled,Disabled","Feature","Valid"
"Set-Faxprinter","Status","Enabled,Disabled","Feature","Valid"
"Set-XPSprinter","Status","Enabled,Disabled","Feature","Valid"
"Set-InternetExplorerFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-WorkFoldersFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-LinuxSubsystemFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-HyperVFeature","Status","Enabled,Disabled","Feature","Valid"
"Set-EdgeShortcutCreation","Status","Enabled,Disabled","Browser","Valid"
"Set-PhotoViewerAssociation","Status","Enabled,Disabled","OS","Valid"
"Set-PhotoViewerOpenWith","Status","Enabled,Disabled","OS","Valid"
"Set-SearchAppInStore","Status","Enabled,Disabled","Feature","Valid"
"Set-NewAppPrompt","Status","Enabled,Disabled","Explorer","Valid"
"Set-ControlPanelView","Status","Category,Large,Small","Explorer","Valid"
"Set-DEP","Status","OptOut,OptIn","Security","Valid"
"Set-ServerManagerOnLogin","Status","Enabled,Disabled","Server","Valid"
"Set-ShutdownTracker","Status","Enabled,Disabled","Server","Valid"
#set required values in function PasswordPolicy parameter set!!!,,,,"Comment"
"Set-PasswordPolicy","","","Security","Valid"
"Set-CtrlAltDelLogin","Status","Enabled,Disabled","Security","Valid"
"Set-IEEnhancedSecurity","Status","Enabled,Disabled","Security","Valid"
"Set-Audio","Status","Enabled,Disabled","OS","Valid"
"@ | ConvertFrom-Csv -Delimiter "," -Header $TweakHdr

#Script Functions
switch ($RedirectOutput){
	"Host" { Write-Host "Output will be immediately redirected to Host during script execution" }
	"Log" { 
		$script:LogFilePath = New-TemporaryFile
		Write-Output "results will be saved to $($script:LogFilePath)"
		}
	"Pipe" { $script:Output = @() }
	}

#output depending on global -RedirectOutput parameter
Function Out-put ( $InString ) {
Write-Verbose $InString
switch ($RedirectOutput){
	"Host" { Write-Host $InString }
	"Log" { Out-File $script:LogFilePath $InString -Append }
	"Pipe" { $script:Output += $InString }
	}
}

Function Test-Tweak {
param (
[object[]]$Tweaks
)
ForEach ($Tweak in $Tweaks){
	$objTweak = $Tweaks | ?{($_.Tweak -eq $Tweak.Tweak)}
	if ( $objTweak ) {
		if ( $objTweak.Parameter -eq $Tweak.Parameter ){
			if ( $objTweak.ParameterOption -contains $Tweak.ParameterOption ){ $Validation = $objTweak.Validation }
			else { $Validation = "Invalid ParameterOption" }
			}
		else { $Validation = "Wrong Parameter" }
		}
	else { $Validation = "Unknown Tweak" }
	$Tweak.Validation = $Validation
	$Tweak.Applied = $False
	}
return $Tweaks
}

# Generic Set-Remove Single RegKey Function
Function Set-SingleRegKey {
param(
[Parameter(Mandatory = $true)]$Status,
[string]$Description = "Generic Single Regkey Function",
[Parameter(Mandatory = $true)]$RegPath,
[Parameter(Mandatory = $true)]$RegKey,
[Parameter(Mandatory = $true)]
[ValidateSet("DWord","String")]$RegType,
[Parameter(Mandatory = $false)]$RegVal = "",
[switch]$RemoveRegKey = $false
)
if ($RemoveRegKey){
	try{
		Remove-ItemProperty -Path $RegPath -Name $RegKey -EA SilentlyContinue
		Out-put "Removing $($Description) registry setting(s)"
		}
	catch { Out-put "Failed to remove setting(s) in $($RegPath) $($RegKey)"}
	}
else {
	try{
		Out-put "setting $($Description) to $($Status)"
		If (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
		Set-ItemProperty -Path $RegPath -Name $RegKey -Type $RegType -Value $RegVal
		Write-Verbose "$($RegPath) $($RegKey) is set to $($RegVal)"
		}
	catch { Out-put "could not set value of $($RegVal) in $($RegPath) $($RegKey)"}
	}
}#Set-SingleRegKey

#Tweak Functions

Function Set-Telemetry {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Telemetry"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
"HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
)
$RegKey = @("AllowTelemetry")
Out-put "setting $($Description) to $($Status)"
switch ($Status){
	"Enabled"{$RegVal = 3}
	"Disabled" {$RegVal = 0}
	}
foreach ($RegPath in $RegPaths){
	try {
		If (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
		Set-ItemProperty -Path $RegPath -Name $RegKey[0] -Type DWord -Value $RegVal
		}
	catch { Out-put "could not set $($Description) to $($Status)" }
	}
}#Set-Telemetry

Function Set-WiFiSense {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "WiFi Auto Sense"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting",
"HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
)
$RegKeys = @("AllowTelemetry")
switch ($Status){
	"Enabled"{$RegVal = 1}
	"Disabled" {$RegVal = 0}
	}
Out-put "setting $($Description) to $($Status)"
foreach ($RegPath in $RegPaths){
	try {
		If (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
		Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Type DWord -Value $RegVal
		}
	catch { Out-put "could not set $($Description) to $($Status)" }
	}
}#Set-WiFiSense

Function Set-SmartScreen {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Edge SmartScreen and Phishing filter"
$edge = (Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge").PackageFamilyName
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost",
"HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter"
)
$RegKey = @(
"SmartScreenEnabled",
"EnableWebContentEvaluation",
"EnabledV9",
"PreventOverride"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -Type String -Value "RequireAdmin"
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKey[1] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[2] -Name $RegKey[2] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[2] -Name $RegKey[3] -ErrorAction SilentlyContinue
			}
		"Disabled" {
			$RegVal = 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -Type String -Value "Off"
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKey[1] -Type DWord -Value $RegVal
			If (!(Test-Path -Path $RegPaths[2] )) { New-Item -Path $RegPaths[2] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[2] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[3] -Type DWord -Value $RegVal
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)" }
}#Set-SmartScreen

Function Set-WebSearch {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Bing Search in Start Menu"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
)
$RegKey = @(
"BingSearchEnabled",
"DisableWebSearch"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKey[1] -ErrorAction SilentlyContinue
			}
		"Disabled" {
			$RegVal = 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -Type Dword -Value $RegVal
			If (!(Test-Path -Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKey[1] -Type DWord -Value $RegVal
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)" }
}#Set-WebSearch

Function Set-AppSuggestions {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Application Suggestions and Automatic Installation"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
)
$RegKeys = @(
"ContentDeliveryAllowed",
"OemPreInstalledAppsEnabled",
"PreInstalledAppsEnabled",
"PreInstalledAppsEverEnabled",
"SilentInstalledAppsEnabled",
"SubscribedContent-338389Enabled",
"SystemPaneSuggestionsEnabled",
"SubscribedContent-338388Enabled",
"DisableWindowsConsumerFeatures"
)
Out-put "setting $($Description) to $($Status)"
try{
	switch ($Status){
		"Disabled" {
			$RegVal = 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[7] -Type DWord -Value $RegVal
			If (!(Test-Path $RegPaths[1])) { New-Item -Path $RegPaths[1] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[8] -Type DWord -Value $RegVals[1]
			}
		"Enabled"{
			$RegVal = 1
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[7] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[8] -ErrorAction SilentlyContinue
			}
		}
	foreach ($RegKey in $RegKeys[0..6]){ Set-ItemProperty -Path $RegPaths[0] -Name $RegKey -Type DWord -Value $RegVal }
	}
catch { Out-put "could not set $($Description) to $($Status)" }
}#Set-AppSuggestions

Function Set-ActivityHistory {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Activity History"
$RegPaths = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")
$RegKeys = @(
"EnableActivityFeed",
"PublishUserActivities",
"UploadUserActivities"
)
Out-put "setting $($Description) to $($Status)"
try{
	switch ($Status){
		"Disabled" {
			$RegVal = 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[3] -Type DWord -Value $RegVal
			}
		"Enabled"{
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[3] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)" }
}#Set-ActivityHistory

Function Set-StartSuggestions {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Start Menu Suggestions"
$RegPaths = @("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")
$RegKeys = @(
"SystemPaneSuggestionsEnabled",
"SilentInstalledAppsEnabled"
)
Out-put "setting $($Description) to $($Status)"
switch ($Status){
	"Enabled"{$RegVal = 1}
	"Disabled" {$RegVal = 0}
	}
try {
	If (!(Test-Path $RegPaths[0])) { New-Item -Path $RegPaths[0] -Force | Out-Null }
	foreach ($RegKey in $RegKeys){ Set-ItemProperty -Path $RegPaths[0] -Name $RegKey -Type DWord -Value $RegVal	}
	}
catch { Out-put "could not set $($RegPaths[0]) to $($Status)" }
}#Set-StartSuggestions

# Disable Background application access - ie. if apps can download or update even when they aren't used
Function Set-BackgroundApps {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Background application access policy"
$RegPaths = @(Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications")
$RegKeys = @(
"Disabled",
"DisabledByUser"
)
Out-put "setting $($Description) to $($Status)"
try{
	switch ($Status){
		"Enabled"{
			foreach ($RegPath in $RegPaths){
				foreach ($RegKey in $RegKeys){
					Remove-ItemProperty -Path $RegPath -Name $RegKey -ErrorAction SilentlyContinue
					}
				}
			}
		"Disabled" {
			$RegVal = 1
			foreach ($RegPath in $RegPaths){
				foreach ($RegKey in $RegKeys){
					Set-ItemProperty -Path $RegPath -Name $RegKey -Type DWord -Value $RegVal
					}
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)" }
}#Set-BackgroundApps

Function Set-LockScreenSpotlight {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Advertising spots on lockscreen"
$RegPaths = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")
$RegKeys = @(
"RotatingLockScreenEnabled",
"RotatingLockScreenOverlayEnabled",
"SubscribedContent-338387Enabled"
)
Out-put "setting $($Description) to $($Status)"
try{
	switch ($Status){
		"Enabled"{
			$RegVal = 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value $RegVal
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -ErrorAction SilentlyContinue
			}
		"Disabled" {
			$RegVal = 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value $RegVal
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Type DWord -Value $RegVal
			}
		}
	}
catch { Out-put "could not set $($RegPaths[0]) to $($Status)" }
}#Set-LockScreenSpotlight

Function Set-LocationTracking {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Location Tracking"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}",
"HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
)
$RegKeys = @(
"SensorPermissionState",
"Status"
)
switch ($Status){
	"Enabled"{$RegVal = 1}
	"Disabled" {$RegVal = 0}
	}
Out-put "setting $($Description) to $($Status)"
foreach ($RegPath in $RegPaths){
	foreach ($RegKey in $RegKeys){
		try { Set-ItemProperty -Path $RegPath -Name $RegKey -Type DWord -Value $RegVal }
		catch { Out-put "could not set $($RegPath) $($RegKey) to $($Status)"}
		}
	}
}#Set-LocationTracking

Function Set-MapUpdates {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Automatic Map Updates"
RegPath = "HKLM:\SYSTEM\Maps"
RegKey = "AutoUpdateEnabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-MapUpdates

Function Set-Feedback {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Feedback"
RegPath = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
RegKey = "NumberOfSIUFInPeriod"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-Feedback

Function Set-TailoredExperiences {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Tailored Experiences"
RegPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
RegKey = "DisableTailoredExperiencesWithDiagnosticData"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TailoredExperiences

Function Set-AdvertisingID {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Advertising ID"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
RegKey = "Enabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-AdvertisingID

#Let websites provide locally relevant content by accessing my language list
Function Set-WebLangList {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "App access to Web Langage list"
RegPath = "HKCU:\Control Panel\International\User Profile"
RegKey = "HttpAcceptLanguageOptOut"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-WebLangList

Function Set-Cortana {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Cortana preferences"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Personalization\Settings",
"HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore",
"HKCU:\SOFTWARE\Microsoft\InputPersonalization",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
)
$RegKey = @(
"AcceptedPrivacyPolicy",
"RestrictImplicitTextCollection",
"RestrictImplicitInkCollection",
"HarvestContacts",
"AllowCortana",
"EnableWebContentEvaluation"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -ErrorAction SilentlyContinue
			If (!(Test-Path -Path $RegPaths[2] )) { New-Item -Path $RegPaths[2] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[1] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[2] -Type DWord -Value 0
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKey[3] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[3] -Name $RegKey[5] -ErrorAction SilentlyContinue
			}
		"Disabled" {
			foreach ($RegPath in $RegPaths){ If (!(Test-Path -Path $RegPath )) { New-Item -Path $RegPath -Force | Out-Null } }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKey[0] -Type Dword -Value 0
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKey[3] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[1] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKey[2] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[3] -Name $RegKey[4] -Type DWord -Value 0
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Cortana

Function Set-ErrorReporting {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Error Reporting"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
RegKey = "Disabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ErrorReporting

Function Set-P2PUpdate {
param(
[Parameter(Mandatory = $True)][ValidateSet("Local","Internet")]$Status
)
$Description = "P2P Updating Policy"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization"
)
$RegKeys = @(
"DODownloadMode",
"SystemSettingsDownloadMode"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Local"{
			foreach ($RegPath in $RegPaths){ If (!(Test-Path -Path $RegPath )) { New-Item -Path $RegPath -Force | Out-Null } }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type DWord -Value 3
			}
		"Internet" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-P2PUpdate

Function Set-CastToDevice {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = "" }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Cast to Device Context menu"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
RegKey = "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}"
RegType = "String"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-CastToDevice

Function Set-AutoLogger {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "AutoLogger log folder and file"
$LogPaths = @("$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger")
$LogFiles = @("AutoLogger-Diagtrack-Listener.etl")
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			icacls $LogPaths[0] /grant:r SYSTEM:`(OI`)`(CI`)F | Out-Null
			}
		"Disabled" {
			Remove-Item -Path $LogPaths[0] -Filter $LogFiles[0] -Force
			icacls $LogPaths[0] /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-AutoLogger

Function Set-DiagTrack {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Diagnostic Tracking Service"
$Services = @("DiagTrack")
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-Service $Services[0] -StartupType Automatic
			Start-Service $Services[0] -WarningAction SilentlyContinue
			}
		"Disabled" {
			Stop-Service $Services[0] -WarningAction SilentlyContinue
			Set-Service $Services[0] -StartupType Disabled
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DiagTrack

Function Set-WAPPush {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "WAP Push Service"
$Services = @("dmwappushservice")
$RegPaths = @("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice")
$RegKeys = @("DelayedAutoStart")
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-Service $Services[0] -StartupType Automatic
			Start-Service $Services[0] -WarningAction SilentlyContinue
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			}
		"Disabled" {
			Stop-Service $Services[0] -WarningAction SilentlyContinue
			Set-Service $Services[0] -StartupType Disabled
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-WAPPush

########### Service Tweaks ##########

Function Set-UAClevel {
param(
[Parameter(Mandatory = $True)][ValidateSet("Low","High")]$Status
)
$Description = "UAC level"
$RegPaths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")
$RegKeys = @(
"ConsentPromptBehaviorAdmin",
"PromptOnSecureDesktop"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Low"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 0
			}
		"High" {
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 5
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 1
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-UAClevel

# Allow sharing mapped drives between users
Function Set-SharingMappedDrives {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $True }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Sharing Mapped Drives"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
RegKey = "EnableLinkedConnections"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SharingMappedDrives

# Create Adminstrative shares on startup
Function Set-AdminShares {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Admin Shares"
RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
RegKey = "AutoShareWks"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-AdminShares

# Disable obsolete SMB 1.0 protocol
Function Set-SMBv1 {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "SMB v1"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{ Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force }
		"Disabled" { Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force }
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SMBv1

Function Set-SMBServer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "SMB Server"
try {
	switch ($Status){
		"Enabled"{ Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force }
		"Disabled" {
			Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
			Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SmbServer

Function Set-LLMNR {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Link-Local Multicast Name Resolution (LLMNR) protocol"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
RegKey = "EnableMulticast"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-LLMNR

Function Set-CurrentNetworkProfile {
param(
[Parameter(Mandatory = $True)][ValidateSet("Private","Public")]$Status
)
$Description = "Current Network profile"
Out-put "setting $($Description) to $($Status)"
try { Set-NetConnectionProfile -NetworkCategory $Status }
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-CurrentNetworkProfile

Function Set-UnknownNetworkProfile {
param(
[Parameter(Mandatory = $True)][ValidateSet("Private","Public")]$Status
)
switch ($Status){
	"Public"{ $RemoveRegKey = $True }
	"Private" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Unknown Network profile"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24"
RegKey = "Category"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-UnknownNetworkProfile

Function Set-NetDevicesAutoInst {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Automatic installation of network devices"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private"
RegKey = "AutoSetup"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-NetDevicesAutoInst

Function Set-FolderAccessControl {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Help = "Controlled Folder Access (Defender Exploit Guard feature) - Not applicable to Server"
$Description = "Controlled Folder Access"
Out-put "setting $($Description) to $($Status)"
try { Set-MpPreference -EnableControlledFolderAccess $Status }
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-FolderAccessControl

Function Set-Firewall {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Windows Firewall"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
RegKey = "EnableFirewall"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-Firewall

Function Set-WindowsDefender {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Windows Defender"
$RegPaths = @(
"HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
$RegKeys = @(
"DisableAntiSpyware",
"SecurityHealth",
"WindowsDefender"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
				Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[2] -ErrorAction SilentlyContinue
				}
			ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
				Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -ErrorAction SilentlyContinue
				}
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
				Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[2] -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
				}
			ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
				Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-WindowsDefender

Function Set-WindowsDefenderCloud {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Windows Defender Cloud"
$RegPaths = @( "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" )
$RegKeys = @(
"SpynetReporting",
"SubmitSamplesConsent"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 2
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-WindowsDefenderCloud

Function Set-F8BootMenu {
param(
[Parameter(Mandatory = $True)][ValidateSet("Legacy","Standard")]$Status
)
$Description = "F8 boot menu options"
Out-put "setting $($Description) to $($Status)"
try { bcdedit /set `{current`} bootmenupolicy $Status | Out-Null }
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-F8BootMenu

Function Set-DEPOption {
param(
[ValidateSet("OpIn","OptOut")]$Status
)
$Description = "Data Execution Prevention"
bcdedit /set `{current`} nx $Status | Out-Null
Out-put "setting $($Description) to $($Status)"
}#Set-DEPOption

Function Set-CIMemoryIntegrity {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $True }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Core Isolation Memory Integrity"
RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
RegKey = "Enabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
#supported on Win10 v1803 or greater
if ([System.Environment]::OSVersion.Version.Build -lt 17134) {
	Out-Put "$($SingleRegKeyProps["Description"]) not supported on current OS version"
	}
else { Set-SingleRegKey @SingleRegKeyProps }
}#Set-CIMemoryIntegrity

Function Set-DotNetStrongCrypto {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = ".NET strong cryptography"
$Help = @"
Enable strong cryptography for .NET Framework (version 4 and above)
https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
"@
$RegPaths = @("HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319","HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319")
$RegKeys = @( "SchUseStrongCrypto" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Type DWord -Value 1
			}
		"Disabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DotNetStrongCrypto

Function Set-ScriptHost {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Windows Script Host"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings"
RegKey = "Enabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ScriptHost

Function Set-MeltdownCompatFlag {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $True }
	"Enabled" { $RegVal = 0 }
	}
$Help = @"
Enable Meltdown (CVE-2017-5754) compatibility flag - Required for January 2018 and all subsequent Windows updates
This flag is normally automatically enabled by compatible antivirus software (such as Windows Defender).
Use the tweak only if you have confirmed that your AV is compatible but unable to set the flag automatically or if you don't use any AV at all.

For details see: https://support.microsoft.com/en-us/help/4072699/january-3-2018-windows-security-updates-and-antivirus-software
"@
$SingleRegKeyProps =@{
Status = $Status
Description = "Meltdown (CVE-2017-5754) compatibility flag"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat"
RegKey = "cadca5fe-87d3-4b96-b7fb-a231484277cc"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-MeltdownCompatFlag

Function Set-UpdateMSRT {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Malicious Software Removal Tool Update"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\MRT"
RegKey = "DontOfferThroughWUAU"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-UpdateMSRT

Function Set-UpdateDrivers {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Drivers via Windows Update"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata"
)
$RegKeys = @(
"ExcludeWUDriversInQualityUpdate",
"PreventDeviceMetadataFromNetwork",
"DontPromptForWindowsUpdate",
"DontSearchWindowsUpdate",
"DriverUpdateWizardWuSearchEnabled"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[3] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[4] -Type DWord -Value 0
			If (!(Test-Path -Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Type DWord -Value 1
			If (!(Test-Path -Path $RegPaths[2] )) { New-Item -Path $RegPaths[2] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKeys[1] -Type DWord -Value 1
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[3] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[4] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[2] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-UpdateDrivers

Function Set-WindowsUpdateAlert {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Allow FullScreen Windows Update Alert Overlay"
$WUSAlertFiles = @(
"$Env:windir\System32\musnotification.exe",
"$Env:windir\System32\musnotificationux.exe"
)
try {
	switch ($Status){
		"Enabled" {
			$owner = New-Object System.Security.Principal.NTAccount("NT SERVICE\TrustedInstaller")
			ForEach($File In $WUSAlertFiles){
				ICACLS $File /remove:d '"everyone"' | out-null
				ICACLS $File /grant ("Everyone" + ':(OI)(CI)F') | out-null
				$acl = get-acl $File
				$acl.SetOwner($owner) | out-null
				set-acl $File $acl | out-null
				ICACLS $File /remove:g '"everyone"' | out-null
				}
			}
		"Disabled" {
			ForEach($File In $WUSAlertFiles){
				takeown /f $File | out-null
				ICACLS $File /deny '"everyone":(F)' | out-null
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-WindowsUpdateAlert

Function Set-UpdateRestart {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Windows Update Restart"
$RegPaths = @( "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" )
$RegKeys = @(
"NoAutoRebootWithLoggedOnUsers",
"AUPowerManagement"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 0
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-UpdateRestart

Function Set-HomeGroupServices {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Help = "Stop and disable Home Groups services - Not applicable to Server"
$Description = "Home Group Services"
$Services = @(
"HomeGroupListener",
"HomeGroupProvider"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			foreach ($Service in $Services){ Set-Service $Service -StartupType Manual }
			Start-Service $Services[1] -WarningAction SilentlyContinue
			}
		"Disabled" {
			foreach ($Service in $Services){
				Stop-Service $Service -WarningAction SilentlyContinue
				Set-Service $Service -StartupType Disabled
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-HomeGroupServices

Function Set-SharedExperiences {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Shared Experiences"
$RegPaths = @( "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" )
$RegKeys = @(
"EnableCdp",
"EnableMmx"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 0
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SharedExperiences

Function Set-RemoteAssistance {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RegVal = 1 }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Remote Assistance"
RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"
RegKey = "fAllowToGetHelp"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-RemoteAssistance

Function Set-RemoteDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Authenticated Remote Desktop"
$RegPaths = @(
"HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server",
"HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
)
$RegKeys = @(
"fDenyTSConnections",
"UserAuthentication"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ $RegVal = 0 }
		"Enabled" { $RegVal = 1 }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type DWord -Value $RegVal
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-RemoteDesktop

Function Set-AutoPlay {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RegVal = 0 }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "AutoPlay"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"
RegKey = "DisableAutoplay"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-AutoPlay

Function Set-AutoRun {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 255 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "AutoRun on All Drives"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
RegKey = "NoDriveTypeAutoRun"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-AutoRun

Function Set-StorageSense {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Automatic Disk Cleanup"
$RegPaths = @( "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" )
$RegKeys = @(
"01",
"04"
"08"
"32"
"StoragePoliciesNotified"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[3] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[4] -Type DWord -Value 1
			}
		"Disabled" {
			Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-StorageSense

Function Set-Defragmentation {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Scheduled Disk Defragmentation Task"
$TaskNames = @( "\Microsoft\Windows\Defrag\ScheduledDefrag" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ Disable-ScheduledTask -TaskName $TaskNames[0] | Out-Null }
		"Enabled" {	Enable-ScheduledTask -TaskName $TaskNames[0] | Out-Null }
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Defragmentation

Function Set-SuperFetch {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Help ="Set Superfetch service - Not applicable to Server"
$Description = "SuperFetching"
$Services = @( "SysMain" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-Service $Services[0] -StartupType Automatic
			Start-Service $Services[0] -WarningAction SilentlyContinue
			}
		"Disabled" {
			Stop-Service $Services[0] -WarningAction SilentlyContinue
			Set-Service $Services[0] -StartupType Disabled
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SuperFetch

Function Set-Indexing {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Search Indexing Service"
$Services = @("WSearch")
$RegPaths = @("HKLM:\SYSTEM\CurrentControlSet\Services\WSearch")
$RegKeys = @("DelayedAutoStart")
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Set-Service $Services[0] -StartupType Automatic
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Start-Service $Services[0] -WarningAction SilentlyContinue
			}
		"Disabled" {
			Stop-Service $Services[0] -WarningAction SilentlyContinue
			Set-Service $Services[0] -StartupType Disabled
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Indexing

Function Set-BIOSTimeZone {
param(
[Parameter(Mandatory = $True)][ValidateSet("UTC","Local")]$Status
)
switch ($Status){
	"UTC"{ $RegVal = 1 }
	"Local" { $RemoveRegKey = $true }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "BIOS Time Zone"
RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
RegKey = "RealTimeIsUniversal"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-BIOSTimeZone

Function Set-Hibernation {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Hibernation"
$Help= @"
Enable Hibernation
Do not use on Server if Hyper-V service set to Automatic
it may lead to BSODs (Win10 with Hyper-V is fine)
"@
$RegPaths = @(
"HKLM:\System\CurrentControlSet\Control\Session Manager\Power",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings"
)
$RegKeys = @(
"HibernateEnabled",
"ShowHibernateOption"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ $RegVal = 0 }
		"Enabled" { $RegVal = 1 }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	If (!(Test-Path -Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] -Force | Out-Null }
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type DWord -Value $RegVal
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Hibernation

Function Set-SleepButton {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Sleep button action"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" )
$RegKeys = @( "ShowSleepOption" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ $RegVal = 0	}
		"Enabled" { $RegVal = 1 }
		}
	If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION $RegVal
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION $RegVal
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SleepButton

Function Set-SleepTimeout {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Display Sleep Time Out"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
				powercfg /X monitor-timeout-ac 0
				powercfg /X monitor-timeout-dc 0
				powercfg /X standby-timeout-ac 0
				powercfg /X standby-timeout-dc 0
			}
		"Enabled" {
				powercfg /X monitor-timeout-ac 10
				powercfg /X monitor-timeout-dc 5
				powercfg /X standby-timeout-ac 30
				powercfg /X standby-timeout-dc 15
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-SleepTimeout

Function Set-FastStartUp {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Fast Startup"
RegPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
RegKey = "HiberbootEnabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-FastStartUp

########### UI Tweaks ##########

Function Set-ActionCenter {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "ActionCenter"
$RegPaths = @(
"HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"
)
$RegKeys = @(
"DisableNotificationCenter",
"ToastEnabled"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type DWord -Value 0
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ActionCenter

Function Set-AccountProtectionWarning {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
# Hide Account Protection warning in Defender about not using a Microsoft account
switch ($Status){
	"Disabled"{ $RegVal = 1 }
	"Enabled" { $RemoveRegKey = $true }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Microsoft Account Protection warning"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State"
RegKey = "AccountProtection_MicrosoftAccount_Disconnected"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-AccountProtectionWarning

Function Set-LockScreen {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 1 }
	"Enabled" { $RemoveRegKey = $true }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "LockScreen"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
RegKey = "NoLockScreen"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-LockScreen

# Lock screen - Applicable to RS1 (1607) or newer
Function Set-LockScreenRS1 {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "LockScreen RS1"
$TaskNames = @("LockScreen Status")
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			$service = New-Object -com Schedule.Service
			$service.Connect()
			$task = $service.NewTask(0)
			$task.Settings.DisallowStartIfOnBatteries = $false
			$trigger = $task.Triggers.Create(9)
			$trigger = $task.Triggers.Create(11)
			$trigger.StateChange = 8
			$action = $task.Actions.Create(0)
			$action.Path = "reg.exe"
			$action.Arguments = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
			$service.GetFolder("\").RegisterTaskDefinition($TaskNames[0], $task, 6, "NT AUTHORITY\SYSTEM", $null, 4) | Out-Null
			}
		"Enabled" {
			Unregister-ScheduledTask -TaskName $TaskNames[0] -Confirm:$false -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-LockScreenRS1

Function Set-LockScreenNetworkConnection {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 1 }
	"Enabled" { $RemoveRegKey = $true }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Network connection on LockScreen"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
RegKey = "DontDisplayNetworkSelectionUI"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-LockScreenNetworkConnection

Function Set-LockScreenShutdownMenu {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Shutdown Menu on LockScreen"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
RegKey = "ShutdownWithoutLogon"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-LockScreenShutdownMenu

Function Set-StickyKeys {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = "506" }
	"Enabled" { $RegVal = "510" }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Stickey Keys prompt"
RegPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
RegKey = "Flags"
RegType = "String"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-StickyKeys

Function Set-TaskManagerDetails {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Detail view in TaskManager"
$RegPaths = @( "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" )
$RegKeys = @( "Preferences" )
$preferences = New-Object PSObject
Out-put "setting $($Description) to $($Status)"
try {
	If (!(Test-Path -Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] -Force | Out-Null }
	$preferences = Get-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
	switch ($Status){
		"Enabled"{
			If (!($preferences.Preferences)) {
				$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
				While (!($preferences)) {
					Start-Sleep -m 250
					$preferences = Get-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
					}
				Stop-Process $taskmgr
				}
			$preferences.Preferences[28] = 0
			}
		"Disabled" {
			If ($preferences.Preferences) { $preferences.Preferences[28] = 1 }
			}
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type Binary -Value $Preferences.Preferences
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-TaskManagerDetails

# Show file operations details
Function Set-FileOperationsDetails {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $true }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Details for File Operations"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"
RegKey = "EnthusiastMode"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-FileOperationsDetails

Function Set-FileDeleteConfirm {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $true }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Ask Confirmation for File Deletion"
RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
RegKey = "ConfirmFileDelete"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-FileDeleteConfirm

Function Set-PreviousFileVersions {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "ShadowCopy of previous folder/file versions"
$RegPaths = @( 
"HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
"HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
"HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
"HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ foreach ( $RegPath in $RegPaths ) { Remove-Item -Path $RegPath -Recurse -Force } }
		"Enabled" { foreach ( $RegPath in $RegPaths ) { New-Item -Path $RegPath -Force } }
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PreviousFileVersions

Function Set-IncludeInLibrary {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled" { $RegVal = "" }
	"Disabled" { $RegVal = "{3dad6c5d-2167-4cae-9914-f99e41c12cfa}" }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Include In Library"
RegPath = "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location"
RegKey = "(Default)"
RegType = "String"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
}#Set-IncludeInLibrary

Function Set-PinToStart {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Pin items to Start Menu"
$RegPaths = @(
"HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}",
"HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}",
"HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen",
"HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen",
"HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen",
"HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen"
)
$RegKeys = @( "(Default)" )
$RegVals = @(
"Taskband Pin",
"Start Menu Pin",
"{470C0EBD-5D73-4d58-9CED-E91E22E23282}"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			New-Item -Path $RegPaths[0] -Force
			Set-ItemProperty -LiteralPath $RegPaths[0] -Name $RegKeys[0] -Value $RegVals[0] -Type String
			New-Item -Path $RegPaths[1] -Force
			Set-ItemProperty -LiteralPath $RegPaths[1] -Name $RegKeys[0] -Value $RegVals[1] -Type String
			foreach ( $RegPath in $RegPaths[2..5]) {
				Set-ItemProperty -LiteralPath $RegPath -Name $RegKeys[0] -Value $RegVals[2] -Type String
				}
			}
		"Disabled"{
			Remove-Item -LiteralPath $RegPaths[0] -Force
			Remove-Item -LiteralPath $RegPaths[1] -Force
			foreach ( $RegPath in $RegPaths[2..5]) {
				Set-ItemProperty -LiteralPath $RegPath -Name $RegKeys[0] -Value "" -Type String
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PinToStart

Function Set-PinToQuickAccess {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Pin items to Quick Access folder"
$RegPaths = @(
"HKCR:\Folder\shell\pintohome",
"HKCR:\Folder\shell\pintohome\command",
"HKLM:\SOFTWARE\Classes\Folder\shell\pintohome",
"HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command"
)
$RegKeys = @(
"MUIVerb",
"AppliesTo",
"DelegateExecute"
)
$RegVals = @(
"@shell32.dll,-51377",
'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}" AND System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}" AND System.IsFolder:=System.StructuredQueryType.Boolean#True',
"{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			if (-not (Test-Path $RegPaths[0])){New-Item -Path $RegPaths[0] -Force}
			New-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVals[0]
			New-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Value $RegVals[1]
			if (-not (Test-Path $RegPaths[1])){New-Item -Path $RegPaths[1] -Force}
			New-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Value $RegVals[2]
			if (-not (Test-Path $RegPaths[2])){New-Item -Path $RegPaths[2] -Force}
			New-ItemProperty -Path $RegPaths[2] -Name $RegKeys[0] -Value $RegVals[0]
			New-ItemProperty -Path $RegPaths[2] -Name $RegKeys[1] -Value $RegVals[1]
			if (-not (Test-Path $RegPaths[3])){New-Item -Path $RegPaths[3] -Force}
			New-ItemProperty -Path $RegPaths[3] -Name $RegKeys[2] -Value $RegVals[2]
			}
		"Disabled"{
			Remove-Item -LiteralPath $RegPaths[0] -Recurse -Force
			Remove-Item -LiteralPath $RegPaths[1] -Recurse -Force
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PinToQuickAccess

Function Set-RecentItemsInQuickAccess {
param(
[Parameter(Mandatory = $True)][ValidateSet("Show","Hidden","Removed")]$Status
)
$Description = "Recent items in Quick Access"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
"HKLM:\$Path\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}",
"HKLM:\SOFTWARE\Wow6432Node\$Path\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}"
)
$RegKeys = @(
"(Default)"
"ShowRecent"
)
$RegVals = @(
"Recent Items Instance Folder"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Show"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Value 1 -Type DWord
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVals[0] -Type String			
			Set-ItemProperty -Path $RegPaths[2] -Name $RegKeys[0] -Value $RegVals[0] -Type String
			}
		"Hidden"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Value 0 -Type DWord
			}
		"Removed"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Value 0 -Type DWord
			Remove-Item -Path $RegPaths[1] -Recurse -Force
			Remove-Item -Path $RegPaths[2] -Recurse -Force
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-RecentItemsInQuickAccess

Function Set-FrequentFoldersInQuickAccess {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled" { $Regval = 1 }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Frequent folders in Quick Access"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
RegKey = "ShowFrequent"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-FrequentFoldersInQuickAccess

Function Set-WindowsContentWhileDragging {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled" { $Regval = 1 }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Show windows content while dragging"
RegPath = "HKCU:\Control Panel\Desktop"
RegKey = "DragFullWindows"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-WindowsContentWhileDragging

Function Set-ShareWith {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Share items context menu"
$RegPaths = @(
"HKCR:\*\shellex\ContextMenuHandlers\Sharing",
"HKCR:\Directory\shellex\ContextMenuHandlers\Sharing",
"HKCR:\Directory\shellex\CopyHookHandlers\Sharing",
"HKCR:\Directory\shellex\PropertySheetHandlers\Sharing",
"HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing",
"HKCR:\Drive\shellex\ContextMenuHandlers\Sharing",
"HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing"
)
$RegKey = "(Default)"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" }
		"Disabled" { $RegVal = "" }
		}
	foreach ( $RegPath in $RegPaths ) {
		Set-ItemProperty -Path $RegPath -Name $RegKey -Value $RegVal -Type String
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ShareWith

Function Set-SendTo {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RegVal = "{7BA4C740-9E81-11CF-99D3-00AA004AE837}" }
	"Disabled" { $RemoveRegKey = $True }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "SendTo Context Menu"
RegPath = "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo"
RegKey = "(Default)"
RegType = "String"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SendTo

Function Set-OpenWithStoreApp {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $True }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Search StoreApp for unknonw extension"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
RegKey = "NoUseStoreOpenWith"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-OpenWithStoreApp

Function Set-WinXPowerShell {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RegVal = 0 }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Replace Command with PowerShell in WinX menu"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "DontUsePowerShellOnWinX"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-WinXPowerShell

Function Set-BatteryIcon {
param(
[Parameter(Mandatory = $True)][ValidateSet("NewStyle","OldStyle")]$Status
)
switch ($Status){
	"OldStyle"{ $RegVal = 1 }
	"NewStyle" { $RemoveRegKey = $True }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Battery icon in Systray"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell"
RegKey = "UseWin32BatteryFlyout"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-BatteryIcon

Function Set-ClockIcon {
param(
[Parameter(Mandatory = $True)][ValidateSet("NewStyle","OldStyle")]$Status
)
switch ($Status){
	"OldStyle"{ $RegVal = 1 }
	"NewStyle" { $RemoveRegKey = $True }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Clock icon in Systray"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell"
RegKey = "UseWin32TrayClockExperience"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ClockIcon

Function Set-VolumeIcon {
param(
[Parameter(Mandatory = $True)][ValidateSet("NewStyle","OldStyle")]$Status
)
switch ($Status){
	"OldStyle"{ $RegVal = 0 }
	"NewStyle" { $RemoveRegKey = $True }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Volume icon in Systray"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC"
RegKey = "EnableMtcUvc"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-VolumeIcon

Function Set-TaskbarSearchOption {
param(
[Parameter(Mandatory = $True)][ValidateSet("Box","Icon","Hidden")]$Status
)
switch ($Status){
	"Box"{ $RegVal = 2 }
	"Icon" { $RegVal = 1 }
	"Hidden" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Searchbox on Taskbar"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
RegKey = "SearchboxTaskbarMode"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TaskbarSearchOption

Function Set-TaskViewButton {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Taskview Button on Taskbar"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "ShowTaskViewButton"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TaskViewButton

Function Set-TaskbarIconSize {
param(
[Parameter(Mandatory = $True)][ValidateSet("Small","Large")]$Status
)
switch ($Status){
	"Large"{ $RemoveRegKey = $true }
	"Small" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Icon size on Taskbar"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "TaskbarSmallIcons"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TaskbarIconSize

Function Set-TaskbarCombineTitles {
param(
[Parameter(Mandatory = $True)][ValidateSet("WhenFull","Never","Always")]$Status
)
$Description = "Group Taskbar Titles"
$RegPaths = @( "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" )
$RegKeys = @(
"TaskbarGlomLevel",
"MMTaskbarGlomLevel"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Never"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 2
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 2
			}
		"WhenFull"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 1
			}
		"Always" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-TaskbarCombineTitles

Function Set-TaskbarPeopleIcon {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "People icon on Taskbar"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
RegKey = "PeopleBand"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TaskbarPeopleIcon

Function Set-MultiDisplayTaskbar {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Display Taskbar on all monitors"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "MMTaskbarEnabled"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-MultiDisplayTaskbar

Function Set-DisplayTaskbarButtons {
param(
[Parameter(Mandatory = $True)][ValidateSet("All","Open","MainAndOpen")]$Status
)
switch ($Status){
	"Open"{ $RegVal = 2 }
	"MainAndOpen" { $RegVal = 1 }
	"All" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Show Taskbar Button for program(s) on Display: "
RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "MMTaskbarMode"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TaskbarSearchOption

Function Set-TrayIcons {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RemoveRegKey = $true }
	"Enabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Tray icons on Taskbar"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
RegKey = "EnableAutoTray"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-TrayIcons

Function Set-SecondHandInClock {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Display Seconds in Clock Face"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "ShowSecondsInSystemClock"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SecondHandInClock

Function Set-LastActiveClick {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Last Active Click"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "LastActiveClick"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-LastActiveClick

Function Set-DisplayKnownExtensions {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 1 }
	"Enabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Display of known extensions"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "HideFileExt"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-DisplayKnownExtensions

Function Set-ShowHiddenSystemFiles {
param(
[Parameter(Mandatory = $True)][ValidateSet("None","Hidden","System")]$Status
)
$Description = "Show hidden system files"
$RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$RegKeys = @(
"Hidden",
"SuperHidden"
)
switch ($Status){
	"None" { 
		Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Value 2 -Type DWord
		Set-ItemProperty -Path $RegPath -Name $RegKeys[1] -Value 0 -Type DWord
		}
	"Hidden"{ 
		Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Value 1 -Type DWord
		Set-ItemProperty -Path $RegPath -Name $RegKeys[1] -Value 0 -Type DWord
		}
	"System" { Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Value 1 -Type DWord }
	}
}#Set-ShowHiddenSystemFiles

# Hide item selection checkboxes
Function Set-SelectCheckboxes {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 2 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Display checkboxes next to files"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "AutoCheckSelect"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SelectCheckboxes

Function Set-ShowSyncNotifications {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Synchronization Notifications"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "ShowSyncProviderNotifications"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ShowSyncNotifications

Function Set-ShowRecentShortcuts {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Shortcuts of Recent files in Computer folder"
$RegPaths = @( "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" )
$RegKeys = @( "ShowRecent","ShowFrequent" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value 0
			}
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ShowRecentShortcuts

Function Set-SetExplorerDefaultView {
param(
[Parameter(Mandatory = $True)][ValidateSet("ThisPC","QuickAccess")]$Status
)
switch ($Status){
	"QuickAccess"{ $RemoveRegKey = $true }
	"ThisPC" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Default Explorer view"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "LaunchTo"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SetExplorerDefaultView

Function Set-ThisPCIconOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "ThisPC Icon On Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKeys = @( "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			foreach ($RegPath in $RegPaths){
				If (!(Test-Path -Path $RegPath )) { New-Item -Path $RegPath -Force | Out-Null }
				Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Type DWord -Value 0
				}
			}
		"Disabled" {
			foreach ($RegPath in $RegPaths){
				Remove-ItemProperty -Path $RegPath -Name $RegKeys[0] -ErrorAction SilentlyContinue
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ThisPCIconOnDesktop

Function Set-ShowUserFolderOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "User folder Icon On Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKeys = @( "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			foreach ($RegPath in $RegPaths){
				If (!(Test-Path -Path $RegPath )) { New-Item -Path $RegPath -Force | Out-Null }
				Set-ItemProperty -Path $RegPath -Name $RegKeys[0] -Type DWord -Value 0
				}
			}
		"Disabled" {
			foreach ($RegPath in $RegPaths){
				Remove-ItemProperty -Path $RegPath -Name $RegKeys[0] -ErrorAction SilentlyContinue
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ShowUserFolderOnDesktop

Function Set-DesktopInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Desktop icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{ If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null } }
		"Disabled" { Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue } }
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DesktopInThisPC

Function Set-DesktopIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Desktop icon in Explorer Namespace"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
)
$RegKeys = @("ThisPCPolicy")

Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value "Hide" -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value "Hide" -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DesktopIconInExplorer

Function Set-DocumentsIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Documents icon in Explorer Namespace"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"
)
$RegKeys = @("ThisPCPolicy")

Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DocumentsIconInExplorer

Function Set-DocumentsIconInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Documents Icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			foreach ($RegPath in $RegPaths){
				If (!(Test-Path $RegPath )) { New-Item -Path $RegPath | Out-Null }
				}
			}
		"Disabled" {
			foreach ($RegPath in $RegPaths){
				Remove-Item -Path $RegPath -Recurse -ErrorAction SilentlyContinue
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DocumentsIconInThisPC

Function Set-DownloadsIconInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Downloads Icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null }
			If (!(Test-Path $RegPaths[1] )) { New-Item -Path $RegPaths[0] | Out-Null }
			}
		"Disabled" {
			Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue
			Remove-Item -Path $RegPaths[1] -Recurse -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DownloadsIconInThisPC

Function Set-DownloadsIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Downloads Icon in Explorer"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" )
$RegKeys = @( "ThisPCPolicy" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DownloadsIconInExplorer

Function Set-MusicIconInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Music Icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{ If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null } }
		"Disabled" { Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue } }
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-MusicIconInThisPC

Function Set-MusicIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Documents icon in Explorer Namespace"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"
)
$RegKeys = @("ThisPCPolicy")

Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-MusicIconInExplorer

# Hide Pictures icon from This PC
Function Set-PicturesIconInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Pictures Icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"; "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null }
			If (!(Test-Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] | Out-Null }
			}
		"Disabled" {
			Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue
			Remove-Item -Path $RegPaths[1] -Recurse -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PicturesIconInThisPC

Function Set-PicturesIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Pictures Icon in Explorer"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" )
$RegKeys = @( "ThisPCPolicy" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PicturesIconInExplorer

Function Set-VideosIconInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Videos icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{ If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null } }
		"Disabled" { Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue } }
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-VideosIconInThisPC

Function Set-VideosIconInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Videos Icon in Explorer"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" )
$RegKeys = @( "ThisPCPolicy" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = "Show" }
		"Disabled" { $RegVal = "Hide" }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal -Type String
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-VideosIconInExplorer

Function Set-3DObjectsInThisPC {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "3D icon in ThisPC"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{ If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] | Out-Null } }
		"Disabled" { Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue } }
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-3DObjectsInThisPC

Function Set-3DObjectsInExplorer {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Downloads Icon in Explorer"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" )
$RegKeys = @( "ThisPCPolicy" )
$RegVal = "Hide"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" {
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0]
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0]
			}
		"Disabled" {
			If (!(Test-Path $RegPaths[0] )) { New-Item -Path $RegPaths[0] }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Value $RegVal  -Type String
			If (!(Test-Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Value $RegVal -Type String
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-3DObjectsInExplorer

Function Set-NetworkOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Network Icon on Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKey = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = 0 }
		"Disabled" { $RegVal = 1 }
		}
	Foreach ( $RegPath in $RegPaths ){
		If (!(Test-Path $RegPath )) { New-Item -Path $RegPath }
		Set-ItemProperty -Path $RegPath -Name $RegKey -Value $RegVal -Type DWord
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-NetworkOnDesktop

Function Set-RecycleBinOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "RecycleBin Icon on Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKey = "{645FF040-5081-101B-9F08-00AA002F954E}"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = 0 }
		"Disabled" { $RegVal = 1 }
		}
	Foreach ( $RegPath in $RegPaths ){
		If (!(Test-Path $RegPath )) { New-Item -Path $RegPath }
		Set-ItemProperty -Path $RegPath -Name $RegKey -Value $RegVal -Type DWord
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-RecycleBinOnDesktop

Function Set-UsersFolderOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Users Folder Icon on Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKey = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = 0 }
		"Disabled" { $RegVal = 1 }
		}
	Foreach ( $RegPath in $RegPaths ){
		If (!(Test-Path $RegPath )) { New-Item -Path $RegPath }
		Set-ItemProperty -Path $RegPath -Name $RegKey -Value $RegVal -Type DWord
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-UsersFolderOnDesktop

Function Set-ControlPanelOnDesktop {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "ControlPanel Folder Icon on Desktop"
$RegPaths = @(
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
)
$RegKey = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled" { $RegVal = 0 }
		"Disabled" { $RegVal = 1 }
		}
	Foreach ( $RegPath in $RegPaths ){
		If (!(Test-Path $RegPath )) { New-Item -Path $RegPath }
		Set-ItemProperty -Path $RegPath -Name $RegKey -Value $RegVal -Type DWord
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-ControlPanelOnDesktop

Function Set-MostUsedAppsInStartMenu {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Show most used apps in Start menu"
RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "Start_TrackProgs"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-MostUsedAppsInStartMenu

Function Set-RecentItemsInStartMenu {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled"{ $RegVal = 0 }
	"Enabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Show recently used items in Start menu"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
RegKey = "Start_TrackDocs"
RegType = "DWord"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-RecentItemsInStartMenu

Function Set-VisualFX {
param(
[Parameter(Mandatory = $True)][ValidateSet("Performance","Quality")]$Status
)
#-PerFormace disables animations, transparency etc. but leaves font smoothing and miniatures enabled
$Description = "Visual FX rendering"
$RegPaths = @(
"HKCU:\Control Panel\Desktop",
"HKCU:\Control Panel\Desktop\WindowMetrics",
"HKCU:\Control Panel\Keyboard",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects",
"HKCU:\Software\Microsoft\Windows\DWM"
)
$RegKeys = @(
"DragFullWindows",
"MenuShowDelay",
"UserPreferencesMask",
"MinAnimate",
"KeyboardDelay",
"ListviewAlphaSelect",
"ListviewShadow",
"TaskbarAnimations",
"VisualFXSetting",
"EnableAeroPeek"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Performance"{ $RegVals = @(0,0,[byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00),3) }
		"Quality" {	$RegVals = @(1,400,[byte[]](0x9E,0x1E,0x07,0x80,0x12,0x00,0x00,0x00),3)	}
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type String -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type String -Value $RegVals[1]
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[2] -Type Binary -Value $RegVals[2]
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[3] -Type String -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[2] -Name $RegKeys[4] -Type DWord -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[3] -Name $RegKeys[5] -Type DWord -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[3] -Name $RegKeys[6] -Type DWord -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[3] -Name $RegKeys[7] -Type DWord -Value $RegVals[0]
	Set-ItemProperty -Path $RegPaths[4] -Name $RegKeys[8] -Type DWord -Value $RegVals[3]
	Set-ItemProperty -Path $RegPaths[5] -Name $RegKeys[9] -Type DWord -Value $RegVals[0]
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-VisualFX

Function Set-ShowThumbnails {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RegVal = 0 }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Show Thumbnails as icon"
RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
RegKey = "IconsOnly"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ShowThumbnails

Function Set-LocalThumbnailsDB {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Save ThumbnailsDB on local system"
$RegPaths = @( "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" )
$RegKeys = @( "DisableThumbnailCache" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1 }
		"Enabled" { Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue }
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-LocalThumbnailsDB

Function Set-NetworkThumbnailsDB {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Save ThumbnailsDB in networkfolder(s)"
$RegPaths = @( "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" )
$RegKeys = @( "DisableThumbsDBOnNetworkFolders" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1 }
		"Enabled" { Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue }
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-NetworkThumbnailsDB

Function Set-KeyboardLayout {
param(
[Parameter(Mandatory = $True)][ValidateSet("Add","Remove")]$Status,
[string[]]$KeyboardLayout = "en-US"
)
$Description = "Keyboard layout(s)"
try {
	$langs = Get-WinUserLanguageList
	switch ($Status){
		"Add"{
			foreach ($Keyboard in $KeyboardLayout){
				$langs.Add($Keyboard)
				Set-WinUserLanguageList $langs -Force
				}
			}
		"Remove"{
			foreach ($Keyboard in $KeyboardLayout){
				Set-WinUserLanguageList ($langs | Where-Object {$_.LanguageTag -ne $Keyboard}) -Force
				}
			}
		}
	$langs = (Get-WinUserLanguageList).LocalizedName -join ", "
	Out-put "current $($Description) set to $($langs)"
	}
catch { Out-put "could not $($Status) $($Description)"}
}#Set-KeyboardLayout

Function Set-Numlock {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "default Numlock state at startup"
$RegPaths = @( "HKU:\.DEFAULT\Control Panel\Keyboard" )
$RegKeys = @( "InitialKeyboardIndicators" )
Out-put "setting $($Description) to $($Status)"
try {
	If (!(Test-Path "HKU:")) { New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null }
	switch ($Status){
		"Disabled"{ $RegVal = 2147483648 ; $NumLock = $True }
		"Enabled" { $RegVal = 2147483650 ; $NumLock = $False }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	Add-Type -AssemblyName System.Windows.Forms
	If (([System.Windows.Forms.Control]::IsKeyLocked('NumLock')) -eq $Numlock) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Numlock

Function Set-OneDriveStartUp {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Set OneDrive startup"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
RegKey = "DisableFileSyncNGSC"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-OneDriveStartUp

Function Set-OneDriveProvisioning {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Provisioning of OneDrive"
Out-put "setting $($Description) to $($Status)"
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
If (!(Test-Path $onedrive)) { $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
$RegPaths = @(
"HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
"HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)
$Items = @(
"$env:USERPROFILE\OneDrive",
"$env:LOCALAPPDATA\Microsoft\OneDrive",
"$env:PROGRAMDATA\Microsoft OneDrive",
"$env:SYSTEMDRIVE\OneDriveTemp"
)
try {
	switch ($Status){
		"Disabled"{
			Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
			Start-Sleep -s 3
			Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
			Start-Sleep -s 3
			Stop-Process -Name explorer -ErrorAction SilentlyContinue
			Start-Sleep -s 3
			foreach ($Item in $Items){ Remove-Item $Item -Force -Recurse -ErrorAction SilentlyContinue }
			If (!(Test-Path "HKCR:")) { New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null }
			foreach ($RegPath in $RegPaths){ Remove-Item -Path $RegPath -Recurse -ErrorAction SilentlyContinue }
			}
		"Enabled" {
			Start-Process $onedrive -NoNewWindow
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-OneDriveProvisioning

# (Un)Install Windows Store Apps
Function Set-ProvisionedPackages {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status,
$Description = "Microsoft AppxPackages",
[string[]]$AppxPackages = @(
	"Microsoft.3DBuilder",
	"Microsoft.AppConnector",
	"Microsoft.BingFinance",
	"Microsoft.BingNews",
	"Microsoft.BingSports",
	"Microsoft.BingWeather",
	"Microsoft.BingTranslator",
	"Microsoft.CommsPhone",
	"Microsoft.ConnectivityStore",
	"Microsoft.GetHelp",
	"Microsoft.Getstarted",
	"Microsoft.Messaging",
	"Microsoft.Microsoft3DViewer",
	"Microsoft.MicrosoftOfficeHub",
	"Microsoft.MicrosoftPowerBIForWindows",
	"Microsoft.MicrosoftSolitaireCollection",
	"Microsoft.MicrosoftStickyNotes",
	"Microsoft.MinecraftUWP",
	"Microsoft.MovieMoment",
	"Microsoft.MSPaint",
	"Microsoft.NetworkSpeedTest",
	"Microsoft.Office.OneNote",
	"Microsoft.Office.Sway",
	"Microsoft.OneConnect",
	"Microsoft.People",
	"Microsoft.Print3D",
	"Microsoft.RemoteDesktop",
	"Microsoft.SkypeApp",
	"Microsoft.SkypeWiFi",
	"Microsoft.Wallet",
	"Microsoft.Windows.Photos",
	"Microsoft.WindowsAlarms",
	"Microsoft.WindowsCamera",
	"Microsoft.windowscommunicationsapps",
	"Microsoft.WindowsFeedback",
	"Microsoft.WindowsFeedbackHub",
	"Microsoft.WindowsMaps",
	"Microsoft.WindowsPhone",
	"Microsoft.WindowsSoundRecorder",
	"Microsoft.ZuneMusic",
	"Microsoft.ZuneVideo"
	)
)
$Help = @"
In case you have removed them for good, you can try to restore the files using installation medium as follows:

$MountFolder = "C:\Mnt"
New-Item $MountFolder -Type Directory | Out-Null
dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:"$MountFolder"
robocopy /S /SEC /R:0 "$($MountFolder)\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
dism /Unmount-Image /Discard /MountDir:"$MountFolder"
Remove-Item -Path $MountFolder -Recurse
"@
Out-put "Provisioning of $($Description) is $($Status)"
switch ($Status){
	"Disabled"{
		foreach ($AppxPackage in $AppxPackages){
			Remove-AppxPackage $AppxPackage
			Out-put "Uninstalling Package $($AppxPackage)"
			}#foreach AppxPackage
		}
	"Enabled" {
		foreach ($AppxPackage in $AppxPackages){
			try {
				Get-AppxPackage -AllUsers $AppxPackage | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
				Out-put "Installing Package $($AppxPackage)"
				}
			catch { Out-put "could not set $($Description) to $($Status)"}
			}#foreach AppxPackage
		}
	}#switch
}#Set-ProvisionedPackages

# (Un)Install third party applications
Function Set-Provisioned3PartyPackages {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status,
[string[]]$AppXPackages = @(
	"9E2F88E3.Twitter",
	"king.com.CandyCrushSodaSaga",
	"41038Axilesoft.ACGMediaPlayer",
	"2414FC7A.Viber",
	"46928bounde.EclipseManager",
	"64885BlueEdge.OneCalendar",
	"7EE7776C.LinkedInforWindows",
	"828B5831.HiddenCityMysteryofShadows",
	"A278AB0D.DisneyMagicKingdoms",
	"DB6EA5DB.CyberLinkMediaSuiteEssentials",
	"DolbyLaboratories.DolbyAccess",
	"E046963F.LenovoCompanion",
	"LenovoCorporation.LenovoID",
	"LenovoCorporation.LenovoSettings",
	"SpotifyAB.SpotifyMusic",
	"WinZipComputing.WinZipUniversal",
	"XINGAG.XING",
	"PandoraMediaInc.29680B314EFC2",
	"4DF9E0F8.Netflix",
	"Drawboard.DrawboardPDF",
	"D52A8D61.FarmVille2CountryEscape",
	"GAMELOFTSA.Asphalt8Airborne",
	"flaregamesGmbH.RoyalRevolt2",
	"AdobeSystemsIncorporated.AdobePhotoshopExpress",
	"ActiproSoftwareLLC.562882FEEB491",
	"D5EA27B7.Duolingo-LearnLanguagesforFree",
	"Facebook.Facebook",
	"46928bounde.EclipseManager",
	"A278AB0D.MarchofEmpires",
	"KeeperSecurityInc.Keeper",
	"king.com.BubbleWitch3Saga",
	"89006A2E.AutodeskSketchBook",
	"CAF9E577.Plex"
	)
)
$Description = "ThirdParty (Non-Microsoft) AppXPackages"
switch ($Status){
	"Enabled" {
		ForEach ($AppXPackage in $AppxPackages){
			Get-AppxPackage -AllUsers $AppxPackage | ForEach { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
			}
		}
	"Disabled" {
		ForEach ($AppxPackage in $AppxPackages){
			Get-AppxPackage $AppxPackages | Remove-AppxPackage
			}
		}
	}
}#Set-Provisioned3PartyPackages

Function Set-WindowsStoreProvisioning {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status,
[string[]]$AppXPackages = @( "Microsoft.DesktopAppInstaller","Microsoft.WindowsStore" )
)
$Description = "Windows Store"
switch ($Status){
	"Enabled" {
		ForEach ($AppXPackage in $AppxPackages){
			Get-AppxPackage -AllUsers $AppxPackage | ForEach { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
			}
		}
	"Disabled" {
		ForEach ($AppxPackage in $AppxPackages){
			Get-AppxPackage $AppxPackages | Remove-AppxPackage
			}
		}
	}
}#Set-WindowsStoreProvisioning

Function Set-ConsumerApps {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Consumer Experience"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
RegKey = "DisableWindowsConsumerFeatures"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ConsumerApps

Function Set-XboxFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status,
[string[]]$AppXPackages = @(
	"Microsoft.XboxApp",
	"Microsoft.XboxIdentityProvider",
	"Microsoft.XboxSpeechToTextOverlay",
	"Microsoft.XboxGameOverlay",
	"Microsoft.Xbox.TCUI"
	)
)
$Description = "Xbox Feature"
Set-ProvisionedPackages -Status $Status -AppxPackages $AppxPackages -Description $Description
$RegPaths = @(
"HKCU:\System\GameConfigStore",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
)
$RegKeys = @( "GameDVR_Enabled", "AllowGameDVR" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			If (!(Test-Path -Path $RegPaths[1] )) { New-Item -Path $RegPaths[1] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type Dword -Value 0
			}
		"Enabled" {
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 1
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-XboxFeature

Function Set-AdobeFlash {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Adobe Flash plugin (builtin for Edge and IE)"
$edge = (Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge").PackageFamilyName
$RegPaths = @(
"HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Addons",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{D27CDB6E-AE6D-11CF-96B8-444553540000}"
)
$RegKeys = @(
"FlashPlayerEnabled",
"Flags"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Enabled"{
			Remove-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -ErrorAction SilentlyContinue
			}
		"Disabled" {
			If (!(Test-Path $RegPaths[0])) { New-Item -Path $RegPaths[0] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value 0
			If (!(Test-Path $RegPaths[1])) { New-Item -Path $RegPaths[1] -Force | Out-Null }
			Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[1] -Type DWord -Value 1
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-AdobeFlash

# Generic Windows Feature Function
Function Set-WindowsFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status,
[string[]]$WindowsFeatures
)
$Description = "Windows feature"
switch ($Status){
	"Disabled"{
		try {
			foreach ($WindowsFeature in $WindowsFeatures){
				Disable-WindowsOptionalFeature -Online -FeatureName $WindowsFeature -NoRestart -WarningAction SilentlyContinue | Out-Null
				Out-put "setting $($Description) $($WindowsFeature) to $($Status)"
				}
			}
		catch { Out-put "could not set $($Description) to $($Status)"}
		}
	"Enabled" {
		try {
			foreach ($WindowsFeature in $WindowsFeatures){
				Enable-WindowsOptionalFeature -Online -FeatureName $WindowsFeature -NoRestart -WarningAction SilentlyContinue | Out-Null
				Out-put "setting $($Description) $($WindowsFeature) to $($Status)"
				}
			}
		catch { Out-put "could not set $($Description) to $($Status)"}
		}
	}
}#Set-WindowsFeature

Function Set-MediaPlayerFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "WindowsMediaPlayer"
}#Set-MediaPlayerFeature

Function Set-PDFprinter {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "Printing-PrintToPDFServices-Features"
}#Set-PDFprinter

Function Set-Faxprinter {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "Microsoft Shared Fax Driver"
}#Set-Faxprinter

Function Set-XPSprinter {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "Printing-XPSServices-Features"
}#Set-XPSprinter

Function Set-InternetExplorerFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "Internet-Explorer-Optional-$env:PROCESSOR_ARCHITECTURE"
}#Set-InternetExplorerFeature

Function Set-WorkFoldersFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
Set-WindowsFeature -Status $Status -WindowsFeatures "WorkFolders-Client"
}#Set-WorkFoldersFeature

Function Set-LinuxSubsystemFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Linux SubSystem"
$RegPaths = @( "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" )
$RegKeys = @(
"AllowDevelopmentWithoutDevLicense",
"AllowAllTrustedApps"
)
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ $RegVal = 0 }
		"Enabled" { $RegVal = 1 }
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[1] -Type DWord -Value $RegVal
	Set-WindowsFeature -Status $Status -WindowsFeatures "Microsoft-Windows-Subsystem-Linux"
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-LinuxSubsystemFeature

Function Set-HyperVFeature {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Windows HyperV feature"
Out-put "setting $($Description) to $($Status)"
switch ($Status){
	"Disabled"{
		try {
			if ((Get-WMIObject -class Win32_Computersystem).DomainRole -gt 1 ){
				Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
				}
			else {
				Set-WindowsFeature -Status $Status -WindowsFeatures "Microsoft-Hyper-V-All"
				}
			}
		catch { Out-put "could not set $($Description) to $($Status)"}
		}
	"Enabled" {
		try {
			if ((Get-WMIObject -class Win32_Computersystem).DomainRole -gt 1 ){
				Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
				}
			else {
				Set-WindowsFeature -Status $Status -WindowsFeatures "Microsoft-Hyper-V-All"
				}
			}
		catch { Out-put "could not set $($Description) to $($Status)"}
		}
	}
}#Set-HyperVFeature

Function Set-EdgeShortcutCreation {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Edge Shortcuts creation"
Out-put "setting $($Description) to $($Status)"
$RegPaths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer")
$RegKeys = @("DisableEdgeDesktopShortcutCreation")
$RegVal = 1
switch ($Status){
	"Disabled" { Set-ItemProperty $RegPaths[0] -Name $RegKeys[0] -Type Dword -Value $RegVal }
	"Enabled" { Remove-ItemProperty $RegPaths[0] -Name $RegKeys[0] -ErrorAction SilentlyContinue }
	}
}#Set-EdgeShortcutCreation

Function Set-PhotoViewerAssociation {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$FileTypes = @("Paint.Picture", "giffile", "jpegfile", "pngfile")
$Description = "Photo Viewer Associations for $($FileTypes -join ',')"
Out-put "setting $($Description) to $($Status)"
If (!(Test-Path "HKCR:")) { New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null }
try {
	switch ($Status){
		"Disabled"{
			Remove-Item -Path "HKCR:\Paint.Picture\shell\open" -Recurse -ErrorAction SilentlyContinue
			Remove-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "MuiVerb" -ErrorAction SilentlyContinue
			Set-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "CommandId" -Type String -Value "IE.File"
			Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "(Default)" -Type String -Value "`"$env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1"
			Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "DelegateExecute" -Type String -Value "{17FE9752-0B5A-4665-84CD-569794602F5C}"
			Remove-Item -Path "HKCR:\jpegfile\shell\open" -Recurse -ErrorAction SilentlyContinue
			Remove-Item -Path "HKCR:\pngfile\shell\open" -Recurse -ErrorAction SilentlyContinue
			}
		"Enabled" {
			ForEach ($FileType in $FileTypes) {
				New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
				New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
				Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
				Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
				}
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PhotoViewerAssociation

Function Set-PhotoViewerOpenWith {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Photo Viewer as Open With... option for pictures"
$RegPaths = @(
"HKCR:\Applications\photoviewer.dll\shell\open",
"HKCR:\Applications\photoviewer.dll\shell\open\command",
"HKCR:\Applications\photoviewer.dll\shell\open\DropTarget"
)
Out-put "setting $($Description) to $($Status)"
If (!(Test-Path "HKCR:")) { New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null }
try {
	switch ($Status){
		"Disabled"{
			Remove-Item -Path $RegPaths[0] -Recurse -ErrorAction SilentlyContinue
			}
		"Enabled" {
			foreach ($RegPath in $RegPaths){ If (!(Test-Path -Path $RegPath )) { New-Item -Path $RegPath -Force | Out-Null } }
			Set-ItemProperty -Path $RegPaths[0] -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
			Set-ItemProperty -Path $RegPaths[1] -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
			Set-ItemProperty -Path $RegPaths[2] -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PhotoViewerOpenWith

Function Set-SearchAppInStore {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Open With... in AppStore for unknown extension"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
RegKey = "NoUseStoreOpenWith"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-SearchAppInStore

Function Set-NewAppPrompt {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Open With... prompt for unknown extension"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
RegKey = "NoNewAppAlert"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-NewAppPrompt

Function Set-ControlPanelView {
param(
[Parameter(Mandatory = $True)][ValidateSet("Category","Large","Small")]$Status
)
$Description = "Control Panel view"
$RegPath = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")
$RegKey = @("StartupPage","AllItemsIconView")
Out-put "Setting $($Description)  to $($Status)"
switch ($Status){
	"Category"{
		Remove-ItemProperty -Path $RegPath[0] -Name $RegKey[0] -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path $RegPath[0] -Name $RegKey[1] -ErrorAction SilentlyContinue }
	"Large" {
		If (!(Test-Path $RegPath[0])) { New-Item -Path $RegPath[0] | Out-Null }
		Set-ItemProperty -Path $RegPath[0] -Name $RegKey[0] -Type DWord -Value 1
		Set-ItemProperty -Path $RegPath[0] -Name $RegKey[1] -Type DWord -Value 0
		}
	"Small" {
		If (!(Test-Path $RegPath[0])) { New-Item -Path $RegPath[0] | Out-Null }
		Set-ItemProperty -Path $RegPath[0] -Name $RegKey[0] -Type DWord -Value 1
		Set-ItemProperty -Path $RegPath[0] -Name $RegKey[1] -Type DWord -Value 1
		}
	}
}#Set-ControlPanelView

# Set Data Execution Prevention (DEP) policy to OptOut
Function Set-DEP {
param(
[Parameter(Mandatory = $True)][ValidateSet("OptOut","OptIn")]$Status
)
$Description = "DEP policy"
Out-put "setting $($Description) to $($Status)"
try { bcdedit /set `{current`} nx $($Status) | Out-Null }
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-DEP

########### Server specific Tweaks ###########

Function Set-ServerManagerOnLogin {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 1 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Server Manager startup on login"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager"
RegKey = "DoNotOpenAtLogon"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ServerManagerOnLogin

Function Set-ShutdownTracker {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Enabled"{ $RemoveRegKey = $true }
	"Disabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Shutdown Event Tracker"
RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability"
RegKey = "ShutdownReasonOn"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-ShutdownTracker

Function Set-PasswordPolicy {
param(
[ValidateRange(0,90)][int]$PasswordAge,
[ValidateRange(0,24)]$History,
[switch]$Complexity
)
$Description = "Password complexity, history and age"
Out-put "setting $($Description) to $($Status)"
try {
	$tmpfile = New-TemporaryFile
	secedit /export /cfg $tmpfile /quiet
	$pwdpolicy = (Get-Content $tmpfile)
	$pwdpolicy.Replace("PasswordComplexity = 1", "PasswordComplexity = $([int][bool]$Complexity)")
	$pwdpolicy.Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = $($PasswordAge)")
	$pwdpolicy.Replace("PasswordHistorySize = 0", "PasswordHistorySize = $($History)")
	$pwdpolicy | out-file $tmpfile
	secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $tmpfile
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-PasswordPolicy

Function Set-CtrlAltDelLogin {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
switch ($Status){
	"Disabled" { $RegVal = 1 }
	"Enabled" { $RegVal = 0 }
	}
$SingleRegKeyProps =@{
Status = $Status
Description = "Login with CtrlAltDelete"
RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
RegKey = "DisableCAD"
RegType = "Dword"
RegVal = $RegVal
RemoveRegKey = $RemoveRegKey
}
Set-SingleRegKey @SingleRegKeyProps
}#Set-CtrlAltDelLogin

Function Set-IEEnhancedSecurity {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Internet Explorer Enhanced Security Config"
$RegPaths = @(
"HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}",
"HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
)
$RegKeys = @( "IsInstalled" )
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{ $RegVal = 1	}
		"Enabled" { $RegVal = 0	}
		}
	Set-ItemProperty -Path $RegPaths[0] -Name $RegKeys[0] -Type DWord -Value $RegVal
	Set-ItemProperty -Path $RegPaths[1] -Name $RegKeys[0] -Type DWord -Value $RegVal
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-IEEnhancedSecurity

Function Set-Audio {
param(
[Parameter(Mandatory = $True)][ValidateSet("Enabled","Disabled")]$Status
)
$Description = "Audio device"
Out-put "setting $($Description) to $($Status)"
try {
	switch ($Status){
		"Disabled"{
			Stop-Service "Audiosrv" -WarningAction SilentlyContinue
			Set-Service "Audiosrv" -StartupType Manual
			}
		"Enabled" {
			Set-Service "Audiosrv" -StartupType Automatic
			Start-Service "Audiosrv" -WarningAction SilentlyContinue
			}
		}
	}
catch { Out-put "could not set $($Description) to $($Status)"}
}#Set-Audio

}#begin

end{
switch ($RedirectOutput){
	"Host" { Write-Host "W10 tweaks script has finished"}
	"Log" { Out-File $script:LogFilePath "End of script execution at $(Get-Date)" -Append -NoClobber }
	"Pipe" { $script:Output }
	}
}
