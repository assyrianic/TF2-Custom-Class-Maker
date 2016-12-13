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

	bEnabled = CreateConVar("ccm_enabled", "1", "Enable Custom Class Maker plugin", FCVAR_NONE, true, 0.0, true, 1.0);

	AllowBlu = CreateConVar("ccm_blu", "1", "(Dis)Allow Custom Classes to be playable for BLU team", FCVAR_NONE|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AllowRed = CreateConVar("ccm_red", "1", "(Dis)Allow Custom Classes to be playable for RED team", FCVAR_NONE|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AdminFlagByPass = CreateConVar("sm_ccm_flagbypass", "a", "what flag admins need to bypass the custom class limit", FCVAR_NONE);

	//p_OnClassResupply		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassMenuSelected		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassDeSelected		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnInitClass			= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassEquip			= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	p_OnClassAirblasted		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassDoAirblast		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillBuilding		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKill			= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillDomination		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillRevenge		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilled			= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledDomination	= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledRevenge		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassUbered			= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassDeployUber		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	
	p_OnClassKillDeadRinger		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKillFirstBlood		= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledDeadRinger	= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	p_OnClassKilledFirstBlood	= new PrivForws( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );

	p_OnConfiguration_Load_Sounds	= new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Materials= new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Models	= new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef) );

	p_OnConfiguration_Load_Misc	= new PrivForws( CreateForward(ET_Ignore, Param_String, Param_String, Param_String) );

	//AutoExecConfig(true, "CustomClassMaker");
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("player_chargedeployed", ChargeDeployed);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("teamplay_round_start", RoundStart);

	for (int i=MaxClients; i ; --i) {
		if (!IsValidClient(i))
			continue;
		OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
	CustomClass(client).reset();	// in ccm/defs_globals.inc
}

