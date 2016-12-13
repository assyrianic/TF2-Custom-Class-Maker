
public bool CCM_Load_Configuration(Handle plugin, char[] cFile)
{
	bool found = false;
	KeyValues kv = PrePareTheFile(cFile);

	if (kv != null) {
		found = LoadConfigurationValues(cFile, kv, plugin);
		delete (kv);
		return found;
	}
	return false;
}

public KeyValues PrePareTheFile(char[] cfile)
{
	char path[1024];

	//"configs/sb_weapons.cfg" = cfile
	BuildPath(Path_SM, path, sizeof(path), cfile);

	/* Return true if an update was available. */
	// "TF2_SB_WEAPONS" = cName
	KeyValues kv = new KeyValues("CCM_CONFIGURATION"); //CreateKeyValues("CCM_CONFIGURATION");

	//if (!FileToKeyValues(kv, path))
	if ( !kv.ExportToFile(path) ) {
		delete (kv);
		return null;
	}
	return kv;
}

public bool LoadConfigurationValues(char[] cFile, KeyValues kv, Handle plugin)
{
	kv.Rewind(); //KvRewind(kv);

	//bool result = false;

	char sSectionBuffer[32];
	char sSubKeyBuffer[32];

	char sTempBuffer[PATHX];

	bool found = false;

	bool bPreCacheFile = false;
	bool bAddFileToDownloadsTable = false;

	do {
		// You can read the section/key name by using KvGetSectionName here.
		//PrintToChatAll("do loop\n");

		if (kv.GotoFirstSubKey(false)) //if (KvGotoFirstSubKey(kv, false))
		{
			do {
				//if(KvGetSectionName(kv, sSectionBuffer, sizeof(sSectionBuffer)))
				if ( kv.GetSectionName(sSectionBuffer, sizeof(sSectionBuffer)) )
				{
					PrintToServer("LOADING: %s", sSectionBuffer);
					if ( !StrContains(sSectionBuffer, "sound",false) )
					{
						CCM_Load_Type = CCM_Sounds;
					}
					else if ( !StrContains(sSectionBuffer, "material",false) )
					{
						CCM_Load_Type = CCM_Materials;
					}
					else if ( !StrContains(sSectionBuffer, "model",false) )
					{
						CCM_Load_Type = CCM_Models;
					}
					else if ( !StrContains(sSectionBuffer, "misc",false) )
					{
						CCM_Load_Type = CCM_Misc;
					}
					else {
						continue;
					}

					//PushArrayCell(g_hItemNumber, GetArraySize(g_hItemNumber)+1);

					if (kv.GotoFirstSubKey(false)) //if (KvGotoFirstSubKey(kv, false))
					{
						// Current key is a section. Browse it recursively.
						do {
							//if(KvGetSectionName(kv, sSubKeyBuffer, sizeof(sSubKeyBuffer)))
							if ( kv.GetSectionName(sSubKeyBuffer, sizeof(sSubKeyBuffer)) )
							{
								//KvGetString(kv, NULL_STRING, sTempBuffer, sizeof(sTempBuffer));
								kv.GetString(NULL_STRING, sTempBuffer, sizeof(sTempBuffer));
								if (CCM_Load_Type == CCM_Sounds)
								{
									//TrimString(sSubKeyBuffer);
									//TrimString(sTempBuffer);
									//PrintToServer("CCM_Sounds Before %s = %s",sSubKeyBuffer,sTempBuffer);
									FilterSentence(sSubKeyBuffer);
									FilterSentence(sTempBuffer);
									//PrintToServer("CCM_Sounds After %s = %s",sSubKeyBuffer,sTempBuffer);

									bPreCacheFile = false;
									bAddFileToDownloadsTable = false;

									CCM_OnConfiguration_Load_Sounds(cFile, sSubKeyBuffer, sTempBuffer, bPreCacheFile, bAddFileToDownloadsTable);

									if(bPreCacheFile)
									{
										PrecacheSound(sTempBuffer,true);
									}
									if(bAddFileToDownloadsTable)
									{
										char sFileNameAndPath[PATHX];
										Format(sFileNameAndPath, sizeof(sFileNameAndPath), "sound/%s", sTempBuffer);
										AddFileToDownloadsTable(sFileNameAndPath);
									}

									found = true;
								}
								else if(CCM_Load_Type == CCM_Materials)
								{
									//PrintToServer("CCM_Materials Before %s = %s",sSubKeyBuffer,sTempBuffer);
									FilterSentence(sSubKeyBuffer);
									FilterSentence(sTempBuffer);
									//PrintToServer("CCM_Materials After %s = %s",sSubKeyBuffer,sTempBuffer);

									bPreCacheFile = false;
									bAddFileToDownloadsTable = false;

									CCM_OnConfiguration_Load_Materials(cFile, sSubKeyBuffer, sTempBuffer, bPreCacheFile, bAddFileToDownloadsTable);

									if(bPreCacheFile)
									{
										PrecacheGeneric(sTempBuffer,true);
									}
									if(bAddFileToDownloadsTable)
									{
										AddFileToDownloadsTable(sTempBuffer);
									}

									found = true;
								}
								else if(CCM_Load_Type == CCM_Models)
								{
									//PrintToServer("CCM_Models Before %s = %s",sSubKeyBuffer,sTempBuffer);
									FilterSentence(sSubKeyBuffer);
									FilterSentence(sTempBuffer);
									//PrintToServer("CCM_Models After %s = %s",sSubKeyBuffer,sTempBuffer);

									bPreCacheFile = false;
									bAddFileToDownloadsTable = false;

									CCM_OnConfiguration_Load_Models(cFile, sSubKeyBuffer, sTempBuffer, bPreCacheFile, bAddFileToDownloadsTable);

									if(bPreCacheFile)
									{
										PrecacheModel(sTempBuffer,true);
									}
									if(bAddFileToDownloadsTable)
									{
										AddFileToDownloadsTable(sTempBuffer);
									}

									found = true;
								}
								else if (CCM_Load_Type == CCM_Misc)
								{
									FilterSentence(sSubKeyBuffer);
									FilterSentence(sTempBuffer);
									CCM_OnConfiguration_Load_Misc(cFile, sSubKeyBuffer, sTempBuffer);

									found = true;
								}
							}
						} while (kv.GotoNextKey(false)); //(KvGotoNextKey(kv, false));
						kv.GoBack(); //KvGoBack(kv);
					}
				}
			} while (kv.GotoNextKey(false));
			kv.GoBack();
		}
	} while (kv.GotoNextKey(false));

	//PrintToChatAll("Finished");
	return found;
}

