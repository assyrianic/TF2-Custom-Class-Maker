#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <ccm>

#pragma semicolon 1
#pragma newdecls required

#include "ccm/defs_globals.inc"
#include "ccm/events.sp"
#include "ccm/subplugin_configuration_file.sp"

public Plugin myinfo = {
	name 			= "Custom Class Maker",
	author 			= "Nergal/Assyrian, props to RSWallen, Friagram, Chdata, Powerlord, and everyone else on AM",
	description 		= "Make your Own Classes!",
	version 		= PLUGIN_VERSION,
	url 			= "hue" //will fill later
};

public void OnPluginStart()
{
	hArrayClass = new ArrayList();
	hTrieClass = new StringMap();

	RegConsoleCmd("sm_ccm", MakeClassMenu);
	RegConsoleCmd("sm_noccm", MakeNotClass); //need more creative commands
	RegConsoleCmd("sm_offccm", MakeNotClass);
	RegConsoleCmd("sm_offclass", MakeNotClass);
	RegAdminCmd("sm_reloadccm", CmdReloadCFG, ADMFLAG_GENERIC);

	bEnabled = CreateConVar("sm_ccm_enabled", "1", "Enable Custom Class Maker plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	AllowBlu = CreateConVar("sm_ccm_blu", "0", "(Dis)Allow Custom Classes to be playable for BLU team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AllowRed = CreateConVar("sm_ccm_red", "1", "(Dis)Allow Custom Classes to be playable for RED team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AdminFlagByPass = CreateConVar("sm_ccm_flagbypass", "a", "what flag admins need to bypass the custom class limit", FCVAR_PLUGIN);

	p_OnClassResupply = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassSpawn = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassMenuSelected = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassDeSelected = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnInitClass = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassEquip = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassAirblasted = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassDoAirblast = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillBuilding = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKill = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillDomination = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillRevenge = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilled = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledDomination = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledRevenge = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassUbered = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassDeployUber = new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );

	p_OnConfiguration_Load_Sounds = new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Materials = new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Models = new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Misc =  new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String) );

	//AutoExecConfig(true, "CustomClassMaker");
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("player_changeclass", ChangeClass);
	HookEvent("player_chargedeployed", ChargeDeployed);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("teamplay_round_start", RoundStart);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		OnClientPutInServer(i);
	}
}
public void OnClientPutInServer(int client)
{
	CustomClass player = CustomClass(client);
	player.reset();
}
public void OnClientDisconnect(int client)
{
	CustomClass player = CustomClass(client);
	if (player.bIsCustom) CCM_OnClassDeSelected(player.userid);
	player.reset();
}

