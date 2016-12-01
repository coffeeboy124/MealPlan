<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class Meal
{
	private $m_iMealId;
	private $m_sTimeSlot;
	private $m_sRestaurantName;
	private $m_sRestaurantLocation;
	private $m_sState;
	private $m_sName;
	private $m_sToken;
	private $m_tCreateTime;

	function GetMealId()
	{
		return $this->m_iMealId;
	}
	function GetTimeSlot()
	{
		return $this->m_sTimeSlot;
	}
	function GetRestaurantName()
	{
		return $this->m_sRestaurantName;
	}
	function GetRestaurantLocation()
	{
		return $this->m_sRestaurantLocation;
	}
	function GetState()
	{
		return $this->m_sState;
	}
	function GetName()
	{
		return $this->m_sName;
	}
	function GetToken()
	{
		return $this->m_sToken;
	}
	function GetCreateTime()
	{
		return $this->m_tCreateTime;
	}
	
	function SetMealId($iMealId) 
	{
		$this->m_iMealId = $iMealId; 
	}
	function SetTimeSlot($sTimeSlot) 
	{
		$this->m_sTimeSlot = StringHandling::FilterDatabaseString($sTimeSlot, 32);
	}
	function SetRestaurantName($sRestaurantName) 
	{
		$this->m_sRestaurantName = StringHandling::FilterDatabaseString($sRestaurantName, 64);
	}
	function SetRestaurantLocation($sRestaurantLocation) 
	{
		$this->m_sRestaurantLocation = StringHandling::FilterDatabaseString($sRestaurantLocation, 64);
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}
	function SetName($sName) 
	{
		$this->m_sName = StringHandling::FilterDatabaseString($sName, 64);
	}
	function SetToken($sToken) 
	{
		$this->m_sToken = StringHandling::FilterDatabaseString($sToken, 64);
	}
	function SetCreateTime($tCreateTime) 
	{
		$this->m_tCreateTime = str_replace("'", "''", $tCreateTime);
	}

	function Meal()
	{ 
		$this->SetTimeSlot('');
		$this->SetRestaurantName('');
		$this->SetRestaurantLocation('');
		$this->SetState('');
		$this->SetName('');
		$this->SetToken('');
		$this->SetCreateTime(date('Y/m/d H:i:s'));
	} 

	function Update($iMealId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE meal
			SET time_slot = :TimeSlot, restaurant_name = :RestaurantName, restaurant_location = :RestaurantLocation, state = :State, name = :Name, token = :Token, create_time = :CreateTime 
			WHERE meal_id = :MealId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':TimeSlot', $this->m_sTimeSlot, PDO::PARAM_STR, 32);
			$oStatement->bindParam(':RestaurantName', $this->m_sRestaurantName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':RestaurantLocation', $this->m_sRestaurantLocation, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Token', $this->m_sToken, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
			
			$iRowCount = $oStatement->execute();
			$oStatement->closeCursor();
			return $iRowCount;
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('SqlStatement = ' . $sSqlStatement . '<br>System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}

	function Load($iMealId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT meal_id, time_slot, restaurant_name, restaurant_location, state, name, token, create_time
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
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iMealId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_sTimeSlot = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_sRestaurantName = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sRestaurantLocation = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_sState = $oSQLRow[4];
				}
				if ($oSQLRow[5] != NULL)
				{
					$this->m_sName = $oSQLRow[5];
				}
				if ($oSQLRow[6] != NULL)
				{
					$this->m_sToken = $oSQLRow[6];
				}
				if ($oSQLRow[7] != NULL)
				{
					$this->m_tCreateTime = $oSQLRow[7];
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

	function Delete($iMealId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM meal WHERE meal_id = :MealId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $iMealId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO meal ( time_slot, restaurant_name, restaurant_location, state, name, token, create_time )
			VALUES ( :TimeSlot, :RestaurantName, :RestaurantLocation, :State, :Name, :Token, :CreateTime )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':TimeSlot', $this->m_sTimeSlot, PDO::PARAM_STR, 32);
			$oStatement->bindParam(':RestaurantName', $this->m_sRestaurantName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':RestaurantLocation', $this->m_sRestaurantLocation, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':Token', $this->m_sToken, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iMealId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckToken()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT meal_id
			FROM meal
			WHERE token = :Token" ;
			
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':Token', $this->m_sToken, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->SetMealId($oSQLRow[0]);
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