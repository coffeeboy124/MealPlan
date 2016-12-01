<?php
include_once('../dataobjects/Meal.php');
include_once('../dataobjects/MealUser.php');
include_once('../dataobjects/User.php');
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

if($m_sAction != "" && $m_sAction == "InviteGuest")
{
	InviteGuest();
}
elseif($m_sAction != "" && $m_sAction == "AcceptInvite")
{
	AcceptInvite();
}
elseif($m_sAction != "" && $m_sAction == "RejectInvite")
{
	RejectInvite();
}
elseif($m_sAction != "" && $m_sAction == "ViewMealUsers")
{
	ViewMealUsers();
}
elseif($m_sAction != "" && $m_sAction == "ViewMealState")
{
	ViewMealState();
}
elseif($m_sAction != "" && $m_sAction == "ViewMealTimes")
{
	ViewMealTimes();
}
elseif($m_sAction != "" && $m_sAction == "ListMeals")
{
	ListMeals();
}
elseif($m_sAction != "" && $m_sAction == "LeaveMeal")
{
	LeaveMeal();
}
elseif($m_sAction != "" && $m_sAction == "CreateMeal")
{
	CreateMeal();
}
elseif($m_sAction != "" && $m_sAction == "SelectTime")
{
	SelectTime();
}
elseif($m_sAction != "" && $m_sAction == "SelectRestaurant")
{
	SelectRestaurant();
}
elseif($m_sAction != "" && $m_sAction == "CompleteMeal")
{
	CompleteMeal();
}
elseif($m_sAction != "" && $m_sAction == "ChangeMealName")
{
	ChangeMealName();
}

exit;

