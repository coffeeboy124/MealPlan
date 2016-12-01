<?php
include_once('../dataobjects/User.php');
include_once('../utility/utility.php');

$m_oSessionHandling = new SessionHandling();
$m_oSessionHandling->StartSession();
$m_oJSONPrinter = new JSONPrinter();

if(!isset($_SESSION['iUserId']) || !isset($_GET["action"]))
{
	$m_oJSONPrinter->printJSON("FALSE", "Requirements not met", "NULL");
	return;
}

$m_sAction = $_GET["action"];

if($m_sAction != "" && $m_sAction == "CreateImage")
{
	CreateImage();
}
elseif($m_sAction != "" && $m_sAction == "DeleteImage")
{
	DeleteImage();
}

exit;

function CreateImage(){
	global $m_oJSONPrinter;
	
    $oImageHandling = new ImageHandling();
	$oStringGenerator = new StringGenerator();
	$oUser = new User();
	
	$oUser->Load($_SESSION['iUserId']);
	if($oImageHandling->CheckImage())
	{
		$sUserImgPath = $oUser->GetImgPath();
		$sNewImgPath = $sUserImgPath;
		while($sUserImgPath == $sNewImgPath)
		{
			$sRandTag = $oStringGenerator->GenerateUniqueId(8);
			$sNewImgPath = $_SESSION['iUserId'] . '-' . $sRandTag . '.png';
		}
			
		if($oImageHandling->UploadImage($sNewImgPath))
		{
			if($oUser->GetImgPath() != '')
				unlink($oImageHandling->sUploadDir . '/' . $oUser->GetImgPath());
			
			$oUser->SetImgPath($sNewImgPath);
			$oUser->Update($_SESSION['iUserId']);
			$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
			return;
		}
	}
	$m_oJSONPrinter->printJSON("FALSE", "Upload Failure", "NULL");
	return;
}

function DeleteImage(){
	global $m_oJSONPrinter;
	
	$oUser = new User();
	$oImageHandling = new ImageHandling();
	
	$oUser->Load($_SESSION['iUserId']);
	if($oUser->GetImgPath() != '')
		unlink($oImageHandling->sUploadDir . '/' . $oUser->GetImgPath());
	
	$oUser->SetImgPath('');
	$oUser->Update($_SESSION['iUserId']);
	$m_oJSONPrinter->printJSON("TRUE", "NULL", "NULL");
	return;
}

/*function ViewImage(){
	global $m_oJSONPrinter;
	
	$oUser = new User();
	$oImageHandling = new ImageHandling();
	
	$oUser->Load($_SESSION['iUserId']);
	if(empty($oUser->GetImgPath()))
	{
		$m_oJSONPrinter->printJSON("FALSE", "No uploaded png", "NULL");
		return;
	}
	
	$sAttachment_Location = $oImageHandling->sUploadDir . '/' . $oUser->GetImgPath();
	if (file_exists($sAttachment_Location)) {
		$im = imagecreatefrompng("$sAttachment_Location");

		header('Content-Type: image/png');

		imagepng($im);
		imagedestroy($im);
	}
}*/
?>