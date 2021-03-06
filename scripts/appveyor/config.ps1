[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null;

$instancename = $args[0];

$wmi = New-Object('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer');
$tcp = $wmi.GetSmoObject("ManagedComputer[@Name='${env:computername}']/ServerInstance[@Name='${instancename}']/ServerProtocol[@Name='Tcp']");
$tcp.IsEnabled = $true;
$tcp.Alter();

Start-Service -Name "MSSQL`$$instancename";

$wmi = New-Object('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer');
$ipall = $wmi.GetSmoObject("ManagedComputer[@Name='${env:computername}']/ServerInstance[@Name='${instancename}']/ServerProtocol[@Name='Tcp']/IPAddress[@Name='IPAll']");
$port = $ipall.IPAddressProperties.Item("TcpDynamicPorts").Value;

$config = @{
  instanceName = $instancename;
  config = @{
    server = "localhost";
    userName = "sa";
    password = "Password12!";
    options = @{
      port = $port;
      database = "master";
      requestTimeout = 25000;
      cryptoCredentialsDetails = @{
        ciphers = "RC4-MD5"
      }
    }
  }
} | ConvertTo-Json -Depth 3;

[System.IO.File]::WriteAllLines("C:/Users/appveyor/.tedious/test-connection.json", $config);
