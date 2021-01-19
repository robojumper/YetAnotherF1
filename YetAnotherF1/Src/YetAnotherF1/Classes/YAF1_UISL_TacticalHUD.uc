// we intentionally override the other commands, we don't want anything to interfere (hotkey targeting, UITacticalCharInfo)
class YAF1_UISL_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local YAF1_WotCCallbackHandler CallbackOwner;

	if (UITacticalHUD(Screen) != none)
	{
		`log("YAF1: Attempting to register F1 callback.");
		if (Function'XComGame.UIScreenStack.SubscribeToOnInputForScreen' != none)
		{
			CallbackOwner = new class'YAF1_WotCCallbackHandler';
			Screen.Movie.Stack.SubscribeToOnInputForScreen(Screen, CallbackOwner.CHOnInputFOrScreen);
		}
		else
		{
			`log("YAF1: Error. Failed to register F1 callback.");
		}
	}
}
