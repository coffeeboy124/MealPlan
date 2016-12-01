<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class TimeSheet
{
	private $m_iSheetId;
	private $m_iUserId;
	private $m_sState;
	private $m_sName;

	function GetSheetId()
	{
		return $this->m_iSheetId;
	}
	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetState()
	{
		return $this->m_sState;
	}
	function GetName()
	{
		return $this->m_sName;
	}

	function SetSheetId($iSheetId) 
	{
		$this->m_iSheetId = $iSheetId; 
	}
	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}
	function SetName($sName) 
	{
		$this->m_sName = StringHandling::FilterDatabaseString($sName, 64);
	}

	function TimeSheets()
	{ 
		$this->SetState('');
		$this->SetName('');
	} 

	function Update($iSheetId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE time_sheet
			SET user_id = :UserId, state = :State, name = :Name 
			WHERE sheet_id = :SheetId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
			
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

	function Load($iSheetId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT sheet_id, user_id, state, name
			FROM time_sheet
			WHERE sheet_id = :SheetId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iSheetId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_iUserId = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_sState = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sName = $oSQLRow[3];
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

	function Delete($iSheetId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM time_sheet WHERE sheet_id = :SheetId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':SheetId', $iSheetId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO time_sheet ( user_id, state, name )
			VALUES ( :UserId, :State, :Name )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iSheetId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckTimeSheet()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT user_id
			FROM time_sheet
			WHERE user_id = :UserId AND name = :Name" ;
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->SetUserId($oSQLRow[0]);
				return FALSE;
			}
			else
			{
				return TRUE;
			}
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function GetActiveTimeSheet()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT sheet_id
			FROM time_sheet
			WHERE user_id = :UserId AND state = 'ACTIVE'" ;
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
				return $oSQLRow[0];
			else
				return -1;
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