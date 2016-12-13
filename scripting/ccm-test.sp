#include <tf2_stocks>
#include <sdkhooks>
#include <morecolors>
#include <ccm>

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = {
	name 			= "test",
	author 			= "nergal/assyrian",
	description 		= "test",
	version 		= PLUGIN_VERSION,
	url 			= "hue" //will fill later
};

int iThisPlugin = -1, sounds, models, materials;
#define	ThisConfigFile	"configs/ccm/test.cfg"

#define ASSERT_MODULE		if (iModuleIndex != iThisPlugin) return		// Trust me you'll need this

public void OnPluginStart()
{
	RegAdminCmd("sm_reloadtest", CmdReloadCFG, ADMFLAG_GENERIC);
	//AutoExecConfig(true, "CCM-TestClass");
}


/* YOU NEED TO USE OnAllPluginsLoaded() BECAUSE WE NEED TO MAKE SURE THE CCM PLUGIN LOADS FIRST */

public void OnAllPluginsLoaded()
{
	iThisPlugin = CCM_RegisterClass("test", "Test Class");

	if (!CCM_HookEx(CCMHook_OnClassMenuSelected, OnClassMenuSelected))
	{
		LogError("Error loading CCMHook_OnClassMenuSelected forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassDeSelected, OnClassDeSelected))
	{
		LogError("Error loading CCMHook_OnClassDeSelected forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnConfiguration_Load_Sounds, OnConfigLoadSounds))
	{
		LogError("Error loading CCMHook_OnConfiguration_Load_Sounds forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnConfiguration_Load_Materials, OnConfigLoadMaterials))
	{
		LogError("Error loading CCMHook_OnConfiguration_Load_Materials forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnConfiguration_Load_Models, OnConfigLoadModels))
	{
		LogError("Error loading CCMHook_OnConfiguration_Load_Models forwards for Test Class.");
	}

	// LoadConfiguration ALWAYS after CCMHook
	CCM_LoadConfig(ThisConfigFile);
}

// LOAD CONFIGURATION
public void OnConfigLoadSounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if ( !StrEqual(cFile, ThisConfigFile) )
		return;
	sounds = 1;
}
public void OnConfigLoadMaterials(char[] cFile, char[] skey, char[] value, bool &bPrecacheGeneric, bool &bAddFileToDownloadsTable)
{
	if ( !StrEqual(cFile, ThisConfigFile) )
		return;
	materials = 1;
}
public void OnConfigLoadModels(char[] cFile, char[] skey, char[] value, bool &bPreCacheModel, bool &bAddFileToDownloadsTable)
{
	if ( !StrEqual(cFile, ThisConfigFile) )
		return;
	models = 1;
}

public void OnClassMenuSelected(const int iModuleIndex, const CCMClass Player)	//(int iModuleIndex, int iUserId)
{
	ASSERT_MODULE ;
	//CCMClass player = CCMClass(iUserId, true);
	CPrintToChat(Player.index, "{red}[CCM]{default} OnClassMenuSelected Called");
	Load_CCMHooks();
}
public void Load_CCMHooks()
{
	if (!CCM_HookEx(CCMHook_OnInitClass, OnInitClass))
	{
		LogError("Error loading CCMHook_OnInitClass forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassEquip, OnClassEquip))
	{
		LogError("Error loading CCMHook_OnClassEquip forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassAirblasted, OnClassAirblasted))
	{
		LogError("Error loading CCMHook_OnClassAirblasted forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKillBuilding, OnClassKillBuilding))
	{
		LogError("Error loading CCMHook_OnClassKillBuilding forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKill, OnClassKill))
	{
		LogError("Error loading CCMHook_OnClassKill forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKillDomination, OnClassKillDomination))
	{
		LogError("Error loading CCMHook_OnClassKillDomination forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKillRevenge, OnClassKillRevenge))
	{
		LogError("Error loading CCMHook_OnClassKillRevenge forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKilled, OnClassKilled))
	{
		LogError("Error loading CCMHook_OnClassKilled forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKilledDomination, OnClassKilledDomination))
	{
		LogError("Error loading CCMHook_OnClassKilledDomination forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassKilledRevenge, OnClassKilledRevenge))
	{
		LogError("Error loading CCMHook_OnClassKilledRevenge forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassUbered, OnClassUbered))
	{
		LogError("Error loading CCMHook_OnClassUbered forwards for Test Class.");
	}
	if (!CCM_HookEx(CCMHook_OnClassDeployUber, OnClassDeployUber))
	{
		LogError("Error loading CCMHook_OnClassDeployUber forwards for Test Class.");
	}
}

public void OnClassDeSelected(const int iModuleIndex, const CCMClass Player)	//(int iModuleIndex, int iUserId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iUserId);
	//CCMClass player = CCMClass(iUserId, true);
	CPrintToChat(Player.index, "{red}[CCM]{default} OnClassDeselected Called");
}
public void UnLoad_CCMHooks()
{
	if (!CCM_UnhookEx(CCMHook_OnInitClass, OnInitClass))
	{
		LogError("Error unloading CCMHook_OnInitClass forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassEquip, OnClassEquip))
	{
		LogError("Error unloading CCMHook_OnClassEquip forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassAirblasted, OnClassAirblasted))
	{
		LogError("Error unloading CCMHook_OnClassAirblasted forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKillBuilding, OnClassKillBuilding))
	{
		LogError("Error unloading CCMHook_OnClassKillBuilding forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKill, OnClassKill))
	{
		LogError("Error unloading CCMHook_OnClassKill forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKillDomination, OnClassKillDomination))
	{
		LogError("Error unloading CCMHook_OnClassKillDomination forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKillRevenge, OnClassKillRevenge))
	{
		LogError("Error unloading CCMHook_OnClassKillRevenge forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKilled, OnClassKilled))
	{
		LogError("Error unloading CCMHook_OnClassKilled forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKilledDomination, OnClassKilledDomination))
	{
		LogError("Error unloading CCMHook_OnClassKilledDomination forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassKilledRevenge, OnClassKilledRevenge))
	{
		LogError("Error unloading CCMHook_OnClassKilledRevenge forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassUbered, OnClassUbered))
	{
		LogError("Error unloading CCMHook_OnClassUbered forwards for Test Class.");
	}
	if (!CCM_UnhookEx(CCMHook_OnClassDeployUber, OnClassDeployUber))
	{
		LogError("Error unloading CCMHook_OnClassDeployUber forwards for Test Class.");
	}
}

public void OnInitClass(const int iModuleIndex, const CCMClass Player)	//(int iModuleIndex, int iUserId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iUserId);
	//CCMClass player = CCMClass(iUserId, true);
	CPrintToChat(Player.index, "{red}[CCM]{default} OnInitClass Called");
}
public void OnClassEquip(const int iModuleIndex, const CCMClass Player)	//(int iModuleIndex, int iUserId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iUserId);
	//CCMClass player = CCMClass(iUserId, true);
	CPrintToChat(Player.index, "{red}[CCM]{default} OnClassEquip Called");
}
public void OnClassAirblasted(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassAirblasted Called; Airblaster -> %N", attkr.index);
}
public void OnClassKillBuilding(const int iModuleIndex, const int iAttackerId, const int iBuildingRef)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKillBuilding Called; building reference -> %i", iBuildingRef);
}
public void OnClassKill(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKill Called; victim -> %N", attkr.index);
}
public void OnClassKillDomination(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKillDomination Called; victim -> %N", attkr.index);
}
public void OnClassKillRevenge(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(attkr.index, "{red}[CCM]{default} OnClassKillRevenge Called; victim -> %N", player.index);
}
public void OnClassKilled(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKilled Called; attacker -> %N", attkr.index);
}
public void OnClassKilledDomination(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKilledDomination Called; attacker -> %N", attkr.index);
}
public void OnClassKilledRevenge(const int iModuleIndex, const int iVictimId, const int iAttackerId)
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassKilledRevenge Called; attacker -> %N", attkr.index);
}
public void OnClassUbered(const int iModuleIndex, const int iVictimId, const int iAttackerId) //"victim" is ubered person
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(player.index, "{red}[CCM]{default} OnClassUbered Called; attacker -> %N", attkr.index);
}

public void OnClassDeployUber(const int iModuleIndex, const int iVictimId, const int iAttackerId) //"victim" is ubered person
{
	ASSERT_MODULE ;
	//int client = GetClientOfUserId(iVictimId);
	//int attacker = GetClientOfUserId(iAttackerId);
	CCMClass player = CCMClass(iVictimId, true);
	CCMClass attkr = CCMClass(iAttackerId, true);
	CPrintToChat(attkr.index, "{red}[CCM]{default} OnClassDeployUber Called; victim -> %N", player.index);
}

public Action CmdReloadCFG(int client, int iAction)
{
	//ServerCommand("sm_rcon exec sourcemod/CCM-TankClass.cfg");
	ReplyToCommand(client, "sounds -> %i, models -> %i, materials -> %i", sounds, models, materials);
	return Plugin_Handled;
}
