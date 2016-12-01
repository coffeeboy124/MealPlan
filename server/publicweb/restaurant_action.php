<?php
include_once('../dataobjects/MealRestaurant.php');
include_once('../dataobjects/User.php');
include_once('../dataobjects/Meal.php');
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

if($m_sAction != "" && $m_sAction == "CreateVote")
{
	CreateVote();
}
elseif($m_sAction != "" && $m_sAction == "ListVotes")
{
	ListVotes();
}
elseif($m_sAction != "" && $m_sAction == "DeleteVote")
{
	DeleteVote();
}

exit;

function ListVotes(){
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
	
	$sSqlStatement = "SELECT user.user_name, user.img_path, meal_restaurant.restaurant_id, meal_restaurant.restaurant_name, meal_restaurant.state, meal_restaurant.mr_id
					  FROM user INNER JOIN meal_restaurant 
					  ON user.user_id = meal_restaurant.user_id
					  WHERE meal_restaurant.meal_id = :MealId" ;
					  
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
				$oVoteList = array(
					"user_name" => $sValue[0],
					"prof_pic" => $sValue[1],
					"restaurant_id" => $sValue[2],
					"restaurant_name" => $sValue[3],
					"state" => $sValue[4],
					"id" => $sValue[5]
				);
				array_push($oOutputList, $oVoteList);
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

function CreateVote(){
	global $m_oJSONPrinter;
	
	if (empty($_POST["token"]) || empty($_POST["restaurant_id"]) || empty($_POST["state"]) || empty($_POST["restaurant_name"]))
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
	
	$oMealRestaurant = new MealRestaurant();
	$oMealRestaurant->SetUserId($_SESSION['iUserId']);
	$oMealRestaurant->SetMealId($iMealId);
	$oMealRestaurant->SetRestaurantId($_POST["restaurant_id"]);
	$oMealRestaurant->SetRestaurantName($_POST["restaurant_name"]);
	$oMealRestaurant->SetState($_POST["state"]);
	if($oMealRestaurant->CheckVote())
	{
		$oMealRestaurant->Create();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	else
	{
		$m_oJSONPrinter->printJSON("FALSE", "Already voted for this restaurant", "NULL");
		return;
	}
}

function DeleteVote(){
	global $g_oDatabase;
	global $m_oJSONPrinter;

	if (!isset($_GET["mr_id"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$iMrId = $_GET["mr_id"];
	
	$oMealRestaurant = new MealRestaurant();
	if(!$oMealRestaurant->Load($iMrId))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Vote not found", "NULL");
		return;
	}
	if($oMealRestaurant->GetUserId() != $_SESSION['iUserId'])
	{
		$m_oJSONPrinter->printJSON("FALSE", "Vote not found", "NULL");
		return;
	}
	
	$oMealRestaurant->Delete($iMrId);
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
}

?>