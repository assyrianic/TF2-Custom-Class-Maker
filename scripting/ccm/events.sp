public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client))
	{
		CustomClass player = CustomClass(client);
		if (player.bIsCustom)
		{
			CCM_OnClassResupply(player.userid);
			//CreateTimer(0.1, TimerEquipClass, player.userid);
		}
	}
	return Plugin_Continue;
}
public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if ( client && IsClientInGame(client) )
	{
		CustomClass player = CustomClass(client);

		SetVariantString(""); AcceptEntityInput(client, "SetCustomModel");
		if ( (!AllowBlu.BoolValue && (GetClientTeam(client) == 3)) || (!AllowRed.BoolValue && (GetClientTeam(client) == 2)) )
		{
			player.bIsCustom = false; //block the blocked teams from being able to become custom classes
		}
		player.bIsCustom = player.bSetCustom; //get if the player is set to be a custom class
		if ( player.bIsCustom ) {
			CCM_OnClassSpawn(player.userid);
			SetUpClass(player.userid);
		}
	}
	return Plugin_Continue;
}
public void SetUpClass(int userid) //set class attributes here like Think timers.
{
	int client = GetClientOfUserId(userid);
	if ( client && IsClientInGame(client) )
	{
		CustomClass player = CustomClass(client);
		CreateTimer(0.1, TimerEquipClass, player.userid);
		CCM_OnInitClass(player.userid);
	}
}
public Action TimerEquipClass(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		CustomClass player = CustomClass(client);
		if (!player.bIsCustom) return Plugin_Continue;
		TF2_RemoveAllWeapons2(client);

		CCM_OnClassEquip(player.userid);
	}
	return Plugin_Continue;
}
public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || event.GetInt("weaponid")) return Plugin_Continue;
	int airblaster = GetClientOfUserId(event.GetInt("userid"));
	int client = GetClientOfUserId(event.GetInt("ownerid"));

	CustomClass player = CustomClass(client);
	CustomClass pyro = CustomClass(airblaster);

	if ( player.bIsCustom )
	{
		CCM_OnClassAirblasted(player.userid, pyro.userid);
	}
	else if ( pyro.bIsCustom ) 
	{
		CCM_OnClassDoAirblast(player.userid, pyro.userid);
	}
	return Plugin_Continue;
}
public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int building = event.GetInt("index");
	int buildref = EntIndexToEntRef(building);

	CustomClass player = CustomClass(attacker);
	if ( player.bIsCustom )
	{
		CCM_OnClassKillBuilding(player.userid, buildref);
	}
	return Plugin_Continue;
}
public Action ChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client))
	{
		if ( (!AllowBlu.BoolValue && GetClientTeam(client) == 3) || (!AllowRed.BoolValue && GetClientTeam(client) == 2) )
			return Plugin_Continue;

		CustomClass player = CustomClass(client);
		if ( player.bIsCustom )
		{
			if ( !player.bSetCustom ) //if player doesn't wanna be class anymore, take them off class
			{
				player.bIsCustom = player.bSetCustom;
				return Plugin_Continue;
			}
			/*else //refresh class supplies
			{
				//OnClassChangeClassEvent - needed? wouldn't it call player spawn?
				//CreateTimer(0.1, TimerEquipClass, player.userid);
			}*/
		}
		/*else
		{
			if ( player.bSetCustom ) player.bIsCustom = true;
		}*/
	}
	return Plugin_Continue;
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int deathflags = event.GetInt("death_flags");

	CustomClass victim = CustomClass(client);
	CustomClass killer = CustomClass(attacker);

	if ( killer.bIsCustom )
	{
		CCM_OnClassKill(victim.userid, killer.userid);

		if ( deathflags & (TF_DEATHFLAG_KILLERDOMINATION|TF_DEATHFLAG_ASSISTERDOMINATION) )
		{
			CCM_OnClassKillDomination(victim.userid, killer.userid);
		}
		else if ( (deathflags & (TF_DEATHFLAG_KILLERREVENGE|TF_DEATHFLAG_ASSISTERREVENGE)) )
		{
			CCM_OnClassKillRevenge(victim.userid, killer.userid);
		}
	}
	else if ( victim.bIsCustom )
	{
		CCM_OnClassKilled(victim.userid, killer.userid);

		if ( deathflags & (TF_DEATHFLAG_KILLERDOMINATION|TF_DEATHFLAG_ASSISTERDOMINATION) )
		{
			CCM_OnClassKilledDomination(victim.userid, killer.userid);
		}
		else if ( (deathflags & (TF_DEATHFLAG_KILLERREVENGE|TF_DEATHFLAG_ASSISTERREVENGE)) )
		{
			CCM_OnClassKilledRevenge(victim.userid, killer.userid);
		}
	}
	return Plugin_Continue;
}
public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast) //is this event needed?
{
	//if (!bEnabled.BoolValue) return Plugin_Continue;
	return Plugin_Continue;
}
public Action ChargeDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;
	int medic = GetClientOfUserId(event.GetInt("userid"));
	int ubered = GetClientOfUserId(event.GetInt("targetid"));

	CustomClass doctor = CustomClass(medic);
	CustomClass patient = CustomClass(ubered);

	if ( patient.bIsCustom )
	{
		CCM_OnClassUbered(patient.userid, doctor.userid);
	}
	else if ( doctor.bIsCustom )
	{
		CCM_OnClassDeployUber(patient.userid, doctor.userid);
	}
	return Plugin_Continue;
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue) return Plugin_Continue;

	CustomClass player;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (!IsValidClient(i, false)) continue;

		player = CustomClass(i);
		if ( player.bIsCustom )
		{
			CreateTimer(10.0, TimerEquipClass, player.userid);
		}
	}
	return Plugin_Continue;
}