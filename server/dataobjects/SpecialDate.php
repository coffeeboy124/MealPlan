<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class SpecialDate
{
	private $m_iDateId;
	private $m_iUserId;
	private $m_sStartDate;
	private $m_sEndDate;
	private $m_sName;
	private $m_sState;

	function GetDateId()
	{
		return $this->m_iDateId;
	}
	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetStartDate()
	{
		return $this->m_sStartDate;
	}
	function GetEndDate()
	{
		return $this->m_sEndDate;
	}
	function GetName()
	{
		return $this->m_sName;
	}
	function GetState()
	{
		return $this->m_sState;
	}

	function SetDateId($iDateId) 
	{
		$this->m_iDateId = $iDateId; 
	}
	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetStartDate($sStartDate) 
	{
		$this->m_sStartDate = StringHandling::FilterDatabaseString($sStartDate, 16);
	}
	function SetEndDate($sEndDate) 
	{
		$this->m_sEndDate = StringHandling::FilterDatabaseString($sEndDate, 16);
	}
	function SetName($sName) 
	{
		$this->m_sName = StringHandling::FilterDatabaseString($sName, 64);
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}

	function SpecialDate()
	{ 
		$this->SetStartDate('');
		$this->SetEndDate('');
		$this->SetName('');
		$this->SetState('');
	} 

	function Update($iDateId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE special_date
			SET user_id = :UserId, start_date = :StartDate, end_date = :EndDate, name = :Name state = :State
			WHERE date_id = :DateId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':StartDate', $this->m_sStartDate, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':EndDate', $this->m_sEndDate, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':DateId', $iDateId, PDO::PARAM_INT);
			
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

	function Load($iDateId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT date_id, user_id, start_date, end_date, name, state
			FROM special_date
			WHERE date_id = :DateId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':DateId', $iDateId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iDateId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_iUserId = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_sStartDate = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sEndDate = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_sName = $oSQLRow[4];
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

	function Delete($iDateId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM special_date WHERE date_id = :DateId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':DateId', $iDateId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO special_date ( user_id, start_date, end_date, name, state )
			VALUES ( :UserId, :StartDate, :EndDate, :Name, :State )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':StartDate', $this->m_sStartDate, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':EndDate', $this->m_sEndDate, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':Name', $this->m_sName, PDO::PARAM_STR, 64);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iDateId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckSpecialDate()
	{
		global $g_oDatabase;
		$oTimeHandling = new TimeHandling();
		
		$sSqlStatement = "SELECT start_date, end_date
			FROM busy_slot
			WHERE user_id = :UserId" ;

		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetchall();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{				
				foreach ($oSQLRow as $sBusySlots)
				{
					$sResult = $oTimeHandling->TimeOverlap($oTimeHandling->CreateDateTime($this->m_sStartDate), 
											               $oTimeHandling->CreateDateTime($this->m_sEndDate), 
														   $oTimeHandling->CreateDateTime($sBusySlots[0]), 
														   $oTimeHandling->CreateDateTime($sBusySlots[1])); //dont call it more than once!
					if($sResult)
					{
						//echo $sResult . "<br>";
						return FALSE;
					}

				}
			}
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