public Action MakeClassMenu(int client, int args)
{
	if ( bEnabled.BoolValue && IsClientInGame(client))
	{
		Menu classpick = new Menu(MenuHandler_PickClass);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		classpick.SetTitle("[Custom Class Maker] Choose A Custom Class!");
		int count = hArrayClass.Length; //GetArraySize(hArrayClass);

		if (count <= 0) {
			ReplyToCommand(client, "[CCM] No Class Modules Loaded!");
			return Plugin_Continue;
		}

		char longnameholder[32];
		for (int i = 0; i < count; i++)
		{
			GetTrieString(hArrayClass.Get(i), "LongName", longnameholder, sizeof(longnameholder));
			classpick.AddItem("pickclass", longnameholder);
		}
		classpick.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_PickClass(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32]; menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
	{
		CustomClass player = CustomClass(client);
		if (player.bSetCustom && player.iIndex == selection)
		{
			ReplyToCommand(client, "[CCM] You've already chosen that class!");
		}
		else
		{
			StringMap mappy = hArrayClass.Get(selection);
			player.hIndex = GetClassSubPlugin( mappy );
			char classnameholder[32];
			mappy.GetString("LongName", classnameholder, sizeof(classnameholder));
			ReplyToCommand(client, "[CCM] You selected %s as your class!", classnameholder);
			player.iIndex = selection;

			//CCM_OnClassMenuSelected
			player.bSetCustom = true;
			CCM_OnClassMenuSelected(player.userid); 
		}
	}
	else if (action == MenuAction_End) delete menu;
}

public Action MakeNotClass(int client, int args)
{
	if ( bEnabled.BoolValue )
	{
		CustomClass player = CustomClass(client);
		if ( !player.bIsCustom )
		{
			ReplyToCommand(player.index, "[CCM] You're already not a custom class!");
			return Plugin_Handled;
		}
		player.bSetCustom = false;
		char classnameholder[32];
		StringMap holder = hArrayClass.Get(player.iIndex);
		holder.GetString("LongName", classnameholder, sizeof(classnameholder));
		ReplyToCommand(client, "[CCM] You will no longer be the %s class next time you respawn", classnameholder);

		//CCM_OnClassDeselected
		CCM_OnClassDeSelected(player.userid);
	}
	return Plugin_Handled;
}
/*public void ClassInitialize(int userid, int ClassID)
{
	if (!GetConVarBool(bEnabled)) return;
	int client = GetClientOfUserId(userid);
	if ( client <= 0 ) return;
	int iTeam = GetClientTeam(client);
	if ( (!GetConVarBool(AllowBlu) && (iTeam == 3)) || (!GetConVarBool(AllowRed) && (iTeam == 2)) )
	{
		switch (iTeam)
		{
			case 2: ReplyToCommand(client, "RED players are not allowed to play this Class");
			case 3: ReplyToCommand(client, "BLU players are not allowed to play this Class");
		}
		return;
	}
	int ClassLimit, iCount = 0;
	switch (iTeam)
	{
		case 0, 1: ClassLimit = -2;
		case 2: ClassLimit = GetConVarInt(RedLimit);
		case 3: ClassLimit = GetConVarInt(BluLimit);
	}
	if (ClassLimit == -1)
	{
		bSetCustomClass[client] = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		return;
	}
	else if (ClassLimit == 0)
	{
		if (IsImmune(client))
		{
			bSetCustomClass[client] = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** That Custom Class is Blocked for your Team ****");
		return;
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			if ( (GetClientTeam(i) < 2) && bSetCustomClass[i] ) //remove players who played as custom then went spec
				bSetCustomClass[i] = false;
			if ( ( (!GetConVarBool(AllowBlu) && GetClientTeam(i) == 3) || (!GetConVarBool(AllowRed) && GetClientTeam(i) == 2) ) && bSetCustomClass[i] ) //remove players who were forced to switch teams while dead
				bSetCustomClass[i] = false;
			if (GetClientTeam(i) == iTeam && bSetCustomClass[i] && i != client) //get amount of customs on team
				iCount++;
		}
	}
	if (iCount < ClassLimit)
	{
		bSetCustomClass[client] = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
	}
	else if (iCount >= ClassLimit)
	{
		if ( IsImmune(client) )
		{
			bSetCustomClass[client] = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** Custom Class Limit is Reached ****");
	}
	return;
} MAKE YOUR OWN DAMN CLASS LIMITS*/
public bool IsImmune(int iClient)
{
	if (!IsValidClient(iClient, false)) return false;
	char sFlags[32];
	GetConVarString(AdminFlagByPass, sFlags, sizeof(sFlags));
	// If flags are specified and client has generic or root flag, client is immune
	return ( !StrEqual(sFlags, "") && GetUserFlagBits(iClient) & (ReadFlagString(sFlags)|ADMFLAG_ROOT) );
}
public Action CmdReloadCFG(int client, int iAction)
{
	ServerCommand("sm_rcon exec sourcemod/CustomClassMaker.cfg");
	ReplyToCommand(client, "**** Reloading CustomClassMaker Config ****");
	return Plugin_Handled;
}

stock Handle FindClassName(const char[] name)
{
	Handle GotClassName;
	if (GetTrieValueCaseInsensitive(hTrieClass, name, GotClassName)) return GotClassName;
	return null;
}
public int RegisterClass(Handle pluginhndl, const char shortname[16], const char longname[32])
{
	if (!ValidateName(shortname))
	{
		LogError("**** RegisterClass - Invalid Name For Class ****");
		return -1;
	}
	else if (FindClassName(shortname) != null)
	{
		LogError("**** RegisterClass - Class Already Exists ****");
		return -1;
	}
	// Create the trie to hold the data about the class
	StringMap ClassMap = new StringMap();
	ClassMap.SetValue("Subplugin", pluginhndl);
	ClassMap.SetString("ShortName", shortname);
	ClassMap.SetString("LongName", longname);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	hArrayClass.Push(ClassMap); //PushArrayCell(hArrayClass, ClassSubplug);
	SetTrieValueCaseInsensitive(hTrieClass, shortname, ClassMap);

	return hArrayClass.Length-1;
}

// Real Private Forwards

stock PrivForws GetCCMHookType(CCMHookType hook)
{
	switch ( hook )
	{
		case CCMHook_OnClassResupply:			return p_OnClassResupply;
		case CCMHook_OnClassSpawn:			return p_OnClassSpawn;
		case CCMHook_OnClassMenuSelected:		return p_OnClassMenuSelected;
		case CCMHook_OnClassDeSelected:			return p_OnClassDeSelected;
		case CCMHook_OnInitClass:			return p_OnInitClass;
		case CCMHook_OnClassEquip:			return p_OnClassEquip;
		case CCMHook_OnClassAirblasted:			return p_OnClassAirblasted;
		case CCMHook_OnClassDoAirblast:			return p_OnClassDoAirblast;
		case CCMHook_OnClassKillBuilding:		return p_OnClassKillBuilding;
		case CCMHook_OnClassKill:			return p_OnClassKill;
		case CCMHook_OnClassKillDomination:		return p_OnClassKillDomination;
		case CCMHook_OnClassKillRevenge:		return p_OnClassKillRevenge;
		case CCMHook_OnClassKilled:			return p_OnClassKilled;
		case CCMHook_OnClassKilledDomination:		return p_OnClassKilledDomination;
		case CCMHook_OnClassKilledRevenge:		return p_OnClassKilledRevenge;
		case CCMHook_OnClassUbered:			return p_OnClassUbered;
		case CCMHook_OnClassDeployUber:			return p_OnClassDeployUber;
		case CCMHook_OnConfiguration_Load_Sounds:	return p_OnConfiguration_Load_Sounds;
		case CCMHook_OnConfiguration_Load_Materials:	return p_OnConfiguration_Load_Materials;
		case CCMHook_OnConfiguration_Load_Models:	return p_OnConfiguration_Load_Models;
		case CCMHook_OnConfiguration_Load_Misc:		return p_OnConfiguration_Load_Misc;
	}
	return null;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// N A T I V E S ============================================================================================================
	CreateNative("CCM_RegisterClass", Native_RegisterClassSubplugin);
	CreateNative("CCM_LoadConfig", Native_LoadConfigurationSubplugin);
	CreateNative("CCM_Hook", Native_Hook);
	CreateNative("CCM_HookEx", Native_HookEx);
	CreateNative("CCM_Unhook", Native_Unhook);
	CreateNative("CCM_UnhookEx", Native_UnhookEx);

	CreateNative("CCM_IsCustomClass", Native_IsCustomClass);
	CreateNative("CCM_SetIsCustomClass", Native_SetIsCustomClass);
	CreateNative("CCM_IsSetCustomClass", Native_IsSetCustomClass);
	CreateNative("CCM_SetIsSetCustomClass", Native_SetIsSetCustomClass);
	CreateNative("CCM_GetPlayerModuleIndex", Native_GetPlayerModuleIndex);
	CreateNative("CCM_SetPlayerModuleIndex", Native_SetPlayerModuleIndex);
	//===========================================================================================================================

	RegPluginLibrary("ccm");
	MarkNativeAsOptional("CCM_RegisterClass");
	MarkNativeAsOptional("CCM_LoadConfig");
	MarkNativeAsOptional("CCM_Hook");
	MarkNativeAsOptional("CCM_HookEx");
	MarkNativeAsOptional("CCM_Unhook");
	MarkNativeAsOptional("CCM_UnhookEx");

	MarkNativeAsOptional("CCM_IsCustomClass");
	MarkNativeAsOptional("CCM_SetIsCustomClass");
	MarkNativeAsOptional("CCM_IsSetCustomClass");
	MarkNativeAsOptional("CCM_SetIsSetCustomClass");
	MarkNativeAsOptional("CCM_GetPlayerModuleIndex");
	MarkNativeAsOptional("CCM_SetPlayerModuleIndex");

	return APLRes_Success;
}

public int Native_RegisterClassSubplugin(Handle plugin, int numParams)
{
	char ShortModuleName[16]; GetNativeString(1, ShortModuleName, sizeof(ShortModuleName));
	char ModuleName[32]; GetNativeString(2, ModuleName, sizeof(ModuleName));

	int ClassIndex = RegisterClass(plugin, ShortModuleName, ModuleName); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return ClassIndex;
}
public int Native_LoadConfigurationSubplugin(Handle plugin, int numParams)
{
	char cFileName[128]; GetNativeString(1, cFileName, sizeof(cFileName));
	return CCM_Load_Configuration(plugin, cFileName);
}
public int Native_Hook(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);

	PrivForws FwdHandle = GetCCMHookType(CCMHook);
	Function Func = GetNativeFunction(2);

	if (FwdHandle != null)
	{
		FwdHandle.Add(plugin, Func);
	}
}

