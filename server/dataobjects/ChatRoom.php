<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class ChatRoom
{
	private $m_iMesId;
	private $m_iMealId;
	private $m_iUserId;
	private $m_iRelationId;
	private $m_sMessage;
	private $m_tCreateTime;

	function GetMesId()
	{
		return $this->m_iMesId;
	}
	function GetMealId()
	{
		return $this->m_iMealId;
	}
	function GetUserId()
	{
		return $this->m_iUserId;
	}
	function GetRelationId()
	{
		return $this->m_iRelationId;
	}
	function GetMessage()
	{
		return $this->m_sMessage;
	}
	function GetCreateTime()
	{
		return $this->m_tCreateTime;
	}

	function SetMesId($iMesId) 
	{
		$this->m_iMesId = $iMesId; 
	}
	function SetMealId($iMealId) 
	{
		$this->m_iMealId = $iMealId; 
	}
	function SetUserId($iUserId) 
	{
		$this->m_iUserId = $iUserId; 
	}
	function SetRelationId($iRelationId)
	{
		$this->m_iRelationId = $iRelationId;
	}
	function SetMessage($sMessage) 
	{
		$this->m_sMessage = StringHandling::FilterDatabaseString($sMessage, 255);
	}
	function SetCreateTime($tCreateTime) 
	{
		$this->m_tCreateTime = str_replace("'", "''", $tCreateTime);
	}

	function ChatRoom()
	{ 
		$this->SetMessage('');
		$this->SetCreateTime(date('Y/m/d H:i:s'));
	} 

	function Update($iMesId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE chat_room
			SET meal_id = :MealId, user_id = :UserId, relation_id = :RelationId, message = :Message, create_time = :CreateTime 
			WHERE mes_id = :MesId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':RelationId', $this->m_iRelationId, PDO::PARAM_INT);
			$oStatement->bindParam(':Message', $this->m_sMessage, PDO::PARAM_STR, 255);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			$oStatement->bindParam(':MesId', $iMesId, PDO::PARAM_INT);
			
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

	function Load($iMesId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT mes_id, meal_id, user_id, message, create_time, relation_id
			FROM chat_room
			WHERE mes_id = :MesId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MesId', $iMesId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iMesId = $oSQLRow[0];
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
					$this->m_sMessage = $oSQLRow[3];
				}
				if ($oSQLRow[4] != NULL)
				{
					$this->m_tCreateTime = $oSQLRow[4];
				}
				if ($oSQLRow[5] != NULL)
				{
					$this->m_iRelationId = $oSQLRow[5];
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

	function Delete($iMesId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM chat_room WHERE mes_id = :MesId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MesId', $iMesId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO chat_room ( meal_id, user_id, relation_id, message, create_time )
			VALUES ( :MealId, :UserId, :RelationId, :Message, :CreateTime )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':MealId', $this->m_iMealId, PDO::PARAM_INT);
			$oStatement->bindParam(':UserId', $this->m_iUserId, PDO::PARAM_INT);
			$oStatement->bindParam(':RelationId', $this->m_iRelationId, PDO::PARAM_INT);
			$oStatement->bindParam(':Message', $this->m_sMessage, PDO::PARAM_STR, 255);
			$oStatement->bindParam(':CreateTime', $this->m_tCreateTime, PDO::PARAM_STR, 19);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iMesId = $g_oDatabase->lastInsertId();
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