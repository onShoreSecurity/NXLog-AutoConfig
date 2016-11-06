$conf += '# Nxlog internal logs
<Input internal>
  Module im_internal
  Exec $EventReceivedTime = integer($EventReceivedTime) / 1000000;
  Exec $NXLogHostname = '
  $conf += "'"
  $conf += $env:computername
  $conf += "';"
  $conf += '
  Exec to_json();
</Input>

<Output out_internal>
  Module      om_tcp
  Host        '
  $conf += $script:logstashHost
  $conf += '
  Port        5000
</Output>
 
#<Route 1>
#  Path internal => out_internal
#</Route>


'
