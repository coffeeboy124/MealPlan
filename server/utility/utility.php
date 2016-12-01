<?php
//error_reporting(0); //disable notifications for release version.

require_once '../include/PHPMailer-master/PHPMailerAutoload.php';
class ErrorHandling
{
    function OutputError($sErrorMessage)
    {
        try
        {
            if (isset($_SESSION['User']))
            {
                $sUserDetails = "<br>";
                $sUserDetails .= "Email: ".$_SESSION['Employee']->GetEmail()."<br>";
                $sErrorMessage .= $sUserDetails;
            }
            $oEmail = new Email();
            $oEmail->SendEmail($sErrorMessage);

            echo '{"Result":"FALSE","Error":"Server broke","Output":"NULL"}';
            exit();
        }
        catch (ErrorException $e)
        {            
        }
    }
}

class Email
{
	private $m_sEmailUsername = "mealplan99@gmail.com";
	private $m_sEmailPassword = "mealplan97";
	private $m_sEmailSubject = "Mealplan error";
	private $m_sPersonalEmailUsername = "hahafunnymao@gmail.com";
	
    function SendEmail($sErrorMessage)
    {
        try
        {
            $mail = new PHPMailer();
			$mail -> IsSMTP();
			$mail -> SMTPAuth = true;
			$mail -> SMTPSecure = 'ssl';
			$mail -> Host = "smtp.gmail.com";
			$mail -> Port = 465;
			$mail -> IsHTML(true);
			
			$mail -> Username = $this->m_sEmailUsername;
			$mail -> Password = $this->m_sEmailPassword;
			$mail -> SetFrom($this->m_sEmailUsername);
			$mail -> Subject = $this->m_sEmailSubject;
			$mail -> Body = $sErrorMessage;
			
			$mail -> AddAddress($this->m_sPersonalEmailUsername);
			$mail -> Send();
        }
        catch (ErrorException $e)
        {
        }
    }
}

class StringHandling
{	
    static function FilterDatabaseString($sInputString, $iLength)
    {
        $sInputString = trim($sInputString);

        if (strlen($sInputString) > $iLength)
        {
            $sInputString = substr($sInputString, 0, $iLength);
        }
		
		//$sInputString = preg_replace('/[^A-Za-z0-9\-]/', '', $sInputString);

        return $sInputString;

    }
}

class SessionHandling
{
	private $m_sSessionLength = 1800;
	
    function StartSession()
    {
		if(session_status() == PHP_SESSION_NONE)
		{
			session_set_cookie_params(0); //cookie lives till browser is closed
			session_start();
		}
		
		if(!isset($_SESSION['nonce']))
			$_SESSION['nonce'] = md5(microtime(true));

		if(!isset($_SESSION['IPaddress']))
			$_SESSION['IPaddress'] = $_SERVER['REMOTE_ADDR'];

		if(!isset($_SESSION['userAgent']))
			$_SESSION['userAgent'] = $_SERVER['HTTP_USER_AGENT'];
		
		if($_SESSION['IPaddress'] != $_SERVER['REMOTE_ADDR'])
		{
			echo '{"Result":"FALSE","Error":"Session expired","Output":"NULL"}';
			exit;
   		}

        if($_SESSION['userAgent'] != $_SERVER['HTTP_USER_AGENT']){
            echo '{"Result":"FALSE","Error":"Session expired","Output":"NULL"}';
			exit;
		}

		if(isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > $this->m_sSessionLength))
		{
			$this->EndSession();
			echo '{"Result":"FALSE","Error":"Session expired","Output":"NULL"}';
			exit;
		}

		$_SESSION['LAST_ACTIVITY'] = time();
	}
	
	function EndSession()
	{
		if(session_status() == PHP_SESSION_ACTIVE)
		{
			session_unset();
			session_destroy();
		}
	}
}

class TimeHandling
{
	/*I assume that the minimum time for a meal is 1 hour. Therefore, CalculateOverlaps only returns overlaps that are >= 1 hour.*/
	
	function CreateTimeString($sStartTime, $sEndTime, $sDay)
    {
		$oDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
		$sStringFormat = '%s %s %s';
		$sTimeFormat = '%02d:%02d';
		$bPassTest = FALSE;
		
		$sDay = strtoupper($sDay);
		foreach ($oDays as $sCorrectDay)
		{
			if(strcmp($sDay, $sCorrectDay) == 0)
			{
				$bPassTest = TRUE;
				break;
			}
		}
		if(!$bPassTest)
			return FALSE;
		
		list($iHours, $iMinutes) = sscanf($sStartTime, $sTimeFormat);
		if($iHours >= 24 || $iHours < 0)
			return FALSE;
		if($iMinutes >= 60 || $iMinutes < 0)
			return FALSE;
		$sStartTime =  sprintf($sTimeFormat, $iHours, $iMinutes);
		
		list($iHours, $iMinutes) = sscanf($sEndTime, $sTimeFormat);
		if($iHours >= 24 || $iHours < 0)
			return FALSE;
		if($iMinutes >= 60 || $iMinutes < 0)
			return FALSE;
		$sEndTime =  sprintf($sTimeFormat, $iHours, $iMinutes);
		
		$sTime = sprintf($sStringFormat, $sStartTime, $sEndTime, $sDay);
		return $sTime;
	}
	
