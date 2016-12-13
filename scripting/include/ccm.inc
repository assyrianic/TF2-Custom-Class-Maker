#if defined _ccm_included
	#endinput
#endif
	#define _ccm_included

#define MaxEntities			2048
#define PLYR				MAXPLAYERS+1	// 65
/**< Maximum number of players SourceMod supports */
// This number is much higher than what TF2 supports

// Setting (PLYR = Max players) to maximum TF2 Supports (32 + 2 relay?)
//#define PLYR				34

#define PATH				64
#define PATHX				PLATFORM_MAX_PATH
#define nullfunc			INVALID_FUNCTION
#define nullvec				NULL_VECTOR
#define IsClientValid(%1)		( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )

#define and		&&
#define or		||

// unusued
#define MAXCLASSES			50	//who's gonna think up over 50 custom classes anyways? Let alone GET to 50?


methodmap CCMClass	/* Custom Class Maker Class Methodmap from Natives!! */
{
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the CCM internal methodmap
	 * @param index			index or the userid of a player
	 * @param userid		if using userid instead of player index, set this param to true
	 * @return			an instance of the CCMClass methodmap
	*/
	public native CCMClass(const int index, bool userid=false);

	/* **** **** [ P R O P E R T I E S ] **** **** */
	
	/**
	 * gets the userid of the methodmap instance
	 * @return			the bare integer player userid
	*/
	property int userid {
		public native get();				//{ return view_as<int>(this); }
	}
	
	/**
	 * gets the index of the methodmap instance
	 * @return			the bare integer player index
	*/
	property int index {
		public native get();				//{ return GetClientOfUserId( view_as<int>(this) ); }
	}

	/**
	 * get/set if a CCMClass instance is a custom class or not
	 * @param val			set if the instance is a custom class
	 * @return			true if the instance is a custom class, false if not.
	*/
	property bool bIsCustom
	{
		public native get();				//{ return CCM_IsCustomClass( this.index ); }
		public native set( const bool val );			//{ CCM_SetIsCustomClass(this.index, val); }
	}
	
	/**
	 * get/set if a CCMClass instance is set to become a custom class or not
	 * @param val			set if the instance will become a custom class
	 * @return			true if the instance will become a custom class, false if not.
	*/
	property bool bSetCustom
	{
		public native get();				//{ return CCM_IsSetCustomClass(this.index); }
		public native set( const bool val );			//{ CCM_SetIsSetCustomClass(this.index, val); }
	}
	
	/**
	 * get/set the index of the Class Module the instance will be using to run code
	 * @note			VERY DANGEROUS, USE WITH EXTREME CAUTION.
	 * @param val			integer to set the player's current class module index to
	 * @return			index of the plugin array the class is using to run its specific code
	*/
	property int iIndex
	{
		public native get();				//{ return CCM_GetPlayerModuleIndex(this.index); }
		public native set( const int val );			//{ CCM_SetPlayerModuleIndex(this.index, val); }
	}
	///////////////////////////////
};


//=================================================== [ F O R W A R D S ] =========================================================
enum CCMHookType {
	CCMHook_None,
	CCMHook_OnClassMenuSelected,
	CCMHook_OnClassDeSelected,
	CCMHook_OnInitClass,
	CCMHook_OnClassEquip,
	CCMHook_OnClassAirblasted,
	CCMHook_OnClassDoAirblast,
	CCMHook_OnClassKillBuilding,
	CCMHook_OnClassKill,
	CCMHook_OnClassKillDomination,
	CCMHook_OnClassKillRevenge,
	CCMHook_OnClassKilled,
	CCMHook_OnClassKilledDomination,
	CCMHook_OnClassKilledRevenge,
	CCMHook_OnClassUbered,
	CCMHook_OnClassDeployUber,
	CCMHook_OnClassKillDeadRinger,
	CCMHook_OnClassKillFirstBlood,
	CCMHook_OnClassKilledDeadRinger,
	CCMHook_OnClassKilledFirstBlood,
	CCMHook_OnConfiguration_Load_Sounds,
	CCMHook_OnConfiguration_Load_Materials,
	CCMHook_OnConfiguration_Load_Models,
	CCMHook_OnConfiguration_Load_Misc
};