/*
How config looks like

// cbs.cfg (cbs as player-class)

"CCM_CONFIGURATION"
{
	"sounds"
	{
		"CBS2"			"vo/sniper_award" // 1 - 9
		"AUTOLOAD"		"vo/sniper_award01.mp3"
		"AUTOLOAD"		"vo/sniper_award02.mp3"
		"AUTOLOAD"		"vo/sniper_award03.mp3"
		"AUTOLOAD"		"vo/sniper_award04.mp3"
		"AUTOLOAD"		"vo/sniper_award05.mp3"
		"AUTOLOAD"		"vo/sniper_award06.mp3"
		"AUTOLOAD"		"vo/sniper_award07.mp3"
		"AUTOLOAD"		"vo/sniper_award08.mp3"
		"AUTOLOAD"		"vo/sniper_award09.mp3"
		"CBSJump1"		"vo/sniper_specialcompleted02.wav"
	}
	"models"
	{
		"CBSModel"              "models/player/saxton_hale/cbs_v4.mdl"
		"CBSModelPrefix"	"models/player/saxton_hale/cbs_v4"
	}
	"materials"
	{
		"MaterialPrefix"	"materials/models/player/saxton_hale/sniper_red"
		"MaterialPrefix"	"materials/models/player/saxton_hale/sniper_lens"
		"MaterialPrefix"	"materials/models/player/saxton_hale/sniper_head_red"
	}
}
*/