<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class User
{
	private $m_iUserId;
	private $m_sFbId;
	private $m_sUserName;
	private $m_sName;
	private $m_sGender;
	private $m_iAge;
	private $m_sBlurb;
	private $m_bMatchEnabled;
	private $m_sPrefGender;
	private $m_sPrefAgeRange;
	private $m_iPrefFood;
	private $m_fLocationLatitude;
	private $m_fLocationLongitude;
	private $m_sImgPath;
	private $m_sHash;
	private $m_tCreateTime;
	private $m_tLastLoginTime;

	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetFbId()
	{
		return $this->m_sFbId;
	}
	function GetUserName()
	{
		return $this->m_sUserName;
	}
	function GetName()
	{
		return $this->m_sName;
	}
	function GetGender()
	{
		return $this->m_sGender;
	}
	function GetAge()
	{
		return $this->m_iAge;
	}
	function GetBlurb()
	{
		return $this->m_sBlurb;
	}
	function GetMatchEnabled()
	{
		return $this->m_bMatchEnabled;
	}
	function GetPrefGender()
	{
		return $this->m_sPrefGender;
	}
	function GetPrefAgeRange()
	{
		return $this->m_sPrefAgeRange;
	}
	function GetPrefFood()
	{
		return $this->m_iPrefFood;
	}
	function GetLocationLatitude()
	{
		return $this->m_fLocationLatitude;
	}
	function GetLocationLongitude()
	{
		return $this->m_fLocationLongitude;
	}
	function GetImgPath()
	{
		return $this->m_sImgPath;
	}
	function GetHash()
	{
		return $this->m_sHash;
	}
	function GetCreateTime()
	{
		return $this->m_tCreateTime;
	}
	function GetLastLoginTime()
	{
		return $this->m_tLastLoginTime;
	}

	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetFbId($sFbId) 
	{
		$this->m_sFbId = StringHandling::FilterDatabaseString($sFbId, 64);
	}
	function SetUserName($sUserName) 
	{
		$this->m_sUserName = StringHandling::FilterDatabaseString($sUserName, 64);
	}
	function SetName($sName) 
	{
		$this->m_sName = StringHandling::FilterDatabaseString($sName, 64);
	}
	function SetGender($sGender) 
	{
		$this->m_sGender = StringHandling::FilterDatabaseString($sGender, 8);
	}
	function SetAge($iAge) 
	{
		$this->m_iAge = $iAge; 
	}
	function SetBlurb($sBlurb) 
	{
		$this->m_sBlurb = StringHandling::FilterDatabaseString($sBlurb, 255);
	}
	function SetMatchEnabled($bMatchEnabled) 
	{
		$this->m_bMatchEnabled = $bMatchEnabled; 
	}
	function SetPrefGender($sPrefGender) 
	{
		$this->m_sPrefGender = StringHandling::FilterDatabaseString($sPrefGender, 8);
	}
	function SetPrefAgeRange($sPrefAgeRange) 
	{
		$this->m_sPrefAgeRange = StringHandling::FilterDatabaseString($sPrefAgeRange, 8);
	}
	function SetPrefFood($iPrefFood) 
	{
		$this->m_iPrefFood = $iPrefFood; 
	}
	function SetLocationLatitude($fLocationLatitude) 
	{
		$this->m_fLocationLatitude = $fLocationLatitude; 
	}
	function SetLocationLongitude($fLocationLongitude) 
	{
		$this->m_fLocationLongitude = $fLocationLongitude; 
	}
	function SetImgPath($sImgPath) 
	{
		$this->m_sImgPath = StringHandling::FilterDatabaseString($sImgPath, 32);
	}
	function SetHash($sHash) 
	{
		$this->m_sHash = StringHandling::FilterDatabaseString($sHash, 60);
		$this->m_sHash = password_hash($this->m_sHash, PASSWORD_BCRYPT);
	}
	function SetCreateTime($tCreateTime) 
	{
		$this->m_tCreateTime = str_replace("'", "''", $tCreateTime);
	}
	function SetLastLoginTime($tLastLoginTime) 
	{
		$this->m_tLastLoginTime = str_replace("'", "''", $tLastLoginTime);
	}

	function User()
	{ 
		$this->SetFbId('');
		$this->SetUserName('');
		$this->SetName('');
		$this->SetGender('');
		$this->SetBlurb('');
		$this->SetPrefGender('');
		$this->SetPrefAgeRange('');
		$this->SetImgPath('');
		$this->SetHash('');
		$this->SetCreateTime(date('Y/m/d H:i:s'));
		$this->SetLastLoginTime(date('Y/m/d H:i:s'));
	} 

	function Update($iUserId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE user
			SET fb_id = :FbId, user_name = :UserName, name = :Name, gender = :Gender, age = :Age, blurb = :Blurb, match_enabled = :MatchEnabled, pref_gender = :PrefGender, pref_age_range = :PrefAgeRange, pref_food = :PrefFood, location_latitude = :LocationLatitude, location_longitude = :LocationLongitude, img_path = :ImgPath, hash = :Hash, create_time = :CreateTime, last_login_time = :LastLoginTime
			WHERE user_id = :UserId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':FbId', $this->m_sFbId, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':UserName', $this->m_sUserName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Gender', $this->m_sGender, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':Age', $this->m_iAge, PDO::PARAM_INT);
			$oStatement->bindParam(':Blurb', $this->m_sBlurb, PDO::PARAM_STR, 255);
			$oStatement->bindParam(':MatchEnabled', $this->m_bMatchEnabled, PDO::PARAM_INT);
			$oStatement->bindParam(':PrefGender', $this->m_sPrefGender, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':PrefAgeRange', $this->m_sPrefAgeRange, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':PrefFood', $this->m_iPrefFood, PDO::PARAM_INT);
			$oStatement->bindParam(':LocationLatitude', $this->m_fLocationLatitude, PDO::PARAM_STR);
			$oStatement->bindParam(':LocationLongitude', $this->m_fLocationLongitude, PDO::PARAM_STR);
			$oStatement->bindParam(':ImgPath', $this->m_sImgPath, PDO::PARAM_STR, 32);
			$oStatement->bindParam(':Hash', $this->m_sHash, PDO::PARAM_STR, 60);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			$oStatement->bindParam(':LastLoginTime', $this->m_tLastLoginTime, PDO::PARAM_STR, 19);
			$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
			
			$iRowCount = $oStatement->execute();
			$oStatement->closeCursor();
			return $iRowCount;
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}

	function Load($iUserId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT user_id, fb_id, user_name, name, gender, age, blurb, match_enabled, pref_gender, pref_age_range, pref_food, location_latitude, location_longitude, img_path, hash, create_time, last_login_time
			FROM user
			WHERE user_id = :UserId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iUserId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_sFbId = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_sUserName = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sName = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_sGender = $oSQLRow[4];
				}
				if ($oSQLRow[5] != NULL)
				{
					$this->m_iAge = $oSQLRow[5];
				}
				if ($oSQLRow[6] != NULL)
				{
					$this->m_sBlurb = $oSQLRow[6];
				}
				if ($oSQLRow[7] != NULL)
				{
					$this->m_bMatchEnabled = $oSQLRow[7];
				}
				if ($oSQLRow[8] != NULL)
				{
					$this->m_sPrefGender = $oSQLRow[8];
				}
				if ($oSQLRow[9] != NULL)
				{
					$this->m_sPrefAgeRange = $oSQLRow[9];
				}
				if ($oSQLRow[10] != NULL)
				{
					$this->m_iPrefFood = $oSQLRow[10];
				}
				if ($oSQLRow[11] != NULL)
				{
					$this->m_fLocationLatitude = $oSQLRow[11];
				}
				if ($oSQLRow[12] != NULL)
				{
					$this->m_fLocationLongitude = $oSQLRow[12];
				}
				if ($oSQLRow[13] != NULL)
				{
					$this->m_sImgPath = $oSQLRow[13];
				}
				if ($oSQLRow[14] != NULL)
				{
					$this->m_sHash = $oSQLRow[14];
				}
				if ($oSQLRow[15] != NULL)
				{
					$this->m_tCreateTime = $oSQLRow[15];
				}
				if ($oSQLRow[16] != NULL)
				{
					$this->m_tLastLoginTime = $oSQLRow[16];
				}
				
				return true;
			}
			else
			{
				return false;
			}
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}

	function Delete($iUserId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM user WHERE user_id = :UserId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $iUserId, PDO::PARAM_INT);
			
			$iRowCount = $oStatement->execute();
			$oStatement->closeCursor();
			return $iRowCount;
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}

	function Create()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "INSERT INTO user ( fb_id, user_name, name, gender, age, blurb, match_enabled, pref_gender, pref_age_range, pref_food, location_latitude, location_longitude, img_path, hash, create_time, last_login_time )
			VALUES ( :FbId, :UserName, :Name, :Gender, :Age, :Blurb, :MatchEnabled, :PrefGender, :PrefAgeRange, :PrefFood, :LocationLatitude, :LocationLongitude, :ImgPath, :Hash, :CreateTime, :LastLoginTime )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserName', $this->m_sUserName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':FbId', $this->m_sFbId, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':UserName', $this->m_sUserName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Gender', $this->m_sGender, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':Age', $this->m_iAge, PDO::PARAM_INT);
			$oStatement->bindParam(':Blurb', $this->m_sBlurb, PDO::PARAM_STR, 255);
			$oStatement->bindParam(':MatchEnabled', $this->m_bMatchEnabled, PDO::PARAM_INT);
			$oStatement->bindParam(':PrefGender', $this->m_sPrefGender, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':PrefAgeRange', $this->m_sPrefAgeRange, PDO::PARAM_STR, 8);
			$oStatement->bindParam(':PrefFood', $this->m_iPrefFood, PDO::PARAM_INT);
			$oStatement->bindParam(':LocationLatitude', $this->m_fLocationLatitude, PDO::PARAM_STR);
			$oStatement->bindParam(':LocationLongitude', $this->m_fLocationLongitude, PDO::PARAM_STR);
			$oStatement->bindParam(':ImgPath', $this->m_sImgPath, PDO::PARAM_STR, 32);
			$oStatement->bindParam(':Hash', $this->m_sHash, PDO::PARAM_STR, 60);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			$oStatement->bindParam(':LastLoginTime', $this->m_tLastLoginTime, PDO::PARAM_STR, 19);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iUserId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckUsername()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT user_id
			FROM user
			WHERE user_name = :UserName" ;
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserName', $this->m_sUserName, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->SetUserId($oSQLRow[0]);
				return FALSE;
			}
			else
				return TRUE;
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}

}

?>