typeset CCMHookCB {	/* Optional Methodmap variants! */
	// CCMHook OnClassMenuSelected
	// CCMHook OnClassDeSelected
	// CCMHook OnInitClass
	// CCMHook OnClassEquip
	function void (const int iModuleIndex, const int iUserId);
	function void (const int iModuleIndex, const CCMClass Player);

	// CCMHook OnClassAirblasted
	// CCMHook OnClassDoAirblast
	// CCMHook OnClassKill
	// CCMHook OnClassKillDomination
	// CCMHook OnClassKillRevenge
	// CCMHook OnClassKilled
	// CCMHook OnClassKilledDomination
	// CCMHook OnClassKilledRevenge
	// CCMHook OnClassUbered
	// CCMHook OnClassDeployUber
	// CCMHook OnClassKillDeadRinger,
	// CCMHook OnClassKillFirstBlood,
	// CCMHook OnClassKilledDeadRinger,
	// CCMHook OnClassKilledFirstBlood,
	function void (const int iModuleIndex, const int iVictimId, const int iAttackerId);
	function void (const int iModuleIndex, const CCMClass Victim, const CCMClass Attacker);

	// CCMHook OnClassKillBuilding
	function void (const int iModuleIndex, const int iAttackerId, const int iBuildingRef);
	function void (const int iModuleIndex, const CCMClass Attacker, const int iBuildingRef);

	// CCMHook OnConfiguration_Load_Sounds
	// CCMHook OnConfiguration_Load_Materials
	// CCMHook OnConfiguration_Load_Models
	function void (char[] cFile, char[] skey, char[] value, bool& bPreCacheFile, bool& bAddFileToDownloadsTable);

	// CCMHook OnConfiguration_Load_Misc
	function void (char[] cFile, char[] skey, char[] value);
};

//=================================================================================================================================

//=================================================== [ N A T I V E S ] ==========================================================

/** 
 * Registers a custom class module with Custom Class Maker.
 *
 * @param shortname		developer/programming name of module. i.e. "module"
 * @param longname		official name of module. i.e. "The Module"
 * @return			Array index number of module if registration is successful.
 * @error			returns negative one (-1)
 */
native int CCM_RegisterClass(char shortname[16], char longname[32]);

/** 
 * Loads a custom class module's special files config file.
 *
 * @param charFile		path to the config file. example: CCM_LoadConfig("configs/ccm/module.cfg");
 * @return			true if loading is successful, false otherwise.
 */
native bool CCM_LoadConfig(char[] charFile);

/** 
 * Hooks a typeset to a function
 *
 * @param type			type of function to hook
 * @param callback		hook function to call when hook is called.
 * @return			true if hooking is successful, false otherwise.
 */
native void CCM_Hook(CCMHookType type, CCMHookCB callback);
native bool CCM_HookEx(CCMHookType type, CCMHookCB callback);

/** 
 * Unhooks a typeset from a function
 *
 * @param type			type of function to unhook
 * @param callback		function to unhook.
 * @return			true if unhooking is successful, false otherwise.
 */
native void CCM_Unhook(CCMHookType type, CCMHookCB callback);
native bool CCM_UnhookEx(CCMHookType type, CCMHookCB callback);

/** 
 * Check if a player is a custom class
 *
 * @param client		index of a player
 * @return			true if player is a custom class, false otherwise.
 */
native bool CCM_IsCustomClass(int client);

/** 
 * set a player to be a custom class or not
 *
 * @param client		index of a player
 * @param state			set player as custom class or not
 * @noreturn
 */
native void CCM_SetIsCustomClass(int client, bool state);

/** 
 * if a player is set to be a custom class or not
 *
 * @param client		index of a player
 * @return			true if player is set to be a custom class, false otherwise.
 */
native bool CCM_IsSetCustomClass(int client);

/** 
 * set to set a player to be a custom class or not
 *
 * @param client		index of a player
 * @param bstate		set player to be set as custom class or not
 * @noreturn
 */
native void CCM_SetIsSetCustomClass(int client, bool bstate);

/** 
 * Gets the current index of the custom class module the player is using
 *
 * @param client		index of a player
 * @return			abstract array index of module.
 */
native int CCM_GetPlayerModuleIndex(int client);

/** 
 * Sets the current index of the custom class module the player is using
 * @note: VERY DANGEROUS, USE WITH EXTREME CAUTION.
 * @param client		index of a player
 * @param index			integer to set the player's current class module index to
 * @noreturn
*/
native void CCM_SetPlayerModuleIndex(int client, int index);


