<?php
include_once('../dataobjects/User.php');
include_once('../utility/utility.php');

$m_oSessionHandling = new SessionHandling();
$m_oSessionHandling->StartSession();
$m_oJSONPrinter = new JSONPrinter();

if(!isset($_GET["action"]))
{
	$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
	return;
}
$m_sAction = $_GET["action"];

if($m_sAction != "" && $m_sAction == "Login")
{
	Login();
}
elseif($m_sAction != "" && $m_sAction == "Logout")
{
	session_regenerate_id(true);
	$m_oSessionHandling->EndSession();
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
}
elseif($m_sAction != "" && $m_sAction == "CreateUser")
{
	CreateUser();
}
elseif($m_sAction != "" && $m_sAction == "EditProfile")
{
	EditProfile();
}
elseif($m_sAction != "" && $m_sAction == "ViewProfile")
{
	ViewProfile();
}
exit;

function Login(){
	global $g_oDatabase;
	global $m_oJSONPrinter;
	
	if (empty($_POST['user_name']) || empty($_POST['password']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$sSqlStatement = "SELECT user_id, hash FROM user WHERE user_name = :UserName" ;

	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':UserName', $_POST['user_name'], PDO::PARAM_STR, 64);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		
		if($oSQLRow)
		{
			if (password_verify($_POST['password'], $oSQLRow[1]))
			{
				$oUser = new User();
				$oUser->Load($oSQLRow[0]);
				$oUser->SetLastLoginTime(date('Y/m/d H:i:s'));
				$oUser->Update($oSQLRow[0]);
				
				$_SESSION['iUserId'] = $oSQLRow[0];
				session_regenerate_id(true);
				$m_oJSONPrinter->printJSON("TRUE", "NULL", $oSQLRow[0]);
				return;
			}
			else //wrong password
			{
				$m_oJSONPrinter->printJSON("FALSE", "Incorrect Password or Username", "NULL");
				return;
			}
		}
		else //username not found
		{
			$m_oJSONPrinter->printJSON("FALSE", "Incorrect Password or Username", "NULL");
			return;
		}
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function CreateUser(){
	global $m_oJSONPrinter;
	
	if (empty($_POST['user_name']) || empty($_POST['password']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	if(!ctype_alnum($_POST['user_name']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Alphanumeric characters only", "NULL");
		return;
	}
	if(strlen($_POST['password']) <= 4)
	{
		$m_oJSONPrinter->printJSON("FALSE", "Password must be at least 5 characters", "NULL");
		return;
	}
	
	$oUser = new User();
	if(!empty($_POST['first_name']))
		$oUser->SetFirstName($_POST['first_name']);
	if(!empty($_POST['last_name']))
		$oUser->SetLastName($_POST['last_name']);
	$oUser->SetUserName($_POST['user_name']);
	$oUser->SetHash($_POST['password']);
	if($oUser->CheckUsername())
	{
		$oUser->Create();
		$_SESSION['iUserId'] = $oUser->GetUserId();
		$m_oJSONPrinter->printJSON("TRUE", "NULL", $oUser->GetUserId());
		return;
	}
	else
	{
		$m_oJSONPrinter->printJSON("FALSE", "Username is taken", "NULL");
		return;
	}
}

function EditProfile(){
	global $m_oJSONPrinter;
	
	if(!isset($_SESSION['iUserId']) || empty($_POST['name']) || empty($_POST['gender']) || empty($_POST['age']) || empty($_POST['blurb']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oUser = new User();
	$oUser->Load($_SESSION['iUserId']);
	
	$oUser->SetName($_POST['name']);
	$oUser->SetGender($_POST['gender']);
	$oUser->SetAge($_POST['age']);
	$oUser->SetBlurb($_POST['blurb']);
	
	$oUser->Update($_SESSION['iUserId']);
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
	return;
}

function ViewProfile(){
	global $m_oJSONPrinter;
	if (!isset($_SESSION['iUserId']))
	{
		$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
		return;
	}
	
	$oUser = new User();
	if (isset($_GET["user_name"]))
	{
		$sUserName = $_GET["user_name"];
		$oUser->SetUserName($sUserName);
		if($oUser->CheckUsername()) //id not found
		{
			$m_oJSONPrinter->printJSON("FALSE", "Account not found", "NULL");
			return;
		}
	}
	else
	{
		$oUser->SetUserId($_SESSION['iUserId']);
	}
	$oUser->Load($oUser->GetUserId());
	$sIsFriend = 'SELF';
	if (isset($_GET["user_name"]))
	{
		if($_SESSION['iUserId'] != $oUser->GetUserId())
			$sIsFriend = 'NO';
		$sIsFriend = ViewProfileFriendHelper($_SESSION['iUserId'], $oUser->GetUserId());
	}
	$oUserAttributeList = array(
					"name" => $oUser->GetName(),
					"user_name" => $oUser->GetUserName(),
					"prof_img" => $oUser->GetImgPath(),
					"is_friend" => $sIsFriend
				);
	$oUserStatList = ViewProfileStatHelper($oUser->GetUserId());
	$oUserAttributeList['number_meals_attended'] = $oUserStatList[0];
	$oUserAttributeList['number_friends'] = $oUserStatList[1];
	$oUserAttributeList['number_meals_created'] = $oUserStatList[2];
	
	$m_oJSONPrinter->printJSON("TRUE", "NULL", $oUserAttributeList);
	return;
}

function ViewProfileFriendHelper($iUser1Id, $iUser2Id)
{
	global $g_oDatabase;
	
	$sSqlStatement = "SELECT * FROM user_relation
			          WHERE (user1_id = :User1Id AND user2_id = :User2Id AND state = 'ACCEPTED') OR 
					  (user2_id = :User1Id AND user1_id = :User2Id AND state = 'ACCEPTED')";
					  
	$sSqlStatement2 = "SELECT * FROM user_relation
			          WHERE (user1_id = :User1Id AND user2_id = :User2Id) OR 
					  (user2_id = :User1Id AND user1_id = :User2Id)";
			  			  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':User1Id', $iUser1Id, PDO::PARAM_INT);
		$oStatement->bindParam(':User2Id', $iUser2Id, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		
		if($oSQLRow)
			return "YES";
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement2);
		$oStatement->bindParam(':User1Id', $iUser1Id, PDO::PARAM_INT);
		$oStatement->bindParam(':User2Id', $iUser2Id, PDO::PARAM_INT);
		
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		
		if($oSQLRow)
			return "PENDING";
		return "NO";
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}

function ViewProfileStatHelper($iUserId)
{
	global $g_oDatabase;
	
	$sSqlStatement = "SELECT COUNT(*)
			  FROM meal_user INNER JOIN user
			  ON user.user_id = meal_user.user_id
			  WHERE user.user_id = :UserId AND meal_user.state = 'HOST'";
	
	$sSqlStatement2 = "SELECT COUNT(*)
			  FROM meal_user INNER JOIN user
			  ON user.user_id = meal_user.user_id
			  INNER JOIN meal
			  ON meal_user.meal_id = meal.meal_id
			  WHERE user.user_id = :UserId AND meal_user.state = 'GUEST' AND meal.state = 'COMPLETED'";
			  
	$sSqlStatement3 = "SELECT COUNT(*)
			  FROM user_relation INNER JOIN user
			  ON user.user_id = user_relation.user1_id OR user.user_id = user_relation.user2_id
			  WHERE user.user_id = :UserId AND user_relation.state = 'ACCEPTED'";
			  			  
	try
	{	
		$oStatement = $g_oDatabase->prepare($sSqlStatement);
		$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
		$oStatement->execute();
		$oSQLRow = $oStatement->fetch();
		$oStatement->closeCursor();
		if(!$oSQLRow)
			$oSQLRow[0] = -1;
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement2);
		$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
		$oStatement->execute();
		$oSQLRow2 = $oStatement->fetch();
		$oStatement->closeCursor();
		if(!$oSQLRow2)
			$oSQLRow2[0] = -1;
		
		$oStatement = $g_oDatabase->prepare($sSqlStatement3);
		$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
		$oStatement->execute();
		$oSQLRow3 = $oStatement->fetch();
		$oStatement->closeCursor();
		if(!$oSQLRow3)
			$oSQLRow3[0] = -1;
		
		return array((string)$oSQLRow2[0], (string)$oSQLRow3[0], (string)$oSQLRow[0]);
	}
	catch (PDOException $oPDOException)
	{
		$oErrorHandling = new ErrorHandling();
		$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
		exit;
	}
}
?>