public int Native_HookEx(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);

	PrivForws FwdHandle = GetCCMHookType(CCMHook);
	Function Func = GetNativeFunction(2);

	if (FwdHandle != null)
	{
		return FwdHandle.Add(plugin, Func);
	}
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);

	PrivForws FwdHandle = GetCCMHookType(CCMHook);

	if (FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		//RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
		FwdHandle.Remove(plugin, GetNativeFunction(2));
	}
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);

	PrivForws FwdHandle = GetCCMHookType(CCMHook);

	if(FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		return FwdHandle.Remove(plugin, GetNativeFunction(2));
	}
	return 0;
}

// Internal private forward calls

public void CCM_OnClassResupply(int userid) // 2
{
	//Call_StartForward(p_OnClassResupply);
	p_OnClassResupply.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}

public void CCM_OnClassSpawn(int userid) // 2
{
	p_OnClassSpawn.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassMenuSelected(int userid) // 2
{
	p_OnClassMenuSelected.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassDeSelected(int userid) // 2
{
	p_OnClassDeSelected.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnInitClass(int userid) // 2
{
	p_OnInitClass.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassEquip(int userid) // 2
{
	p_OnClassEquip.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassAirblasted(int userid, int attackerid) // 3
{
	p_OnClassAirblasted.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassDoAirblast(int userid, int attackerid) // 3
{
	p_OnClassDoAirblast.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(attackerid)]);
	Call_PushCell(userid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillBuilding(int userid, int entref) // 3
{
	p_OnClassKillBuilding.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(userid)]);
	Call_PushCell(userid);
	Call_PushCell(entref);
	Call_Finish();
}
public void CCM_OnClassKill(int victimid, int attackerid) // 3
{
	p_OnClassKill.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(attackerid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillDomination(int victimid, int attackerid) // 3
{
	p_OnClassKillDomination.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(attackerid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillRevenge(int victimid, int attackerid) // 3
{
	p_OnClassKillRevenge.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(attackerid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilled(int victimid, int attackerid) // 3
{
	p_OnClassKilled.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(victimid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilledDomination(int victimid, int attackerid) // 3
{
	p_OnClassKilledDomination.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(victimid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilledRevenge(int victimid, int attackerid) // 3
{
	p_OnClassKilledRevenge.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(victimid)]);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassUbered(int patientid, int medicid) // 3
{
	p_OnClassUbered.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(patientid)]);
	Call_PushCell(patientid);
	Call_PushCell(medicid);
	Call_Finish();
}
public void CCM_OnClassDeployUber(int patientid, int medicid) // 3
{
	p_OnClassDeployUber.Start();
	Call_PushCell(iClassIndex[GetClientOfUserId(medicid)]);
	Call_PushCell(patientid);
	Call_PushCell(medicid);
	Call_Finish();
}
public void CCM_OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	p_OnConfiguration_Load_Sounds.Start();
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void CCM_OnConfiguration_Load_Materials(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	p_OnConfiguration_Load_Materials.Start();
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void CCM_OnConfiguration_Load_Models(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	p_OnConfiguration_Load_Models.Start();
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void CCM_OnConfiguration_Load_Misc(char[] cFile, char[] skey, char[] value) // 3
{
	p_OnConfiguration_Load_Misc.Start();
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_Finish();
}




//non-module related natives

public int Native_IsCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	return player.bIsCustom;
}
public int Native_SetIsCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.bIsCustom = GetNativeCell(2);
	return 0;
}

public int Native_IsSetCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	return player.bSetCustom;
}
public int Native_SetIsSetCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.bSetCustom = GetNativeCell(2);
	return 0;
}

public int Native_GetPlayerModuleIndex(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	return player.iIndex;
}
public int Native_SetPlayerModuleIndex(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.iIndex = GetNativeCell(2);
	return 0;
}