//=================================================== [ S T O C K S ] =========================================================
stock int SetWeaponAmmo(int weapon, int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
stock int GetWeaponClip(int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(int weapon, int ammo)
{
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int SpawnClientWeapon(int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == null)
		return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 0) {
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2 = 0;
		for (int i = 0; i < count; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete (hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock void SetWeaponInvis(const int client, const int alpha)
{
	char wepclassname[32];
	for (int i=0 ; i<5 ; i++) {
		int entity = GetPlayerWeaponSlot(client, i); 
		if (entity != -1 && StrContains(wepclassname, "tf_weapon", false))
		{ 
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 255, 255, 255, alpha); 
		} 
	}
}
stock void SetClientOverlay(int client, char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	if (IsValidClient(client))
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}
stock bool IsValidClient(const int client, bool replaycheck=true)
{
	if (client <= 0 || client > MaxClients)
		return false;
	if (!IsClientInGame(client))
		return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
		return false;
	if (replaycheck)
		if (IsClientSourceTV(client) || IsClientReplay(client))
			return false;
	return true;
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i=0 ; i<length ; ++i) {
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores and normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_'))
			return false;
	}
	// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
stock bool GetTrieValueCaseInsensitive(StringMap trie, const char[] key, any &value)
{
	if (trie == null)
		return false;
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return trie.GetValue(trieKey, value); //GetTrieValue(trie, trieKey, value);
}
stock bool SetTrieValueCaseInsensitive(StringMap trie, const char[] key, any value)
{
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return trie.SetValue(trieKey, value); //SetTrieValue(trie, trieKey, value);
}
stock void StringToLower(const char[] input, char[] output, int size)
{
	for (int i=0 ; i<size ; ++i) {
		if (IsCharUpper(input[i]))
			output[i] = CharToLower(input[i]);
		else output[i] = input[i];
	}
}
stock Handle GetClassSubPlugin(StringMap hndl)
{
	Handle plugin;
	if ( hndl.GetValue("Subplugin", plugin) )
		return plugin;
	// Shouldn't actually get here, but we keep it just incase
	return null;
}
stock int FilterSentence(char[] message,bool extremefilter=false,bool RemoveWhiteSpace=false)
{
	int charMax = strlen(message)+1;
	int charIndex;
	int copyPos = 0;

	char[] strippedString = new char[charMax];

	for (charIndex=0; charIndex<charMax; ++charIndex) {
		// Reach end of string. Break.
		if (message[copyPos] == 0) {
			strippedString[copyPos] = 0;
			break;
		}

		if (GetCharBytes(message[charIndex]) > 1)
			continue;

		if ( RemoveWhiteSpace && IsCharSpace(message[charIndex]) )
			continue;

		if(extremefilter && IsAlphaNumeric(message[charIndex]))
		{
			strippedString[copyPos] = message[charIndex];
			copyPos++;
			continue;
		}

		// Found a normal character. Copy.
		if (!extremefilter && IsNormalCharacter(message[charIndex])) {
			strippedString[copyPos] = message[charIndex];
			copyPos++;
			continue;
		}
	}

	// Copy back to passing parameter.
	strcopy(message, charMax, strippedString);
	return copyPos;
}
stock bool IsAlphaNumeric(int characterNum) {
	return ((characterNum >= 48 && characterNum <=57)
		||  (characterNum >= 65 && characterNum <=90)
		||  (characterNum >= 97 && characterNum <=122));
}
stock bool IsNormalCharacter(int characterNum) {
	return (characterNum > 31 && characterNum < 127);
}
stock bool IsUnicode(int characterNum)
{
	return ( characterNum >= 128 );
}
//=================================================================================================================================

public SharedPlugin __pl_CCM = 
{
	name = "ccm",
	file = "ccm.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_CCM_SetNTVOptional()
{
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
	
	MarkNativeAsOptional("CCMClass.CCMClass");
	MarkNativeAsOptional("CCMClass.userid.get");
	MarkNativeAsOptional("CCMClass.index.get");
	
	MarkNativeAsOptional("CCMClass.bIsCustom.get");
	MarkNativeAsOptional("CCMClass.bIsCustom.set");
	MarkNativeAsOptional("CCMClass.bSetCustom.get");
	MarkNativeAsOptional("CCMClass.bSetCustom.set");
	MarkNativeAsOptional("CCMClass.iIndex.get");
	MarkNativeAsOptional("CCMClass.iIndex.set");
}
#endif