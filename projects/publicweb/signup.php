<?php
include_once('../utility/utility.php');

$oSessionHandling = new SessionHandling();
$oSessionHandling->StartSession();
?>

<html>
<head>
<title>MealPlan - signup</title>
</head>
<body>

<form id='register' action='user_action.php?action=CreateUser' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Register</legend>
<label for='first_name' >Your First Name*: </label>
<input type='text' name='first_name' id='first_name' maxlength="50" />

<label for='last_name' >Your Last Name*: </label>
<input type='text' name='last_name' id='last_name' maxlength="50" />

<label for='user_name' >User Name*:</label>
<input type='text' name='user_name' id='user_name' maxlength="50" />

<label for='password' >Password*:</label>
<input type='password' name='password' id='password' maxlength="50" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='user_action.php?action=Login' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Login</legend>

<label for='user_name' >User Name*:</label>
<input type='text' name='user_name' id='user_name' maxlength="50" />

<label for='password' >Password*:</label>
<input type='password' name='password' id='password' maxlength="50" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='meal_create' action='meal_action.php?action=CreateMeal' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Create Meals</legend>
<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='time_action.php?action=CreateTime' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter New Times</legend>

<label for='start_time' >Start Time:</label>
<input type='text' name='start_time' id='start_time' maxlength="50" />

<label for='end_time' >End Time:</label>
<input type='text' name='end_time' id='end_time' maxlength="50" />

<label for='day' >Day:</label>
<input type='text' name='day' id='day' maxlength="50" />

<label for='sheet_id' >TimeSheet ID:</label>
<input type='text' name='sheet_id' id='sheet_id' maxlength="50" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='time_action.php?action=CreateTimeSheet' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter New TimeSheet Name</legend>

<label for='name' >Name:</label>
<input type='text' name='name' id='name' maxlength="50" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='relation_action.php?action=CreateRelation' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter Friend Username</legend>

<label for='recipient_user_name' >User name:</label>
<input type='text' name='recipient_user_name' id='recipient_user_name' maxlength="64" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='chat_action.php?action=CreateMessage' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter Message</legend>

<label for='message' >Message:</label>
<input type='text' name='message' id='message' maxlength="64" />

<label for='token' >Token:</label>
<input type='text' name='token' id='token' maxlength="64" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='chat_action.php?action=CreateMessage' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter Message</legend>

<label for='message' >Message:</label>
<input type='text' name='message' id='message' maxlength="64" />

<label for='user_name' >UserName:</label>
<input type='text' name='user_name' id='user_name' maxlength="64" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='restaurant_action.php?action=CreateVote' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter Vote info</legend>

<label for='restaurant_id' >Restaurant id:</label>
<input type='text' name='restaurant_id' id='restaurant_id' maxlength="64" />

<label for='restaurant_name' >Restaurant Name:</label>
<input type='text' name='restaurant_name' id='restaurant_name' maxlength="64" />

<label for='state' >State:</label>
<input type='text' name='state' id='state' maxlength="64" />

<label for='token' >Token:</label>
<input type='text' name='token' id='token' maxlength="64" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form id='login' action='busy_time_action.php?action=CreateBusyTime' method='post' 
    accept-charset='UTF-8'>
<fieldset >
<legend>Enter Busy Time Info</legend>

<label for='start_time' >Start Time:</label>
<input type='text' name='start_time' id='start_time' maxlength="64" />

<label for='end_time' >End Time:</label>
<input type='text' name='end_time' id='end_time' maxlength="64" />

<label for='name' >Name:</label>
<input type='text' name='name' id='name' maxlength="64" />

<input type='submit' name='Submit' value='Submit' />
</fieldset>
</form>

<form action="image_action.php?action=CreateImage" enctype="multipart/form-data" method="post">
<table style="border-collapse: collapse; font: 12px Tahoma;" border="1" cellspacing="5" cellpadding="5">
<tbody><tr>
<td>
<input name="uploadedimage" type="file">
</td>
</tr>
<tr>
<td>
<input name="Upload Now" type="submit" value="Upload Image">
</td>
</tr>
</tbody></table>
</form>

<p><a href="meal_action.php?action=ListMeals">Meal List</a> | <a href="time_action.php?action=ListTimes">Time List</a> | <a href="time_action.php?action=ListTimeSheets">Sheets List</a> | 
<a href="relation_action.php?action=ListRelations">Friend List</a> | <a href="restaurant_action.php?action=ListVotes&token=6c98ac15e6a305ba32fce8e3b3c9090abc3a1bc25f6d62e8526e35763ada8e77">Restaurant List</a></p>
<p><a href="image_action.php?action=DeleteImage">Delete Image</a> | <a href="user_action.php?action=ViewProfile">View Profile</a> | <a href="user_action.php?action=Logout">Logout</a></p>


<?php
include_once('../dataobjects/User.php');

if(isset($_SESSION['iUserId']))
{
	echo "User id: ".$_SESSION['iUserId'] . "<br/>";
	$oUser = new User();
	$oUser->Load($_SESSION['iUserId']);	
	echo '<img src="../user_pics/' . $oUser->GetImgPath() . '" alt="" height="100" >';
}
?>


</body>
</html> 