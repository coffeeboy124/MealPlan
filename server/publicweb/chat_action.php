<?php
include_once('../dataobjects/ChatRoom.php');
include_once('../dataobjects/Meal.php');
include_once('../dataobjects/User.php');
include_once('../dataobjects/UserRelation.php');
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

if($m_sAction != "" && $m_sAction == "CreateMessage")
{
	CreateMessage();
}
elseif($m_sAction != "" && $m_sAction == "ListMessages")
{
	ListMessages();
}

exit;

function CreateMessage(){
	global $m_oJSONPrinter;
	
	if ((empty($_POST["token"]) && empty($_POST["user_name"])) || empty($_POST["message"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oChatRoom = new ChatRoom();
	$oChatRoom->SetUserId($_SESSION['iUserId']);
	$oChatRoom->SetMessage($_POST["message"]);
	
	if(!empty($_POST["token"]))
	{
		$oMeal = new Meal();
		$oMeal->SetToken($_POST["token"]);
		$oMeal->CheckToken();
		$iMealId = $oMeal->GetMealId();
		if(!$iMealId)
		{
			$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
			return;
		}
		
		$oChatRoom->SetMealId($iMealId);
	}
	else
	{
		$oUser = new User();
		$oUser->SetUserName($_POST["user_name"]);
		if($oUser->CheckUsername()) //id not found
		{
			$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
			return;
		}
		
		$oUserRelation = new UserRelation();
		$oUserRelation->SetUser1Id($_SESSION['iUserId']);
		$oUserRelation->SetUser2Id($oUser->GetUserId());
		$oUserRelation->CheckRelation();
		$iRelationId = $oUserRelation->GetRelationId();
		if(!$iRelationId || ($oUserRelation->GetState() != 'ACCEPTED'))
		{
			$m_oJSONPrinter->printJSON("FALSE", "Relation not found", "NULL");
			return;
		}
		
		$oChatRoom->SetRelationId($iRelationId);
	}	
	
	$oChatRoom->Create();
	
	$m_oJSONPrinter->printJSON("TRUE", "NULL", ["message_id" => $oChatRoom->GetMesId()]);
	return;
}

function ListMessages(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	//$_POST["token"] = "c78c4e2aec5c946dd18477c87154adc61971ec5c2be244f201f3cdc0ccfb3310";
	$_POST["user_name"] = "ss";
	
	if (empty($_POST["token"]) && empty($_POST["user_name"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	if(!isset($_GET["mes_id"]))
		$iMesId = 0;
	else
		$iMesId = $_GET["mes_id"];
	
	if(!empty($_POST["token"]))
	{
		$oMeal = new Meal();
		$oMeal->SetToken($_POST["token"]);
		$oMeal->CheckToken();
		$iMealId = $oMeal->GetMealId();
		if(!$iMealId)
		{
			$m_oJSONPrinter->printJSON("FALSE", "Meal not found", "NULL");
			return;
		}
		
		$sSqlStatement = "SELECT user.user_name, user.first_name, user.last_name, chat_room.message, chat_room.mes_id
						  FROM user INNER JOIN chat_room 
						  ON user.user_id = chat_room.user_id
						  WHERE chat_room.meal_id = :MealId AND mes_id > :MesId";
	}
	else
	{
		$oUser = new User();
		$oUser->SetUserName($_POST["user_name"]);
		if($oUser->CheckUsername()) //id not found
		{
			$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
			return;
		}
		
		$oUserRelation = new UserRelation();
		$oUserRelation->SetUser1Id($_SESSION['iUserId']);
		$oUserRelation->SetUser2Id($oUser->GetUserId());
		$oUserRelation->CheckRelation();
		$iRelationId = $oUserRelation->GetRelationId();
		if(!$iRelationId || ($oUserRelation->GetState() != 'ACCEPTED'))
		{
			$m_oJSONPrinter->printJSON("FALSE", "Relation not found", "NULL");
			return;
		}
		
		$sSqlStatement = "SELECT user.user_name, user.first_name, user.last_name, chat_room.message, chat_room.mes_id
						  FROM user INNER JOIN chat_room 
						  ON user.user_id = chat_room.user_id
						  WHERE chat_room.relation_id = :RelationId AND mes_id > :MesId";
	}
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		if(!empty($_POST["token"]))
			$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
		else
			$oStatement->bindParam(':RelationId', $iRelationId, PDO::PARAM_INT);
		$oStatement->bindParam(':MesId', $iMesId, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		$oOutputList = array();
		if($oSQLRow)
		{

			foreach ($oSQLRow as $sValue)
			{
				$oMessageList = array(
					"user_name" => $sValue[0],
					"first_name" => $sValue[1],
					"last_name" => $sValue[2],
					"message" => $sValue[3],
					"mes_id" => $sValue[4]
				);
				array_push($oOutputList, $oMessageList);
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

?>