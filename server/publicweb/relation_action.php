<?php
include_once('../dataobjects/UserRelation.php');
include_once('../dataobjects/User.php');
include_once('../utility/utility.php');

$m_oSessionHandling = new SessionHandling();
$m_oSessionHandling->StartSession();
$m_oJSONPrinter = new JSONPrinter();
$m_iMatchMakingLimit = 5;
$m_iMaximumDistance = 32.1869; //20 miles

if(!isset($_SESSION['iUserId']) || !isset($_GET["action"]))
{
	$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
	return;
}
$m_sAction = $_GET["action"];

if($m_sAction != "" && $m_sAction == "CreateRelation")
{
	CreateRelation();
}
elseif($m_sAction != "" && $m_sAction == "ListRelations")
{
	ListRelations();
}
elseif($m_sAction != "" && $m_sAction == "AcceptRelation")
{
	AcceptRelation();
}
elseif($m_sAction != "" && $m_sAction == "DeleteRelation")
{
	DeleteRelation();
}
elseif($m_sAction != "" && $m_sAction == "CreateMatchMakingList")
{
	CreateMatchMakingList();
}


exit;

function ListRelations(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	$sSqlStatement = "SELECT user.user_name, user_relation.state, user.img_path
					  FROM user INNER JOIN user_relation 
					  ON user.user_id = user_relation.user2_id
					  WHERE user_relation.user1_id = :UserId" ;
	$sSqlStatement2 = "SELECT user.user_name, user_relation.state, user.img_path
					  FROM user INNER JOIN user_relation 
					  ON user.user_id = user_relation.user1_id
					  WHERE user_relation.user2_id = :UserId" ;							  
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
				if($sValue[1] == "INVITED")
					continue;
				
				$oRelationList = array(
					"user_name" => $sValue[0],
					"state" => $sValue[1],
					"prof_img" => $sValue[2]
				);
				array_push($oOutputList, $oRelationList);
			}
		}
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement2);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			foreach ($oSQLRow as $sValue)
			{
				$oRelationList = array(
					"user_name" => $sValue[0],
					"state" => $sValue[1],
					"prof_img" => $sValue[2]
				);
				array_push($oOutputList, $oRelationList);
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

function CreateRelation(){
	global $m_oJSONPrinter;

	if (!isset($_GET["user_name"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sUserName = $_GET["user_name"];
	
	$oUser = new User();
	$oUser->SetUserName($sUserName);
	if($oUser->CheckUsername()) //id not found
	{
		$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
		return;
	}
	if($oUser->GetUserId() == $_SESSION['iUserId']) //cant friend yourself
	{
		$m_oJSONPrinter->printJSON("FALSE", "Cant friend yourself", "NULL");
		return;
	}
	
	$oUserRelation = new UserRelation();
	$oUserRelation->SetUser1Id($_SESSION['iUserId']);
	$oUserRelation->SetUser2Id($oUser->GetUserId());
	$oUserRelation->SetState('INVITED');
	if($oUserRelation->CheckRelation())
	{
		$oUserRelation->Create();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
		return;
	}
	else
	{
		$m_oJSONPrinter->printJSON("FALSE", "Relation already exists", "NULL");
		return;
	}
}

function AcceptRelation(){
	global $g_oDatabase;
	global $m_oJSONPrinter;

	if (!isset($_GET["user_name"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sUserName = $_GET["user_name"];
	
	$oUser = new User();
	$oUser->SetUserName($sUserName);
	if($oUser->CheckUsername()) //id not found
	{
		$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
		return;
	}
	$iOtherUserId = $oUser->GetUserId();
	
	$sSqlStatement = "SELECT relation_id
					  FROM user_relation 
					  WHERE user1_id = :User1Id AND user2_id = :User2Id";	    
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':User1Id', $iOtherUserId, PDO::PARAM_INT);
		$oStatement->bindParam(':User2Id', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$oUserRelation = new UserRelation();
			$oUserRelation->Load($oSQLRow[0]);
			$oUserRelation->SetState('ACCEPTED');
			$oUserRelation->Update($oSQLRow[0]);
			$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
			return;
		}
		$m_oJSONPrinter->printJSON("FALSE", "Relation not found", "NULL");
		return;
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function DeleteRelation(){
	global $g_oDatabase;
	global $m_oJSONPrinter;

	if (!isset($_GET["user_name"]))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	$sUserName = $_GET["user_name"];
	
	$oUser = new User();
	$oUser->SetUserName($sUserName);
	if($oUser->CheckUsername()) //id not found
	{
		$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
		return;
	}
	$iOtherUserId = $oUser->GetUserId();
	
	$sSqlStatement = "DELETE FROM user_relation 
					  WHERE (user1_id = :User2Id AND user2_id = :User1Id) OR
					  (user2_id = :User2Id AND user1_id = :User1Id)";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':User1Id', $iOtherUserId, PDO::PARAM_INT);
		$oStatement->bindParam(':User2Id', $_SESSION['iUserId'], PDO::PARAM_INT);
		
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

function CreateMatchMakingList(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	global $m_iMatchMakingLimit;
	global $m_iMaximumDistance;
	
	$oUser = new User();
	$oUser->Load($_SESSION['iUserId']);
	if(!$oUser->GetMatchEnabled())
	{
		$m_oJSONPrinter->printJSON("FALSE", "Must enable matchmaking", "NULL");
		return;
	}
	$sSqlStatement = "UPDATE user_relation SET state = 'MM_SEEN' 
					  WHERE state = 'MM_DECIDING' AND user1_id = :UserId";
					  
	//$sSqlStatement2 = "SELECT user_id, age, pref_age_range, location_latitude, location_longitude FROM user 
	//				  WHERE match_enabled = 1 AND gender = :PrefGender AND pref_gender = :Gender AND user_id != :UserId";
	
	$sSqlStatement2 = "SELECT user_id, age, pref_age_range, location_latitude, location_longitude FROM user 
					  WHERE user_id != :UserId";
					  
	$sSqlStatement3 = "DELETE FROM user_relation
					  WHERE state = 'MM_SEEN' AND user1_id = :UserId";
					  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		
		$oStatement->execute();
		$oStatement->closeCursor();
	
		$oStatement = $g_oDatabase->prepare($sSqlStatement2);
		$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
		//$oStatement->bindParam(':PrefGender', $oUser->GetPrefGender, PDO::PARAM_STR, 8);
		//$oStatement->bindParam(':Gender', $oUser->GetGender, PDO::PARAM_STR, 8);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetchall();
		$oStatement->closeCursor();
		if($oSQLRow)
		{
			$i = 0;
			foreach ($oSQLRow as $sValue)
			{
				if($i == $m_iMatchMakingLimit)
				{
					$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
					return;
				}
				/*age filtering.
				$oPrefAgeRange = explode("-", $oUser->GetPrefAgeRange());
				if(intval($oPrefAgeRange[0]) > $sValue[1] || intval($oPrefAgeRange[1]) < $sValue[1])
					continue;
				$oRequiredAgeRange = explode ("-", $sValue[2]);
				if(intval($oRequiredAgeRange[0]) > $oUser->GetAge() || intval($oRequiredAgeRange[1]) < $oUser->GetAge())
					continue;
				*/
				/*relation filtering*/
				$oUserRelation = new UserRelation();
				$oUserRelation->SetUser1Id($_SESSION['iUserId']);
				$oUserRelation->SetUser2Id($sValue[0]);
				$oUserRelation->SetState("MM_DECIDING");
				if($oUserRelation->CheckRelation())
				{
					
					/*distance filtering. displays closest users up to $m_iMaximumDistance radius. NOT IMPLEMENTED. distance finding function in utility under LocationHandling*/
					$oUserRelation->Create();
					++$i;
				}
			}
			
			if($i == 0)
			{
				$oStatement = $g_oDatabase->prepare($sSqlStatement3);
				$oStatement->bindParam(':UserId', $_SESSION['iUserId'], PDO::PARAM_INT);
				
				$oStatement->execute();
				$oStatement->closeCursor();
			}
		}
		
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

?>