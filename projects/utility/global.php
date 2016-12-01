<?php
include_once('utility.php');

$sDSN = "mysql:host=127.0.0.1;dbname=mealtime";
$sUserName = "root";
$sPassword = "";

try
{
    $g_oDatabase = new PDO($sDSN, $sUserName, $sPassword);
    $g_oDatabase->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
catch (PDOException $oPDOException)
{
    $oErrorHandling = new ErrorHandling();
    $oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
	exit;
}

?>