function InviteGuest(){
	global $m_oJSONPrinter;
	
	if(empty($_POST["InvitedUserNames"]) || empty($_POST["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oMeal = new Meal();
	$oMeal->SetToken($_POST["token"]);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	$oInvitedUserNames = explode(",", $_POST["InvitedUserNames"]);
	$oUser = new User();
	foreach ($oInvitedUserNames as $sUserName)
	{
		$oUser->SetUserName($sUserName);
		if($oUser->CheckUsername()) //id not found
		{
			$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
			return;
		}
		
		$oMealUser = new MealUser();
		$oMealUser->SetUserId($oUser->GetUserId());
		$oMealUser->SetMealId($iMealId);
		$oMealUser->SetState("INVITED");
		if($oMealUser->CheckUserID())
		{
			$oMealUser->Create();
		}
	}
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
	return;
}

function AcceptInvite(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$sSqlStatement = "SELECT meal_user.mu_id, meal.meal_id 
					  FROM meal INNER JOIN meal_user 
					  ON meal.meal_id = meal_user.meal_id
					  WHERE meal_user.state = 'INVITED' AND meal.token = :Token AND meal_user.user_id = :UserId";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':Token', $sToken, PDO::PARAM_STR, 64);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$oTimeSheet = new TimeSheet();
			$oTimeSheet->SetUserId($_SESSION['iUserId']);
			$iSheetId = $oTimeSheet->GetActiveTimeSheet();
			if($iSheetId == -1)
			{
				$m_oJSONPrinter->printJSON("FALSE", "No active time sheet", "NULL");
				return;
			}
			
			$oMealUser = new MealUser();
			$oMealUser->Load($oSQLRow[0]);
			$oMealUser->SetState("GUEST");
			$oMealUser->SetSheetId($iSheetId);
			$oMealUser->Update($oSQLRow[0]);
			
			$oMeal = new Meal();
			$oMeal->Load($oSQLRow[1]);
			$sMealState = $oMeal->GetState();
			if($sMealState == "CANCELLED" || $sMealState == "COMPLETED")
			{
				$oMealUser->Delete($oSQLRow[0]);
				$m_oJSONPrinter->printJSON("FALSE", "Meal was either cancelled or completed", "NULL");
				return;
			}
			$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
			return;
		}
		$m_oJSONPrinter->printJSON("FALSE", "Invite not found", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function RejectInvite(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$sSqlStatement = "SELECT meal_user.mu_id 
					  FROM meal INNER JOIN meal_user 
					  ON meal.meal_id = meal_user.meal_id
					  WHERE meal_user.state = 'INVITED' AND meal.token = :Token AND meal_user.user_id = :UserId";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':Token', $sToken, PDO::PARAM_STR, 64);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$oMealUser = new MealUser();
			$oMealUser->Delete($oSQLRow[0]);
			$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
			return;
		}
		$m_oJSONPrinter->printJSON("FALSE", "Invite not found", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ViewMealUsers(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$oMeal = new Meal();
	$oMeal->SetToken($sToken);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$sSqlStatement = "SELECT user.user_name, meal_user.state, user.img_path 
					  FROM user INNER JOIN meal_user 
					  ON user.user_id = meal_user.user_id
					  WHERE meal_user.meal_id = :MealId" ;
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		$oOutputList = array();
		if($oSQLRow)
		{
			foreach ($oSQLRow as $sValue)
			{
				$oUserList = array(
					"user_name" => $sValue[0],
					"state" => $sValue[1],
					"prof_img" => $sValue[2]
				);
				array_push($oOutputList, $oUserList);
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

function ViewMealState(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$oMeal = new Meal();
	$oMeal->SetToken($sToken);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
					  
	$sSqlStatement = "SELECT state, time_slot, restaurant_name, restaurant_location 
					  FROM meal
					  WHERE meal_id = :MealId" ;
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$oMealList = array(
				"meal_state" => $oSQLRow[0],
				"meal_time_slot" => $oSQLRow[1],
				"restaurant_name" => $oSQLRow[2],
				"restaurant_location" => $oSQLRow[3]
			);
			$m_oJSONPrinter->printJSON("TRUE", "NULL", $oMealList);
			return;
		}
		
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL"); // this should never happen!!!
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ViewMealTimes(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$oMeal = new Meal();
	$oMeal->SetToken($sToken);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
					  
	$sSqlStatement = "SELECT time_slot.time_slot, time_sheet.user_id
					  FROM time_sheet INNER JOIN time_slot
					  ON time_sheet.sheet_id = time_slot.sheet_id
					  INNER JOIN meal_user 
					  ON time_sheet.sheet_id = meal_user.sheet_id
					  WHERE meal_user.state != 'INVITED' AND meal_user.meal_id = :MealId" ;
	try
	{			
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		
		$oTimeHandling = new TimeHandling();
		$oTimes = array();
		$oUsers = array();
		$oResults = array();
		$oOutputList = array();
	
		if($oSQLRow)
		{
			foreach ($oSQLRow as $oRow)
			{
				array_push($oTimes, $oRow[0]);
				array_push($oUsers, [$oRow[1]]);
			}
			
			$oTimeHandling->CalculateOverlaps($oTimes, $oUsers, $oResults);

			for ($i = 0; $i < count($oResults); $i++)
			{
				if($i%2 == 0)
				{
					$oMealUserArray = ViewMealTimesHelper($oResults[$i+1], $iMealId);
					if(!$oMealUserArray){
						$m_oJSONPrinter->printJSON("FALSE", "User not found", "NULL");
						return;
					}
					$oTimeComponents = explode(" ",$oResults[$i]);
					$oTimeList = array(
					"time_slot" =>  array(
									"start_time" => $oTimeComponents[0],
									"end_time" => $oTimeComponents[1],
									"day" => $oTimeComponents[2]
									),
					"meal_user" => $oMealUserArray
					);
					array_push($oOutputList, $oTimeList);
				}
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

function ViewMealTimesHelper($iUserIds, $iMealId){
	global $g_oDatabase;
	
	$sSqlStatement = "SELECT user.user_name, meal_user.state, user.img_path 
					  FROM user INNER JOIN meal_user 
					  ON user.user_id = meal_user.user_id
					  WHERE meal_user.state != 'INVITED' AND meal_user.meal_id = :MealId AND user.user_id IN (" . implode(",", $iUserIds) . ")" ;
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$oOutputList = array();
			foreach ($oSQLRow as $sValue)
			{
				$oUserList = array(
					"user_name" => $sValue[0],
					"state" => $sValue[1],
					"prof_img" => $sValue[2]
				);
				array_push($oOutputList, $oUserList);
			}
			return $oOutputList;
		}
		return FALSE;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function LeaveMeal(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$oMeal = new Meal();
	$oMeal->SetToken($sToken);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$oMeal->Load($iMealId);
	$sMealState = $oMeal->GetState();
	if($sMealState == "CANCELLED" || $sMealState == "COMPLETED")
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal was either cancelled or completed", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetMealId($iMealId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	if($oMealUser->CheckUserID())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal user not found", "NULL");
		return;
	}
	$iMuId = $oMealUser->GetMuId();
	
	$oMealUser->Load($iMuId);
	if(strcmp($oMealUser->GetState(),'HOST')==0) //host left, meal is over!
	{
		$oMeal->Load($iMealId);
		$oMeal->SetState("CANCELLED");
		$oMeal->Update($iMealId);
		
		$sSqlStatement = "DELETE FROM meal_user WHERE meal_id = :MealId";				  
		try
		{	
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oStatement->closeCursor();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	$oMealUser->Delete($iMuId);
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
	return;
}

function ListMeals(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	$sSqlStatement = "SELECT meal.state, meal.token, meal.name, user.user_name, meal_user.state, user.img_path 
					  FROM meal_user INNER JOIN meal
					  ON meal.meal_id = meal_user.meal_id
					  INNER JOIN user
					  ON meal_user.user_id = user.user_id
					  WHERE meal_user.user_id = :UserId AND meal.state != 'COMPlETED' AND meal.state != 'CANCELLED'" ;
					  					  
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
				if($sValue[4] == "HOST")
				{
					$oMealList = array(
						"meal_state" => $sValue[0],
						"token" => $sValue[1],
						"meal_name" => $sValue[2],
						"user_name" => $sValue[3],
						"user_state" => $sValue[4],
						"prof_img" => $sValue[5]
					);
					$oMealList['attendance']  = ListMealsCountHelper($sValue[1]);
					array_push($oOutputList, $oMealList);
				}
				else
				{
					$oMealList = ListMealsPersonHelper($sValue[1], $sValue[4]);
					$oMealList['attendance']  = ListMealsCountHelper($sValue[1]);
					if($oMealList){
						array_push($oOutputList, $oMealList);
					}
				}
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

function ListMealsPersonHelper($sToken, $sState)
{
	global $g_oDatabase;
	
	$sSqlStatement = "SELECT meal.state, meal.token, meal.name, user.user_name, meal_user.state, user.img_path
			  FROM meal_user INNER JOIN meal
			  ON meal.meal_id = meal_user.meal_id
			  INNER JOIN user
			  ON meal_user.user_id = user.user_id
			  WHERE meal.token = :Token AND meal.state != 'COMPLETED' AND meal.state != 'CANCELLED' AND meal_user.state = 'HOST'" ;
			  			  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':Token', $sToken, PDO::PARAM_STR, 64);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		
		if($oSQLRow)
		{
			$oMealList = array(
					"meal_state" => $oSQLRow[0],
					"token" => $oSQLRow[1],
					"meal_name" => $oSQLRow[2],
					"user_name" => $oSQLRow[3],
					"user_state" => $sState,
					"prof_img" => $oSQLRow[5]
				);
			return $oMealList;
		}
		return array();
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ListMealsCountHelper($sToken)
{
	global $g_oDatabase;
	
	$sSqlStatement = "SELECT COUNT(*)
			  FROM meal_user INNER JOIN meal
			  ON meal.meal_id = meal_user.meal_id
			  WHERE meal.token = :Token";
	
	$oSqlStatement2 = "SELECT COUNT(*)
			  FROM meal_user INNER JOIN meal
			  ON meal.meal_id = meal_user.meal_id
			  WHERE meal.token = :Token AND meal_user.state = 'GUEST'";
			  			  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':Token', $sToken, PDO::PARAM_STR, 64);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		
		if($oSQLRow)
		{			
			$oStatement = $g_oDatabase->prepare($oSqlStatement2);
			$oStatement->bindParam(':Token', $sToken, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oSQLRow2 = $oStatement->fetch();
			$oStatement->closeCursor();
			
			return (string)($oSQLRow2[0] + 1) . "/" . (string)$oSQLRow[0];
		}
		return FALSE;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function CreateMeal(){
	global $m_oJSONPrinter;
	
	$oStringGenerator = new StringGenerator();
	$oMeal = new Meal();
	if (!empty($_POST["meal_name"]))
		$oMeal->SetName($_POST["meal_name"]);
	$oMeal->SetState("VOTING");
	$oMeal->SetToken($oStringGenerator->GenerateUniqueId(64));
	while(!$oMeal->CheckToken())
	{
		$oMeal->SetToken($oStringGenerator->GenerateUniqueId(64));
	}
	$oMeal->Create();

	$oTimeSheet = new TimeSheet();
	$oTimeSheet->SetUserId($_SESSION['iUserId']);
	$iSheetId = $oTimeSheet->GetActiveTimeSheet();
	if($iSheetId == -1)
	{
		$m_oJSONPrinter->printJSON("FALSE", "No active time sheet", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetSheetId($iSheetId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	$oMealUser->SetMealId($oMeal->GetMealId());
	$oMealUser->SetState("HOST");
	$oMealUser->Create();

	$m_oJSONPrinter->printJSON("TRUE", "NULL", $oMeal->GetToken());
}

function SelectTime()
{
	global $m_oJSONPrinter;
	
	if (empty($_POST["token"]) || empty($_POST["time_slot"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oMeal = new Meal();
	$oMeal->SetToken($_POST["token"]);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetMealId($iMealId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	if($oMealUser->CheckUserID())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal user not found", "NULL");
		return;
	}
	$iMuId = $oMealUser->GetMuId();
	
	$oMealUser->Load($iMuId);
	if($oMealUser->GetState() == "HOST")
	{
		$oMeal->Load($iMealId);
		$oMeal->SetTimeSlot($_POST["time_slot"]);
		$oStringComponents = explode("|", $_POST["time_slot"]);
		$oMeal->SetState($oStringComponents[0]."| ".date("Y"));
		$oMeal->Update($iMealId);
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	$m_oJSONPrinter->printJSON("FALSE", "Not the host", "NULL");
	return;
}

function SelectRestaurant()
{
	global $m_oJSONPrinter;
	
	if (empty($_POST["token"]) || empty($_POST["restaurant_name"]) || empty($_POST["restaurant_location"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oMeal = new Meal();
	$oMeal->SetToken($_POST["token"]);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetMealId($iMealId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	if($oMealUser->CheckUserID())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal user not found", "NULL");
		return;
	}
	$iMuId = $oMealUser->GetMuId();
	
	$oMealUser->Load($iMuId);
	if($oMealUser->GetState() == "HOST")
	{
		$oMeal->Load($iMealId);
		$oMeal->SetRestaurantName($_POST["restaurant_name"]);
		$oMeal->SetRestaurantLocation($_POST["restaurant_location"]);
		$oMeal->Update($iMealId);
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	$m_oJSONPrinter->printJSON("FALSE", "Not the host", "NULL");
	return;
}

function CompleteMeal()
{
	global $m_oJSONPrinter;
	
	if (!isset($_GET["token"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sToken = $_GET["token"];
	
	$oMeal = new Meal();
	$oMeal->SetToken($sToken);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetMealId($iMealId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	if($oMealUser->CheckUserID())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal user not found", "NULL");
		return;
	}
	$iMuId = $oMealUser->GetMuId();
	
	$oMealUser->Load($iMuId);
	if($oMealUser->GetState() == "HOST")
	{
		$oMeal->Load($iMealId);
		$oMeal->SetState("COMPLETED");
		$oMeal->Update($iMealId);
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	$m_oJSONPrinter->printJSON("FALSE", "Not the host", "NULL");
	return;
}

function ChangeMealName()
{
	global $m_oJSONPrinter;
	
	if (!isset($_POST["token"]) || !isset($_POST["meal_name"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oMeal = new Meal();
	$oMeal->SetToken($_POST["token"]);
	$oMeal->CheckToken();
	$iMealId = $oMeal->GetMealId();
	if(!$iMealId)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
		return;
	}
	
	$oMealUser = new MealUser();
	$oMealUser->SetMealId($iMealId);
	$oMealUser->SetUserId($_SESSION['iUserId']);
	if($oMealUser->CheckUserID())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Meal user not found", "NULL");
		return;
	}
	$iMuId = $oMealUser->GetMuId();
	
	$oMealUser->Load($iMuId);
	if($oMealUser->GetState() == "HOST")
	{
		$oMeal->Load($iMealId);
		$oMeal->SetName($_POST["meal_name"]);
		$oMeal->Update($iMealId);
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	$m_oJSONPrinter->printJSON("FALSE", "Not the host", "NULL");
	return;
}
?>