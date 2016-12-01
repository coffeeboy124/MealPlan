<?php
include_once('../utility/global.php');
include_once('../utility/utility.php');

class UserRelation
{
	private $m_iRelationId;
	private $m_iUser1Id;
	private $m_iUser2Id;
	private $m_sState;

	function GetRelationId()
	{
		return $this->m_iRelationId;
	}
	function GetUser1Id()
	{
		return $this->m_iUser1Id;
	}
	function GetUser2Id()
	{
		return $this->m_iUser2Id;
	}
	function GetState()
	{
		return $this->m_sState;
	}

	function SetRelationId($iRelationId) 
	{
		$this->m_iRelationId = $iRelationId; 
	}
	function SetUser1Id($iUser1Id) 
	{
		$this->m_iUser1Id = $iUser1Id; 
	}
	function SetUser2Id($iUser2Id) 
	{
		$this->m_iUser2Id = $iUser2Id; 
	}
	function SetState($sState) 
	{
		$this->m_sState = StringHandling::FilterDatabaseString($sState, 16);
	}

	function UserRelation()
	{ 
		$this->SetState('');
	} 

	function Update($iRelationId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "UPDATE user_relation
			SET user1_id = :User1Id, user2_id = :User2Id, state = :State 
			WHERE relation_id = :RelationId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':User1Id', $this->m_iUser1Id, PDO::PARAM_INT);
			$oStatement->bindParam(':User2Id', $this->m_iUser2Id, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			$oStatement->bindParam(':RelationId', $iRelationId, PDO::PARAM_INT);
			
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

	function Load($iRelationId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT relation_id, user1_id, user2_id, state
			FROM user_relation
			WHERE relation_id = :RelationId" ;
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':RelationId', $iRelationId, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				if ($oSQLRow[0] != NULL)
				{
					$this->m_iRelationId = $oSQLRow[0];
				}
				if ($oSQLRow[1] != NULL)
				{
					$this->m_iUser1Id = $oSQLRow[1];
				}
				if ($oSQLRow[2] != NULL)
				{
					$this->m_iUser2Id = $oSQLRow[2];
				}
				if ($oSQLRow[3] != NULL)
				{
					$this->m_sState = $oSQLRow[3];
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

	function Delete($iRelationId)
	{
		global $g_oDatabase;
		
		$sSqlStatement = "DELETE FROM user_relation WHERE relation_id = :RelationId";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':RelationId', $iRelationId, PDO::PARAM_INT);
			
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
		
		$sSqlStatement = "INSERT INTO user_relation ( user1_id, user2_id, state )
			VALUES ( :User1Id, :User2Id, :State )";
		
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':User1Id', $this->m_iUser1Id, PDO::PARAM_INT);
			$oStatement->bindParam(':User2Id', $this->m_iUser2Id, PDO::PARAM_INT);
			$oStatement->bindParam(':State', $this->m_sState, PDO::PARAM_STR, 16);
			
			$oStatement->execute();
			$oStatement->closeCursor();
			$this->m_iRelationId = $g_oDatabase->lastInsertId();
		}
		catch (PDOException $oPDOException)
		{
			$oErrorHandling = new ErrorHandling();
			$oErrorHandling->OutputError('System Error = ' . $oPDOException->getMessage() . '<br>In File: ' . $oPDOException->getFile() . '<br>At Line: ' . $oPDOException->getLine() . '<br>Stack: ' . $oPDOException->getTraceAsString());
			exit;
		}
	}
	
	function CheckRelation()
	{
		global $g_oDatabase;
		
		$sSqlStatement = "SELECT relation_id, state
			FROM user_relation
			WHERE (user1_id = :User1Id AND user2_id = :User2Id)
			OR (user1_id = :User2Id AND user2_id = :User1Id)";
			
		try
		{
			$oStatement = $g_oDatabase->prepare($sSqlStatement);
			$oStatement->bindParam(':User1Id', $this->m_iUser1Id, PDO::PARAM_INT);
			$oStatement->bindParam(':User2Id', $this->m_iUser2Id, PDO::PARAM_INT);
			
			$oStatement->execute();
			$oSQLRow = $oStatement->fetch();
			$oStatement->closeCursor();
			
			if($oSQLRow)
			{
				$this->SetRelationId($oSQLRow[0]);
				$this->SetState($oSQLRow[1]);
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