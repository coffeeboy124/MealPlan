<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class MealUser
{
	private $m_iMuId;
	private $m_iMealId;
	private $m_iUserId;
	private $m_iSheetId;
	private $m_sState;

	function GetMuId()
	{
		return $this->m_iMuId;
	}
	function GetMealId()
	{
		return $this->m_iMealId;
	}
	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetSheetId()
	{
		return $this->m_iSheetId;
	}
	function GetState()
	{
		return $this->m_sState;
	}
	

	function SetMuId($iMuId) 
	{
		$this->m_iMuId = $iMuId; 
	}
	function SetMealId($iMealId) 
	{
		$this->m_iMealId = $iMealId; 
	}
	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetSheetId($iSheetId) 
	{
		$this->m_iSheetId = $iSheetId; 
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}

	function MealUser()
	{ 
		$this->SetState('');
	} 

	function Update($iMuId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE meal_user
			SET meal_id = :MealId, user_id = :UserId, sheet_id = :SheetId,state = :State 
			WHERE mu_id = :MuId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':SheetId', $this->m_iSheetId, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':MuId', $iMuId, PDO::PARAM_INT);
			
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

	function Load($iMuId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT mu_id, meal_id, user_id, state, sheet_id
			FROM meal_user
			WHERE mu_id = :MuId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MuId', $iMuId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iMuId = $oSQLRow[0];
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
					$this->m_sState = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_iSheetId = $oSQLRow[4];
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

	function Delete($iMuId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM meal_user WHERE mu_id = :MuId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MuId', $iMuId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO meal_user ( meal_id, user_id, sheet_id, state )
			VALUES ( :MealId, :UserId, :SheetId, :State )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':SheetId', $this->m_iSheetId, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 8);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iMuId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckUserID()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT mu_id
			FROM meal_user
			WHERE user_id = :UserId AND meal_id = :MealId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->m_iMuId = $oSQLRow[0];
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