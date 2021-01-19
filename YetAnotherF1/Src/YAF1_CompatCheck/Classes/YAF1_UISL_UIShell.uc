// we intentionally override the other commands, we don't want anything to interfere (hotkey targeting, UITacticalCharInfo)
class YAF1_UISL_UIShell extends UIScreenListener;

var bool ShowedPopupThisSession;

event OnInit(UIScreen Screen)
{
	// if UIShell(Screen).DebugMenuContainer is set do NOT show since were not on the final shell
	if (UIShell(Screen) != none && !ShowedPopupThisSession)
	{
		ShowedPopupThisSession = true;
		Screen.SetTimer(2.8f, false, nameof(CheckYAF1Dupe), self);
	}
}

simulated function CheckYAF1Dupe()
{
	local TDialogueBoxData kDialogData;
	local bool OldF1Installed, CHLMissing;
	local string Text;

	OldF1Installed = IsDLCInstalled('YetAnotherF1');
	CHLMissing = Function'XComGame.UIScreenStack.SubscribeToOnInputForScreen' == none;

	Text = "";
	if (OldF1Installed)
	{
		Text $= "The War of the Chosen specific version of Yet Another F1 is incompatible with the original version."
				@ "Please disable the original version (Yet Another F1 / YetAnotherF1) and keep the WotC version (WotC: Yet Another F1 / YetAnotherF1_WotC).";
	}

	if (CHLMissing)
	{
		if (OldF1Installed)
		{
			Text @= "Further, the ";
		}
		else
		{
			Text $= "The ";
		}
		Text $= "WotC Community Highlander is not correctly installed and enabled. The X2WOTCCommunityHighlander is a hard requirement for the new F1.";
	}

	if (Text != "")
	{
		kDialogData.strTitle = "Yet Another F1: Compatibility/Requirements Warning";
		kDialogData.eType = eDialog_Warning;
		
		kDialogData.strText = Text;
		kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericAccept;

		`log(kDialogData.strText);

		`PRESBASE.UIRaiseDialog(kDialogData);
	}
}


private static function bool IsDLCInstalled(name DLCName)
{
	local XComOnlineEventMgr EventManager;
	local int i;
		
	EventManager = `ONLINEEVENTMGR;
	for(i = 0; i < EventManager.GetNumDLC(); ++i)
	{
		if (DLCName == EventManager.GetDLCNames(i))
		{
			return true;
		}
	}
	return false;
}