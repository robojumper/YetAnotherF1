//---------------------------------------------------------------------------------------
//  FILE:   X2DownloadableContentInfo_YetAnotherF1.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_YetAnotherF1 extends X2DownloadableContentInfo;

// weak ref to the screen
// config is just so we can write to it via default.
var config string ScreenPath;

var localized array<string> Instructions;

static event OnPostTemplatesCreated()
{
	local YAF1_Config CDO;

	CDO = YAF1_Config(class'XComEngine'.static.GetClassDefaultObject(class'YAF1_Config'));

	if (CDO.F1Keys.Length == 0)
	{
		CDO.F1Keys.AddItem(class'UIUtilities_Input'.const.FXS_BUTTON_L3);
		CDO.F1Keys.AddItem(class'UIUtilities_Input'.const.FXS_KEY_F1);
	}

	CDO.Instructions = default.Instructions;

	class'YAF1_Config'.static.StaticSaveConfig();

}

static exec function bool YAF1_PushF1Screen()
{
	local XComTacticalInput TI;
	local XComGameStateVisualizationMgr VisMgr;
	local UIScreen TempScreen;
	local XComPresentationLayer Pres;
	local UIScreenStack ScreenStack;
	local StateObjectReference Target;
	local XComGameState_BaseObject TargetState;


	Pres = `PRES;

	// this screen can be used if either a targeting method is in use (already requires no blocking vis blocks)
	// or a unit is selected, it's our turn and nothing blocks ability activation

	TI = XComTacticalInput(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerInput);
	VisMgr = `XCOMVISUALIZATIONMGR;
	ScreenStack = Pres.ScreenStack;
	TempScreen = ScreenStack.GetFirstInstanceOf(class'YAF1_UIUnitInfo');
	if (TempScreen != none && ScreenStack.GetCurrentScreen() == TempScreen)
	{
		TempScreen.CloseScreen();
		return true;
	}
	
	// don't show when paused or showing popups
	if (Pres.UIIsBusy())
	{
		return false;
	}

	// if we are neither targeting nor able to control our current unit, abort
	if (Pres != none && Pres.m_kTacticalHUD.m_kAbilityHUD.TargetingMethod != none)
	{
		Target.ObjectID = Pres.m_kTacticalHUD.m_kAbilityHUD.TargetingMethod.GetTargetedObjectID();
		TargetState = `XCOMHISTORY.GetGameStateForObjectID(Target.ObjectID);
		if (XComGameState_Unit(TargetState) == none)
		{
			`SOUNDMGR.PlaySoundEvent("Play_MenuClickNegative");
			return false;
		}
	}
	else if (TI.IsInState('ActiveUnit_Moving') && TI.GetActiveUnit() != none && !VisMgr.IsActorBeingVisualized(TI.GetActiveUnit()) && !VisMgr.VisualizerBlockingAbilityActivation())
	{
		Target.ObjectID = TI.GetActiveUnit().ObjectID;
	}
	else
	{
		return false;
	}

	TempScreen = GetScreen();
	ScreenStack.Push(TempScreen, Pres.Get2DMovie());
	YAF1_UIUnitInfo(TempScreen).PopulateData(Target);

	return true;
}

static function YAF1_UIUnitInfo GetScreen()
{
	local YAF1_UIUnitInfo TempScreen;
	local XComPresentationLayerBase Pres;

	Pres = `PRESBASE;
	TempScreen = YAF1_UIUnitInfo(FindObject(default.ScreenPath, class'YAF1_UIUnitInfo'));
	if (Pres != none && TempScreen == none)
	{
		TempScreen = Pres.Spawn(class'YAF1_UIUnitInfo', Pres);
		TempScreen.InitScreen(XComPlayerController(Pres.Owner), Pres.Get2DMovie());
		TempScreen.Movie.LoadScreen(TempScreen);
		default.ScreenPath = PathName(TempScreen);
	}
	return TempScreen;
}


exec function YAF1_SetControllerEnabled(bool bActive)
{
	`XPROFILESETTINGS.Data.ActivateMouse(!bActive);
}

exec function YAF1_PrintScreenPanelInfo()
{
	local UIPanel ParentPanel;
	local int iTotalPanels;
	iTotalPanels = 0;
	ParentPanel = GetScreen();
	CountPanels(ParentPanel, iTotalPanels);
	`log(iTotalPanels);
	
}

function CountPanels(UIPanel Panel, out int count)
{
	local int i;
	count += 1; // self
	for (i = 0; i < Panel.ChildPanels.Length; i++)
	{
		if (Panel.ChildPanels[i] != Panel)
			CountPanels(Panel.ChildPanels[i], count);
	}
}
