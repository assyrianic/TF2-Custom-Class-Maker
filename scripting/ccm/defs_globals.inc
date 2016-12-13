
#define PLUGIN_VERSION		"1.0.0 BETA"

//#define MAJOR_REVISION "1", MINOR_REVISION "0", STABLE_REVISION "0", DEV_REVISION "BETA"

//bools
//bool bIsCustomClass[PLYR];
//bool bSetCustomClass[PLYR];
//bool bHasLoadout[PLYR][MAXCLASSES]; //set if custom class has a customizable loadout

//ints
//Handle hClassIndex[PLYR];
//int iClassIndex[PLYR];

enum CCM_FileType {
	CCM_none,
	CCM_Sounds,
	CCM_Materials,
	CCM_Models,
	CCM_Misc
};

CCM_FileType CCM_Load_Type = CCM_none;


StringMap hPlayerFields[PLYR];

methodmap CustomClass
{
	public CustomClass(const int index, bool userid=false)
	{
		int player=0;
		if (userid and GetClientOfUserId(index) > 0)
			player = ( index );
		else if ( IsClientValid(index) )
			player = GetClientUserId(index);
		return view_as< CustomClass >( player );
	}
	property int userid {
		public get()				{ return view_as<int>(this); }
	}
	property int index {
		public get()				{ return GetClientOfUserId( view_as<int>(this) ); }
	}
	
	property bool bIsCustom
	{
		public get()				//{ return bIsCustomClass[ this.index ]; }
		{
			bool item; hPlayerFields[this.index].GetValue("bIsCustom", item);
			return item ;
		}
		public set( const bool val )		//{ bIsCustomClass[ this.index ] = val; }
		{
			hPlayerFields[this.index].SetValue("bIsCustom", val);
		}
	}
	property bool bSetCustom
	{
		public get()				//{ return bSetCustomClass[ this.index ]; }
		{
			bool item; hPlayerFields[this.index].GetValue("bSetCustom", item);
			return item ;
		}
		public set( const bool val )		//{ bSetCustomClass[ this.index ] = val; }
		{
			hPlayerFields[this.index].SetValue("bSetCustom", val);
		}
	}
	property Handle hIndex //the only global variable not exposed from natives
	{
		public get()				//{ return hClassIndex[ this.index ]; }
		{
			Handle item; hPlayerFields[this.index].GetValue("hIndex", item);
			return item ;
		}
		public set( const Handle val )		//{ hClassIndex[ this.index ] = val; }
		{
			hPlayerFields[this.index].SetValue("hIndex", val);
		}
	}
	property int iIndex
	{
		public get()				//{ return iClassIndex[ this.index ]; }
		{
			int item; hPlayerFields[this.index].GetValue("iIndex", item);
			return item ;
		}
		public set( const int val )		//{ iClassIndex[ this.index ] = val; }
		{
			hPlayerFields[this.index].SetValue("iIndex", val);
		}
	}
	public void reset()
	{
		if (hPlayerFields[this.index] != null)
			delete hPlayerFields[this.index];

		hPlayerFields[this.index] = new StringMap();
		this.bIsCustom = false;
		this.bSetCustom = false;
		this.hIndex = null;
		this.iIndex = -1;
	}
	public void SetUp()	//set class attributes here like Think timers.
	{
		CreateTimer(0.1, TimerEquipClass, this.userid);
		CCM_OnInitClass(this.userid);
	}
	/*
	public int SpawnWeapon(char[] name, int index, int level, int qual, char[] att)
	{
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if ( !hWep )
			return -1;

		hWep.SetClassname(name);
		hWep.iItemIndex = index;
		hWep.iLevel = level;
		hWep.iQuality = qual;

		char atts[32][32];
		int count = ExplodeString(att, " ; ", atts, 32, 32);
		if (count > 0) {
			hWep.iNumAttribs = count/2;
			int i2 = 0;
			for (int i=0 ; i<count ; i += 2) {
				hWep.SetAttribute( i2, StringToInt(atts[i]), StringToFloat(atts[i+1]) );
				i2++;
			}
		}
		else hWep.iNumAttribs = 0;

		int entity = hWep.GiveNamedItem(this.index);
		delete hWep;
		EquipPlayerWeapon(this.index, entity);
		return entity;
	}
	*/
};

//cvar handles
ConVar
	bEnabled = null,
	AllowBlu = null,
	AllowRed = null,
	AdminFlagByPass = null
;

ArrayList hArrayClass = null;	// List <Subplugin Index>
StringMap hTrieClass = null;	// Map <Boss Name, Subplugin Handle>



// Private Forwards

methodmap PrivForws < Handle	//very useful ^^
{
	public PrivForws( const Handle forw )
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

//PrivForws p_OnClassResupply;
PrivForws
	p_OnClassMenuSelected,
	p_OnClassDeSelected,
	p_OnInitClass,
	p_OnClassEquip,
	p_OnClassAirblasted,
	p_OnClassDoAirblast,
	p_OnClassKillBuilding,
	p_OnClassKill,
	p_OnClassKillDomination,
	p_OnClassKillRevenge,
	p_OnClassKilled,
	p_OnClassKilledDomination,
	p_OnClassKilledRevenge,
	p_OnClassUbered,
	p_OnClassDeployUber,
	p_OnConfiguration_Load_Sounds,
	p_OnConfiguration_Load_Materials,
	p_OnConfiguration_Load_Models,
	p_OnConfiguration_Load_Misc,
	p_OnClassKillDeadRinger,
	p_OnClassKillFirstBlood,
	p_OnClassKilledDeadRinger,
	p_OnClassKilledFirstBlood
;
