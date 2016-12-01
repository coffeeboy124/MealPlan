<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class MealRestaurant
{
	private $m_iMrId;
	private $m_iMealId;
	private $m_iUserId;
	private $m_sRestaurantId;
	private $m_sRestaurantName;
	private $m_sState;

	function GetMrId()
	{
		return $this->m_iMrId;
	}
	function GetMealId()
	{
		return $this->m_iMealId;
	}
	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetRestaurantId()
	{
		return $this->m_sRestaurantId;
	}
	function GetRestaurantName()
	{
		return $this->m_sRestaurantName;
	}
	function GetState()
	{
		return $this->m_sState;
	}

	function SetMrId($iMrId) 
	{
		$this->m_iMrId = $iMrId; 
	}
	function SetMealId($iMealId) 
	{
		$this->m_iMealId = $iMealId; 
	}
	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetRestaurantId($sRestaurantId) 
	{
		$this->m_sRestaurantId = StringHandling::FilterDatabaseString($sRestaurantId, 64);
	}
	function SetRestaurantName($sRestaurantName) 
	{
		$this->m_sRestaurantName = StringHandling::FilterDatabaseString($sRestaurantName, 64);
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}

	function MealRestaurant()
	{ 
		$this->SetRestaurantId('');
		$this->SetRestaurantName('');
		$this->SetState('');
	} 

	function Update($iMrId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE meal_restaurant
			SET meal_id = :MealId, user_id = :UserId, restaurant_id = :RestaurantId, restaurant_name = :RestaurantName, state = :State 
			WHERE mr_id = :MrId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':RestaurantId', $this->m_sRestaurantId, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':RestaurantName', $this->m_sRestaurantName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':MrId', $iMrId, PDO::PARAM_INT);
			
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

	function Load($iMrId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT mr_id, meal_id, user_id, restaurant_id, restaurant_name, state
			FROM meal_restaurant
			WHERE mr_id = :MrId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MrId', $iMrId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iMrId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_iMealId = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_iUserId = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sRestaurantId = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_sRestaurantName = $oSQLRow[4];
				}
				if ($oSQLRow[5] != NULL)
				{
					$this->m_sState = $oSQLRow[5];
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

	function Delete($iMrId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM meal_restaurant WHERE mr_id = :MrId";
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MrId', $iMrId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO meal_restaurant ( meal_id, user_id, restaurant_id, restaurant_name, state )
			VALUES ( :MealId, :UserId, :RestaurantId, :RestaurantName, :State )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':RestaurantId', $this->m_sRestaurantId, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':RestaurantName', $this->m_sRestaurantName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iMrId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckVote()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT mr_id
			FROM meal_restaurant
			WHERE restaurant_id = :RestaurantId AND user_id = :UserId AND meal_id = :MealId";
			
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':RestaurantId', $this->m_sRestaurantId, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->SetMrId($oSQLRow[0]);
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