	function CheckDateString($sDateString)
    {
		$sTimeFormat = '%02d/%02d/%04d %02d:%02d';
		
		list($iMonths, $iDays, $iYears, $iHours, $iMinutes) = sscanf($sDateString, $sTimeFormat);
		
		if($iMonths > 12 || $iMonths < 1)
			return FALSE;
		if($iDays > 31 || $iDays < 1)
			return FALSE;
		if($iYears < 0)
			return FALSE;
		if($iHours >= 24 || $iHours < 0)
			return FALSE;
		if($iMinutes >= 60 || $iMinutes < 0)
			return FALSE;

		return TRUE;
	}
	
	function CreateDateTimes($sTime) /*for time_slot*/
    {
		$sFormat = '%s %s %s';
		list($sStartTime, $sEndTime, $sDay) = sscanf($sTime, $sFormat);
		$dStartTime = DateTime::createFromFormat('H:i D', $sStartTime . ' ' . $sDay);
		$dEndTime = DateTime::createFromFormat('H:i D', $sEndTime . ' ' . $sDay);
		return [$dStartTime, $dEndTime];
	}
	
	function CreateDateTime($sTime) /*for busy_slot*/
    {
		$dStartTime = DateTime::createFromFormat('m/d/Y H:i', $sTime);
		return $dStartTime;
	}
	
	function TimeOverlap($dStartOne,$dEndOne,$dStartTwo,$dEndTwo) //Warning: add permanently changes parameters! Assumes dates are on same day!
	{ 
		if($dStartOne <= $dEndTwo && $dEndOne >= $dStartTwo) //If the dates overlap
		{
			if($dStartOne < $dStartTwo && $dEndOne > $dEndTwo) //complete overlap
			{
				$sNewStart = $dStartTwo->format('H:i');
				$sNewEnd = $dEndTwo->format('H:i');
			}
			else if($dStartOne > $dStartTwo && $dEndOne < $dEndTwo) //complete overlap
			{
				$sNewStart = $dStartOne->format('H:i');
				$sNewEnd = $dEndOne->format('H:i');
			}
			else if($dStartOne < $dStartTwo) //incomplete overlap
			{
				$sNewStart = $dStartTwo->format('H:i');
				$sNewEnd = $dStartTwo->add($dStartTwo->diff($dEndOne, TRUE))->format('H:i');
			}
			elseif($dStartOne == $dStartTwo) //incomplete overlap
			{
				$sNewStart = $dStartTwo->format('H:i');
				$sNewEnd = $dStartTwo->add($dStartTwo->diff(min($dEndOne, $dEndTwo), TRUE))->format('H:i');
			}
			else //incomplete overlap
			{
				$sNewStart = $dStartOne->format('H:i');
				$sNewEnd = $dStartOne->add($dStartOne->diff($dEndTwo, TRUE))->format('H:i');
			}
			
			/* DEBUG CODE
			echo 'Start 1: ' . $dStartOne->format('H:i D') . '<br>';
			echo 'End 1: ' . $dEndOne->format('H:i D') . '<br>';
			echo 'Start 2: ' . $dStartTwo->format('H:i D') . '<br>';
			echo 'End 2: ' . $dEndTwo->format('H:i D') . '<br>';*/
			$sDay = $dStartTwo->format('D');
			return $this->CreateTimeString($sNewStart, $sNewEnd, $sDay);
		}
		
		return FALSE;
	}
	
	function CalculateOverlaps($oTimes, $oUsers, &$oResults)
	{
		if(count($oTimes) != count($oUsers))
			exit("error!");
		
		/*Find all overlaps*/
		for ($i = 0; $i < count($oTimes); $i++)
		{
			$oNewTimes = array();
			$oNewUsers = array();
			for ($j = $i + 1; $j < count($oTimes); $j++)
			{
				$oDateTimesI = $this->CreateDateTimes($oTimes[$i]);
				$oDateTimesJ = $this->CreateDateTimes($oTimes[$j]);
				
				if($oDateTimesI[0]->format('w') == $oDateTimesJ[0]->format('w'))
				{
					$sResult = $this->TimeOverlap($oDateTimesI[0], $oDateTimesI[1], $oDateTimesJ[0], $oDateTimesJ[1]); //dont call it more than once!
					if($sResult)
					{
						$aResultDateTimes = $this->CreateDateTimes($sResult);
						$dOverlap = date_diff($aResultDateTimes[0], $aResultDateTimes[1], TRUE);
						if($dOverlap->h >= 1 || $dOverlap->i >= 30) //if timeslot bigger than 30 min...
						{
							$oTempUsers = array();
							foreach ($oUsers[$i] as $iUserId)
							{
								if(!in_array($iUserId, $oTempUsers, true))
									array_push($oTempUsers, $iUserId);
							}
							foreach ($oUsers[$j] as $iUserId)
							{
								if(!in_array($iUserId, $oTempUsers, true))
									array_push($oTempUsers, $iUserId);
							}
							array_push($oNewUsers, $oTempUsers);
							
							array_push($oNewTimes, $sResult);
						}
					}
				}
			}
			if ($oNewTimes)
				$this->CalculateOverlaps($oNewTimes, $oNewUsers, $oResults);
		}
		
		/*Data formatting for pretty print*/
		for ($i = 0; $i < count($oTimes); $i++)
		{
			$iIndex = array_search($oTimes[$i], $oResults);
			if($iIndex == FALSE)
			{
				array_push($oResults, $oTimes[$i]);
				array_push($oResults, $oUsers[$i]);
			}
			else
			{
				if($iIndex < count($oTimes)-1 && count($oResults[$iIndex + 1]) < count($oUsers[$i]))
				{
					echo 'omg';
					$oResults[$iIndex] = $oTimes[$i];
					$oResults[$iIndex+1] = $oUsers[$i];
				}
			}
			/*echo $oTimes[$i] . '  |  User(s): ';
			foreach ($oUsers[$i] as $iUserId)
				echo $iUserId . ' ';
			echo "Count: " . count($oUsers[$i]);
			echo '<br/>';*/
		}
		//echo '---------------<br/>';
		
		return;
	}
}

