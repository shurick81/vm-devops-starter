Import-Module -Name SqlServer
$SMOserver = New-Object ( 'Microsoft.SqlServer.Management.Smo.Server' ) -argumentlist $env:COMPUTERNAME\SQLInstance01
$rf = New-Object( 'Microsoft.SqlServer.Management.Smo.RelocateFile' )
$rf.LogicalFileName = "mscrm";
$rf.PhysicalFileName = "$($SMOserver.DefaultFile)\Contos00_MSCRM_Old.mdf"
$rfl = New-Object( 'Microsoft.SqlServer.Management.Smo.RelocateFile' )
$rfl.LogicalFileName = "mscrm_log";
$rfl.PhysicalFileName = "$($SMOserver.DefaultLog)\Contos00_MSCRM_Old_log.ldf"
Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME\SQLInstance01 -Database Contos00_MSCRM_Old -BackupFile ( "C:\dbbackups\Contos00_MSCRM.bak" ) -RelocateFile @( $rf, $rfl )

#Import-Module SQLPS
#Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME\SQLInstance01 -Database MSCRM_CONFIG -BackupFile ( "C:\dbbackups\MSCRM_CONFIG.bak" )
#Restore-SqlDatabase -ServerInstance $env:COMPUTERNAME\SQLInstance01 -Database Contos00_MSCRM -BackupFile ( "C:\dbbackups\Contos00_MSCRM.bak" )
