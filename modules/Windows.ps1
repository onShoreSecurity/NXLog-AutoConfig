Write-Host "Running Windows Module"
$caption = (Get-WmiObject -class Win32_OperatingSystem).Caption
if(($caption -match "2003") -or ($caption -match "XP")){
    $win_module = "im_mseventlog"
} else {
    $win_module = "im_msvistalog"
}

$conf += "<Input windows>
"
$conf += "    Module      $win_module
"

# ADD OTHER WINDOWS EVENT PATHS IF NEEDED
#<Select Path="Microsoft-Windows-PowerShell/Operational">*</Select>
#<Select Path="Application">*</Select>
#<Select Path='Security'>*</Select>
#<Select Path="System">*</Select>
#<Select Path="Microsoft-Windows-TaskScheduler/Operational">*</Select>
$conf += '
    <QueryXML>
        <QueryList>
            <Query Id="0">
                <Select Path="Security">*</Select>
                <Select Path="Microsoft-Windows-TaskScheduler/Operational">*</Select>
            </Query>
        </QueryList>
    </QueryXML>
    <Exec>
      if $Category == undef $Category = 0;
        $EventTimeStr = strftime($EventTime, "YYYY-MM-DDThh:mm:ss.sUTC");
        if $EventType == "CRITICAL"
        {
            $EventTypeNum = 1;
            $EventTypeStr = "Critical";
        }
        else if $EventType == "ERROR"
        {
            $EventTypeNum = 2;
            $EventTypeStr = "Error";
        }
        else if $EventType == "INFO"
        {
            $EventTypeNum = 4;
            $EventTypeStr = "Informational";
        }
        else if $EventType == "WARNING"
        {
            $EventTypeNum = 3;
            $EventTypeStr = "Warning";
        }
        else if $EventType == "VERBOSE"
        {
            $EventTypeNum = 5;
            $EventTypeStr = "Verbose";
        }
    else if $EventType == "AUDIT_SUCCESS"
        {
            $EventTypeNum = 8;
            $EventTypeStr = "Success Audit";
        }
    else if $EventType == "AUDIT_FAILURE"
        {
            $EventTypeNum = 16;
            $EventTypeStr = "Failure Audit";
        }
        else
        {
            $EventTypeNum = 0;
            $EventTypeStr = "Audit";
        }
        if $OpcodeValue == 0 $Opcode = "Info";
        if $TaskValue == 0 $TaskValue = "None";

        $Message = "AgentDevice=WindowsLog" +
            "\tAgentLogFile=" + $Channel +
            "\tSource=" + $SourceName +
            "\tComputer=" + hostname_fqdn() +
            "\tOriginatingComputer=" + $Hostname +
            "\tUser=" + $AccountName +
            "\tDomain=" + $Domain +
            "\tEventID=" + $EventID +
            "\tEventIDCode=" + $EventID +
            "\tEventTypeName=" + $EventType +
            "\tEventType=" + $EventTypeNum +
            "\tEventCategory=" + $Category +
            "\tRecordNumber=" + $RecordNumber +
            "\tTimeGenerated=" + $EventTimeStr +
            "\tTimeWritten=" + $EventTimeStr +
            "\tLevel=" + $EventTypeStr +
            "\tKeywords=" + $Keywords +
            "\tTask=" + $TaskValue +
            "\tOpcode=" + $Opcode +
            "\tMessage=" + $Message;
        $Hostname = hostname();
        delete($SourceName);
        delete($Severity);
        delete($SeverityValue);
        to_syslog_bsd();
    </Exec>
</Input>

<Route windows>
    Path    windows => collector
</Route>

'