public Action MakeClassMenu(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if ( IsClientInGame(client)) {
		Menu classpick = new Menu(MenuHandler_PickClass);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		classpick.SetTitle("[Custom Class Maker] Choose A Custom Class!");
		int count = hArrayClass.Length; //GetArraySize(hArrayClass);

		if (count <= 0) {
			ReplyToCommand(client, "[CCM] No Class Modules Loaded! Please install a Class Module to use this command.");
			return Plugin_Continue;
		}

		char longnameholder[32];
		for (int i=0 ; i<count ; ++i) {
			StringMap map = hArrayClass.Get(i);
			map.GetString("LongName", longnameholder, sizeof(longnameholder));
			classpick.AddItem("pickclass", longnameholder);
		}
		classpick.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_PickClass(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32]; menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select) {
		CustomClass player = CustomClass(client);
		if (player.bSetCustom && player.iIndex == selection)
			ReplyToCommand(client, "[CCM] You've already picked that class stupid!");
		else {
			StringMap smMap = hArrayClass.Get(selection);
			player.hIndex = GetClassSubPlugin( smMap );
			char classnameholder[32];
			smMap.GetString("LongName", classnameholder, sizeof(classnameholder));
			ReplyToCommand(client, "[CCM] You selected the %s class!", classnameholder);
			player.iIndex = selection;

			//CCM_OnClassMenuSelected
			player.bSetCustom = true;
			CCM_OnClassMenuSelected(player.userid); 
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action MakeNotClass(int client, int args)
{
	if ( !bEnabled.BoolValue )
		return Plugin_Continue;

	CustomClass player = CustomClass(client);
	if ( !player.bIsCustom ) {
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

	return Plugin_Handled;
}
/*
public void ClassInitialize(const int userid)
{
	if (!GetConVarBool(bEnabled))
		return;
	
	int client = GetClientOfUserId(userid);
	if ( client <= 0 )
		return;
	
	CustomClass genus = CustomClass(userid, true);
	int iTeam = GetClientTeam(client);
	if ( (!GetConVarBool(AllowBlu) && (iTeam == 3)) || (!GetConVarBool(AllowRed) && (iTeam == 2)) )
	{
		switch (iTeam) {
			case 2: ReplyToCommand(client, "RED players are not allowed to play this Class");
			case 3: ReplyToCommand(client, "BLU players are not allowed to play this Class");
		}
		return;
	}
	int ClassLimit, iCount = 0;
	switch (iTeam) {
		case 0, 1: ClassLimit = -2;
		case 2: ClassLimit = GetConVarInt(RedLimit);
		case 3: ClassLimit = GetConVarInt(BluLimit);
	}
	if (ClassLimit == -1) {
		genus.bSetCustom = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		return;
	}
	else if (ClassLimit == 0) {
		if (IsImmune(client)) {
			genus.bSetCustom = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** That Custom Class is Blocked for your Team ****");
		return;
	}
	
	CustomClass loop;
	for (int i=MaxClients ; i ; --i) {
		if (!IsValidClient(i))
			continue;

		loop = CustomClass(i);
		if ( (GetClientTeam(i) < 2) && loop.bSetCustom )	// remove players who played as custom then went spec
			loop.bSetCustom = false;
		else if ( ( (!GetConVarBool(AllowBlu) && GetClientTeam(i) == 3) || (!GetConVarBool(AllowRed) && GetClientTeam(i) == 2) ) && loop.bSetCustom ) 
			loop.bSetCustom = false;	// remove players who were forced to switch teams while dead and new team is blocked
		
		if (GetClientTeam(i) == iTeam && i != client && loop.bSetCustom)	// get amount of customs on team
			++iCount;
	}
	if (iCount < ClassLimit) {
		genus.bSetCustom = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
	}
	else if (iCount >= ClassLimit) {
		if ( IsImmune(client) ) {
			genus.bSetCustom = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** Custom Class Limit is Reached ****");
	}
	return;
}
MAKE YOUR OWN DAMN CLASS LIMITS
*/

public bool IsImmune(const int iClient)
{
	if (!IsValidClient(iClient, false))
		return false;

	char sFlags[32]; GetConVarString(AdminFlagByPass, sFlags, sizeof(sFlags));
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
	if (GetTrieValueCaseInsensitive(hTrieClass, name, GotClassName))
		return GotClassName;
	return null;
}
public int RegisterClass(Handle pluginhndl, const char shortname[16], const char longname[32])
{
	if (!ValidateName(shortname)) {
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

stock PrivForws GetCCMHookType(const CCMHookType hook)
{
	switch ( hook ) {
		//case CCMHook_OnClassResupply:			return p_OnClassResupply;
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
		case CCMHook_OnClassKillDeadRinger:		return p_OnClassKillDeadRinger;
		case CCMHook_OnClassKillFirstBlood:		return p_OnClassKillFirstBlood;
		case CCMHook_OnClassKilledDeadRinger:		return p_OnClassKilledDeadRinger;
		case CCMHook_OnClassKilledFirstBlood:		return p_OnClassKilledFirstBlood;
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
	
	CreateNative("CCMClass.CCMClass", Native_CCMInstance);

	CreateNative("CCM_IsCustomClass", Native_IsCustomClass);
	CreateNative("CCMClass.bIsCustom.get", Native_IsCustomClass2);
	
	CreateNative("CCM_SetIsCustomClass", Native_SetIsCustomClass);
	CreateNative("CCMClass.bIsCustom.set", Native_SetIsCustomClass2);
	
	CreateNative("CCM_IsSetCustomClass", Native_IsSetCustomClass);
	CreateNative("CCMClass.bSetCustom.get", Native_IsSetCustomClass2);
	
	CreateNative("CCM_SetIsSetCustomClass", Native_SetIsSetCustomClass);
	CreateNative("CCMClass.bSetCustom.set", Native_SetIsSetCustomClass2);
	
	CreateNative("CCM_GetPlayerModuleIndex", Native_GetPlayerModuleIndex);
	CreateNative("CCMClass.iIndex.get", Native_GetPlayerModuleIndex2);
	
	CreateNative("CCM_SetPlayerModuleIndex", Native_SetPlayerModuleIndex);
	CreateNative("CCMClass.iIndex.set", Native_SetPlayerModuleIndex2);
	
	CreateNative("CCMClass.userid.get", Native_CCMGetUserid);
	CreateNative("CCMClass.index.get", Native_CCMGetIndex);
	//===========================================================================================================================

	RegPluginLibrary("ccm");
	MarkNativeAsOptional("CCM_RegisterClass");
	MarkNativeAsOptional("CCM_LoadConfig");
	MarkNativeAsOptional("CCM_Hook");
	MarkNativeAsOptional("CCM_HookEx");
	MarkNativeAsOptional("CCM_Unhook");
	MarkNativeAsOptional("CCM_UnhookEx");

	MarkNativeAsOptional("CCMClass.CCMClass");
	MarkNativeAsOptional("CCMClass.userid.get");
	MarkNativeAsOptional("CCMClass.index.get");
	
	MarkNativeAsOptional("CCMClass.bIsCustom.get");
	MarkNativeAsOptional("CCMClass.bIsCustom.set");
	MarkNativeAsOptional("CCMClass.bSetCustom.get");
	MarkNativeAsOptional("CCMClass.bSetCustom.set");
	MarkNativeAsOptional("CCMClass.iIndex.get");
	MarkNativeAsOptional("CCMClass.iIndex.set");

	return APLRes_Success;
}

public int Native_RegisterClassSubplugin(Handle plugin, int numParams)
{
	char ShortModuleName[16]; GetNativeString(1, ShortModuleName, sizeof(ShortModuleName));
	char ModuleName[32]; GetNativeString(2, ModuleName, sizeof(ModuleName));

	int ClassIndex = RegisterClass(plugin, ShortModuleName, ModuleName);	// ALL PROPS TO COOKIES.NET AKA COOKIES.IO
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
		FwdHandle.Add(plugin, Func);
}

public int Native_HookEx(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);
	PrivForws FwdHandle = GetCCMHookType(CCMHook);
	
	Function Func = GetNativeFunction(2);
	if (FwdHandle != null)
		return FwdHandle.Add(plugin, Func);
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);
	PrivForws FwdHandle = GetCCMHookType(CCMHook);

	if (FwdHandle != null)
		FwdHandle.Remove(plugin, GetNativeFunction(2));
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	CCMHookType CCMHook = GetNativeCell(1);
	PrivForws FwdHandle = GetCCMHookType(CCMHook);

	if(FwdHandle != null)
		return FwdHandle.Remove(plugin, GetNativeFunction(2));
	return 0;
}


// Internal private forward calls

/*
public void CCM_OnClassResupply(int userid) // 2
{
	//Call_StartForward(p_OnClassResupply);
	p_OnClassResupply.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_Finish();
}
*/
public void CCM_OnClassMenuSelected(int userid) // 2
{
	p_OnClassMenuSelected.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassDeSelected(int userid) // 2
{
	p_OnClassDeSelected.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnInitClass(int userid) // 2
{
	p_OnInitClass.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassEquip(int userid) // 2
{
	p_OnClassEquip.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_Finish();
}
public void CCM_OnClassAirblasted(int userid, int attackerid) // 3
{
	p_OnClassAirblasted.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassDoAirblast(int userid, int attackerid) // 3
{
	p_OnClassDoAirblast.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(userid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillBuilding(int userid, int entref) // 3
{
	p_OnClassKillBuilding.Start();
	Call_PushCell(CustomClass(userid, true).iIndex);
	Call_PushCell(userid);
	Call_PushCell(entref);
	Call_Finish();
}
public void CCM_OnClassKill(int victimid, int attackerid) // 3
{
	p_OnClassKill.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillDomination(int victimid, int attackerid) // 3
{
	p_OnClassKillDomination.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillRevenge(int victimid, int attackerid) // 3
{
	p_OnClassKillRevenge.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilled(int victimid, int attackerid) // 3
{
	p_OnClassKilled.Start();
	Call_PushCell(CustomClass(victimid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilledDomination(int victimid, int attackerid) // 3
{
	p_OnClassKilledDomination.Start();
	Call_PushCell(CustomClass(victimid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilledRevenge(int victimid, int attackerid) // 3
{
	p_OnClassKilledRevenge.Start();
	Call_PushCell(CustomClass(victimid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassUbered(int patientid, int medicid) // 3
{
	p_OnClassUbered.Start();
	Call_PushCell(CustomClass(patientid, true).iIndex);
	Call_PushCell(patientid);
	Call_PushCell(medicid);
	Call_Finish();
}
public void CCM_OnClassDeployUber(int patientid, int medicid) // 3
{
	p_OnClassDeployUber.Start();
	Call_PushCell(CustomClass(medicid, true).iIndex);
	Call_PushCell(patientid);
	Call_PushCell(medicid);
	Call_Finish();
}

public void CCM_OnClassKillDeadRinger(int victimid, int attackerid) // 3
{
	p_OnClassKillDeadRinger.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKillFirstBlood(int victimid, int attackerid) // 3
{
	p_OnClassKillFirstBlood.Start();
	Call_PushCell(CustomClass(attackerid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}

public void CCM_OnClassKilledDeadRinger(int victimid, int attackerid) // 3
{
	p_OnClassKilledDeadRinger.Start();
	Call_PushCell(CustomClass(victimid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
	Call_Finish();
}
public void CCM_OnClassKilledFirstBlood(int victimid, int attackerid) // 3
{
	p_OnClassKilledFirstBlood.Start();
	Call_PushCell(CustomClass(victimid, true).iIndex);
	Call_PushCell(victimid);
	Call_PushCell(attackerid);
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
public int Native_IsCustomClass2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	return x.bIsCustom;
}

public int Native_SetIsCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.bIsCustom = GetNativeCell(2);
	return 0;
}
public int Native_SetIsCustomClass2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	x.bIsCustom = GetNativeCell(2);
	return 0;
}

public int Native_IsSetCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	return player.bSetCustom;
}
public int Native_IsSetCustomClass2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	return x.bSetCustom;
}

public int Native_SetIsSetCustomClass(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.bSetCustom = GetNativeCell(2);
	return 0;
}
public int Native_SetIsSetCustomClass2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	x.bSetCustom = GetNativeCell(2);
	return 0;
}

public int Native_GetPlayerModuleIndex(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	return player.iIndex;
}
public int Native_GetPlayerModuleIndex2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	return x.iIndex;
}

public int Native_SetPlayerModuleIndex(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1));
	player.iIndex = GetNativeCell(2);
	return 0;
}
public int Native_SetPlayerModuleIndex2(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	x.iIndex = GetNativeCell(2);
	return 0;
}

public int Native_CCMInstance(Handle plugin, int numParams)
{
	CustomClass player = CustomClass(GetNativeCell(1), GetNativeCell(2));
	return view_as< int >(player);
}

public int Native_CCMGetUserid(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	return x.userid;
}
public int Native_CCMGetIndex(Handle plugin, int numParams)
{
	CustomClass x = GetNativeCell(1);
	return x.index;
}