class ImageHandling
{
	public $m_sUploadDir = 'user_pics';
	/*5MB maximum upload size set in PHP INI*/
	
	function UploadImage($sImgName)
	{
		if ($_FILES["uploadedimage"]["error"] == UPLOAD_ERR_OK) 
		{
			if(move_uploaded_file($_FILES["uploadedimage"]["tmp_name"], $this->m_sUploadDir . "/". $sImgName))
				return TRUE;
		}
		return FALSE;
	}
	
	function CheckImage()
	{
		if(empty($_FILES['uploadedimage']))
		{
			//echo "file name mismatch";
			return FALSE;
		}
		if(!is_uploaded_file($_FILES['uploadedimage']['tmp_name'])) //no upload
		{
			//echo "no upload";
			return FALSE;
		}

		$oImgInfo = getimagesize($_FILES["uploadedimage"]["tmp_name"]);
		
		if(!$oImgInfo) //not an image
		{
			//echo "not an image";
			return FALSE;
		}
		if($oImgInfo[2] !== IMAGETYPE_PNG) //not a PNG
		{
			//echo "not a png";
			return FALSE;
		}
		return TRUE;
	}
}

class StringGenerator
{
	/*NOT MY CODE. TAKEN FROM ONLINE.*/
	function GenerateUniqueId($maxLength = null)
	{
		$entropy = '';

		if (function_exists('openssl_random_pseudo_bytes')) {
			$entropy = openssl_random_pseudo_bytes(64, $strong);
			if($strong !== true) {
				$entropy = '';
			}
		}

		$entropy .= uniqid(mt_rand(), true);

		if (class_exists('COM')) {
			try {
				$com = new COM('CAPICOM.Utilities.1');
				$entropy .= base64_decode($com->GetRandom(64, 0));
			} catch (Exception $ex) {
			}
		}

		if (is_readable('/dev/urandom')) {
			$h = fopen('/dev/urandom', 'rb');
			$entropy .= fread($h, 64);
			fclose($h);
		}

		$hash = hash('whirlpool', $entropy);
		if ($maxLength) {
			return substr($hash, 0, $maxLength);
		}
		return $hash;
	}
}

class JSONPrinter
{
	function printJSON($sResult, $sError, $oOutput)
	{
		if(is_array($oOutput))
			$oOutput = json_encode($oOutput);
		$oJsonList = array(
					"Result" => $sResult,
					"Error" => $sError,
					"Output" => $oOutput
				);
		echo json_encode($oJsonList);
	}
}

class LocationHandling
{
	/*NOT MY CODE*/
	
	/**
	* Calculates the great-circle distance between two points, with
	* the Vincenty formula.
	* @param float $latitudeFrom Latitude of start point in [deg decimal]
	* @param float $longitudeFrom Longitude of start point in [deg decimal]
	* @param float $latitudeTo Latitude of target point in [deg decimal]
	* @param float $longitudeTo Longitude of target point in [deg decimal]
	* @param float $earthRadius Mean earth radius in [m]
	* @return float Distance between points in [m] (same as earthRadius)
	*/
	function vincentyGreatCircleDistance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo, $earthRadius = 6371000)
	{
		// convert from degrees to radians
		$latFrom = deg2rad($latitudeFrom);
		$lonFrom = deg2rad($longitudeFrom);
		$latTo = deg2rad($latitudeTo);
		$lonTo = deg2rad($longitudeTo);

		$lonDelta = $lonTo - $lonFrom;
		$a = pow(cos($latTo) * sin($lonDelta), 2) +
		pow(cos($latFrom) * sin($latTo) - sin($latFrom) * cos($latTo) * cos($lonDelta), 2);
		$b = sin($latFrom) * sin($latTo) + cos($latFrom) * cos($latTo) * cos($lonDelta);

		$angle = atan2(sqrt($a), $b);
		return $angle * $earthRadius;
	}
}

?>