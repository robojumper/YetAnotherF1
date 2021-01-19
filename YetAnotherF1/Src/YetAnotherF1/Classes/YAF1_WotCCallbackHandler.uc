class YAF1_WotCCallbackHandler extends Object config(UI);

var config bool bDontEatL3;

function bool CHOnInputFOrScreen(UIScreen Screen, int iInput, int ActionMask)
{
	if (ActionMask == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE && class'YAF1_Config'.default.F1Keys.Find(iInput) != INDEX_NONE)
	{
		class'X2DownloadableContentInfo_YetAnotherF1'.static.YAF1_PushF1Screen();
		return true;
	}

	if (iInput == class'UIUtilities_Input'.const.FXS_BUTTON_L3)
	{
		// Eat all the events -- otherwise they'll fire the tactical info screen
		return true;
	}
	return false;
}
