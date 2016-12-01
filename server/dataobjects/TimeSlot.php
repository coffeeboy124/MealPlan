<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class TimeSlot
{
	private $m_iTimeId;
	private $m_iSheetId;
	private $m_sTimeSlot;

	function GetTimeId()
	{
		return $this->m_iTimeId;
	}
	function GetSheetId()
	{
		return $this->m_iSheetId;
	}
	function GetTimeSlot()
	{
		return $this->m_sTimeSlot;
	}

	function SetTimeId($iTimeId) 
	{
		$this->m_iTimeId = $iTimeId; 
	}
	function SetSheetId($iSheetId) 
	{
		$this->m_iSheetId = $iSheetId; 
	}
	function SetTimeSlot($sTimeSlot) 
	{
		$this->m_sTimeSlot = StringHandling::FilterDatabaseString($sTimeSlot, 16);
	}

	function TimeSlot()
	{ 
		$this->SetTimeSlot('');
	} 

	function Update($iTimeId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE time_slot
			SET sheet_id = :SheetId, time_slot = :TimeSlot 
			WHERE time_id = :TimeId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':SheetId', $this->m_iSheetId, PDO::PARAM_INT);
			$oStatement->bindParam(':TimeSlot', $this->m_sTimeSlot, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':TimeId', $iTimeId, PDO::PARAM_INT);
			
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

	function Load($iTimeId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT time_id, sheet_id, time_slot
			FROM time_slot
			WHERE time_id = :TimeId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':TimeId', $iTimeId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iTimeId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_iSheetId = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_sTimeSlot = $oSQLRow[2];
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

	function Delete($iTimeId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM time_slot WHERE time_id = :TimeId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':TimeId', $iTimeId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO time_slot ( sheet_id, time_slot )
			VALUES ( :SheetId, :TimeSlot )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':SheetId', $this->m_iSheetId, PDO::PARAM_INT);
			$oStatement->bindParam(':TimeSlot', $this->m_sTimeSlot, PDO::PARAM_STR, 16);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iTimeId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckTimeSlot()
	{
		global $g_oDatabase;
		$oTimeHandling = new TimeHandling();
		
		$sSqlStatement = "SELECT time_slot
			FROM time_slot
			WHERE sheet_id = :SheetId" ;
		try
		{
			$aThisDateTimes = $oTimeHandling->CreateDateTimes($this->m_sTimeSlot);
			if($aThisDateTimes[0] >= $aThisDateTimes[1])
				return FALSE;

			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':SheetId', $this->m_iSheetId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetchall();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{				
				foreach ($oSQLRow as $sTimeSlot)
				{
					$aTempDateTimes = $oTimeHandling->CreateDateTimes($sTimeSlot[0]);
					if($aThisDateTimes[0]->format('w') == $aTempDateTimes[0]->format('w'))
					{
						$sResult = $oTimeHandling->TimeOverlap($aThisDateTimes[0], $aThisDateTimes[1], $aTempDateTimes[0], $aTempDateTimes[1]); //dont call it more than once!
						if($sResult)
						{
							//echo $sResult . "<br>";
							return FALSE;
						}
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