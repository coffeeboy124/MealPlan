<?php
include_once('../dataobjects/TimeSlot.php');
include_once('../dataobjects/TimeSheet.php');
include_once('../utility/utility.php');

$m_oSessionHandling = new SessionHandling();
$m_oSessionHandling->StartSession();
$m_oJSONPrinter = new JSONPrinter();

if(!isset($_SESSION['iUserId']) || !isset($_GET["action"]))
{
	$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
	return;
}
$m_sAction = $_GET["action"];

if($m_sAction != "" && $m_sAction == "CreateTime")
{
	CreateTime();
}
elseif($m_sAction != "" && $m_sAction == "ListTimes")
{
	ListTimes();
}
elseif($m_sAction != "" && $m_sAction == "DeleteTime")
{
	DeleteTime();
}
elseif($m_sAction != "" && $m_sAction == "CreateTimeSheet")
{
	CreateTimeSheet();
}
elseif($m_sAction != "" && $m_sAction == "ListTimeSheets")
{
	ListTimeSheets();
}
elseif($m_sAction != "" && $m_sAction == "DeleteTimeSheet")
{
	DeleteTimeSheet();
}
elseif($m_sAction != "" && $m_sAction == "SetActiveSheet")
{
	SetActiveSheet();
}
elseif($m_sAction != "" && $m_sAction == "ChangeSheetName")
{
	ChangeSheetName();
}

exit;


function ListTimes(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["sheet_id"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$iSheetId = $_GET["sheet_id"];
	
	$oTimeSheet = new TimeSheet();
	if(!$oTimeSheet->Load($iSheetId))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	
	$sSqlStatement = "SELECT time_slot FROM time_slot WHERE sheet_id = :SheetId" ;
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		
		$oOutputList = array();
		if($oSQLRow)
		{
			foreach ($oSQLRow as $sValue)
			{
				$oTimeSlotComponents = explode(" ",$sValue[0]);
				$oTimeList = array(
					"start_time" => $oTimeSlotComponents[0],
					"end_time" => $oTimeSlotComponents[1],
					"day" => $oTimeSlotComponents[2],
				);
				array_push($oOutputList, $oTimeList);
			}
		}
		$m_oJSONPrinter->printJSON("TRUE", "NULL", $oOutputList);
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ListTimeSheets(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	$sSqlStatement = "SELECT sheet_id, name, state FROM time_sheet WHERE user_id = :UserId" ;
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		
		$oOutputList = array();
		if($oSQLRow)
		{
			foreach ($oSQLRow as $sValue)
			{
				$oTimeList = array(
					"sheet_id" => $sValue[0],
					"name" => $sValue[1],
					"state" => $sValue[2],
				);
				array_push($oOutputList, $oTimeList);
			}
		}
		$m_oJSONPrinter->printJSON("TRUE", "NULL", $oOutputList);
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function CreateTime(){
	global $m_oJSONPrinter;
	
	if (empty($_POST['start_time']) || empty($_POST['end_time']) || empty($_POST['day']) || empty($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}

	$oTimeSlot = new TimeSlot();
	$oTimeSheet = new TimeSheet();
	$oTimeHandling = new TimeHandling();
	
	$sTimeString = $oTimeHandling->CreateTimeString($_POST['start_time'], $_POST['end_time'], $_POST['day']);
	if($sTimeString == FALSE)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timeslot invalid", "NULL");
		return;
	}
	if(!$oTimeSheet->Load($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	if($oTimeSheet->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	
	$oTimeSlot->SetTimeSlot($sTimeString);
	$oTimeSlot->SetSheetId($_POST['sheet_id']);
	if($oTimeSlot->CheckTimeSlot())
	{
		$oTimeSlot->Create();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	else
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timeslot overlap", "NULL");
		return;
	}
}

function CreateTimeSheet(){
	global $m_oJSONPrinter;
	
	if (empty($_POST['name']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}

	$oTimeSheet = new TimeSheet();
	$oTimeSheet->SetName($_POST['name']);
	$oTimeSheet->SetUserId($_SESSION['iUserId']);
	if($oTimeSheet->CheckTimeSheet())
	{
		$oTimeSheet->SetState("INACTIVE");
		$oTimeSheet->Create();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	
	$m_oJSONPrinter->printJSON("FALSE", "Timesheet exists", "NULL");
	return;
}

function DeleteTime(){
	global $g_oDatabase;
	global $m_oJSONPrinter;

	if (empty($_POST['time_slot']) || empty($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oTimeSheet = new TimeSheet();
	if(!$oTimeSheet->Load($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	if($oTimeSheet->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}

	$sSqlStatement = "DELETE FROM time_slot 
					  WHERE sheet_id = :SheetId AND time_slot = :TimeSlot";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':SheetId', $_POST['sheet_id'], PDO::PARAM_INT);
		$oStatement->bindParam(':TimeSlot', $_POST['time_slot'], PDO::PARAM_STR, 16);
		
		$oStatement->execute();
		$oStatement->closeCursor();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function DeleteTimeSheet(){
	global $g_oDatabase;
	global $m_oJSONPrinter;

	if (!isset($_GET["sheet_id"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$iSheetId = $_GET["sheet_id"];

	$oTimeSheet = new TimeSheet();
	if(!$oTimeSheet->Load($iSheetId))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	if($oTimeSheet->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	
	
	
	$sSqlStatement = "DELETE FROM time_slot 
					  WHERE sheet_id = :SheetId";
	
	$sSqlStatement2 = "UPDATE meal_user SET sheet_id = NULL
					   WHERE sheet_id = :SheetId";
	
	$sSqlStatement3 = "DELETE FROM time_sheet 
					  WHERE sheet_id = :SheetId";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
		$oStatement->execute();
		$oStatement->closeCursor();
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement2);
		$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
		$oStatement->execute();
		$oStatement->closeCursor();
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement3);
		$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
		$oStatement->execute();
		$oStatement->closeCursor();
		
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
	
	
}

function SetActiveSheet(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["sheet_id"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$iSheetId = $_GET["sheet_id"];
	
	$oTimeSheet = new TimeSheet();
	if(!$oTimeSheet->Load($iSheetId))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	if($oTimeSheet->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	
	$sSqlStatement = "SELECT sheet_id FROM time_sheet WHERE user_id = :UserId" ;
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		
		if($oSQLRow)
		{
			foreach ($oSQLRow as $sValue)
			{
				$oTimeSheet->Load($sValue[0]);
				$oTimeSheet->SetState("INACTIVE");
				$oTimeSheet->Update($sValue[0]);
			}
		}
		$oTimeSheet->Load($iSheetId);
		$oTimeSheet->SetState("ACTIVE");
		$oTimeSheet->Update($iSheetId);
		
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ChangeSheetName(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (empty($_POST['name']) || empty($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oTimeSheet = new TimeSheet();
	if(!$oTimeSheet->Load($_POST['sheet_id']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	if($oTimeSheet->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Timesheet not found", "NULL");
		return;
	}
	
	$oTimeSheet->SetName($_POST['name']);
	$oTimeSheet->Update($_POST['sheet_id']);
		
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
	return;
}

?>