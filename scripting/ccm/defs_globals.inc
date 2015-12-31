
#define PLUGIN_VERSION		"1.0.0 BETA"

//#define MAJOR_REVISION "1", MINOR_REVISION "0", STABLE_REVISION "0", DEV_REVISION "BETA"

//bools
bool bIsCustomClass[PLYR];
bool bSetCustomClass[PLYR];
//bool bHasLoadout[PLYR][MAXCLASSES]; //set if custom class has a customizable loadout

//ints
Handle hClassIndex[PLYR];
int iClassIndex[PLYR];

enum CCM_FileType
{
	CCM_none,
	CCM_Sounds,
	CCM_Materials,
	CCM_Models,
	CCM_Misc
};

CCM_FileType CCM_Load_Type = CCM_none;

methodmap CustomClass
{
	public CustomClass(int index)
	{
		if (index > 0 && index <= MaxClients && IsClientInGame(index)) {
			return view_as<CustomClass>( GetClientUserId(index) );
		}
		return view_as<CustomClass>(-1);
	}
	property int userid {
		public get()				{ return view_as<int>(this); }
	}
	property int index {
		public get()				{ return GetClientOfUserId( this.userid ); }
	}
	property bool bIsCustom
	{
		public get()				{ return bIsCustomClass[ this.index ]; }
		public set( bool val )			{ bIsCustomClass[ this.index ] = val; }
	}
	property bool bSetCustom
	{
		public get()				{ return bSetCustomClass[ this.index ]; }
		public set( bool val )			{ bSetCustomClass[ this.index ] = val; }
	}
	property Handle hIndex //the only global variable not exposed from natives
	{
		public get()				{ return hClassIndex[ this.index ]; }
		public set( Handle val )		{ hClassIndex[ this.index ] = val; }
	}
	property int iIndex
	{
		public get()				{ return iClassIndex[ this.index ]; }
		public set( int val )			{ iClassIndex[ this.index ] = val; }
	}
	public void reset()
	{
		this.bIsCustom = false;
		this.bSetCustom = false;
		this.hIndex = null;
		this.iIndex = -1;
	}
};

//cvar handles
ConVar bEnabled = null;
ConVar AllowBlu = null;
ConVar AllowRed = null;
ConVar AdminFlagByPass = null;

ArrayList hArrayClass = null;	// List <Subplugin>
StringMap hTrieClass = null;	// Map <Boss Name, Subplugin Handle>



// Private Forwards

methodmap PrivForws < Handle	//very useful ^^
{
	public PrivForws( Handle forw )
	{
		if (forw)
			return view_as<PrivForws>( forw );
		return null;
	}
	property int FuncCount
	{
		public get()	{ return GetForwardFunctionCount(this); }
	}
	public bool Add(Handle plugin, Function func)
	{
		return AddToForward(this, plugin, func);
	}
	public bool Remove(Handle plugin, Function func)
	{
		return RemoveFromForward(this, plugin, func);
	}
	public int RemoveAll(Handle plugin)
	{
		return RemoveAllFromForward(this, plugin);
	}
	public void Start()
	{
		Call_StartForward(this);
	}
};

PrivForws p_OnClassResupply;
PrivForws p_OnClassSpawn;
PrivForws p_OnClassMenuSelected;
PrivForws p_OnClassDeSelected;
PrivForws p_OnInitClass;
PrivForws p_OnClassEquip;
PrivForws p_OnClassAirblasted;
PrivForws p_OnClassDoAirblast;
PrivForws p_OnClassKillBuilding;
PrivForws p_OnClassKill;
PrivForws p_OnClassKillDomination;
PrivForws p_OnClassKillRevenge;
PrivForws p_OnClassKilled;
PrivForws p_OnClassKilledDomination;
PrivForws p_OnClassKilledRevenge;
PrivForws p_OnClassUbered;
PrivForws p_OnClassDeployUber;
PrivForws p_OnConfiguration_Load_Sounds;
PrivForws p_OnConfiguration_Load_Materials;
PrivForws p_OnConfiguration_Load_Models;
PrivForws p_OnConfiguration_Load_Misc;
