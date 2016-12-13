public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	CustomClass player = CustomClass( event.GetInt("userid") , true );
	if ( player ) {
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");

		if ( (!AllowBlu.BoolValue && (GetClientTeam(player.index) == 3)) || (!AllowRed.BoolValue && (GetClientTeam(player.index) == 2)) )
			player.bSetCustom = false;	// block the blocked teams from being able to become custom classes

		player.bIsCustom = player.bSetCustom;	//get if the player is set to be a custom class
		if (player.bIsCustom)
			player.SetUp();
	}
	return Plugin_Continue;
}
public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || event.GetInt("weaponid"))
		return Plugin_Continue;

	CustomClass pyro = CustomClass( event.GetInt("userid") , true );
	CustomClass player = CustomClass( event.GetInt("ownerid") , true );

	if ( player.bIsCustom )
		CCM_OnClassAirblasted(player.userid, pyro.userid);
	if ( pyro.bIsCustom )
		CCM_OnClassDoAirblast(player.userid, pyro.userid);
	
	return Plugin_Continue;
}
public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	CustomClass player = CustomClass( event.GetInt("attacker") , true );
	//int building = event.GetInt("index");
	int buildref = EntIndexToEntRef(event.GetInt("index"));

	if ( player.bIsCustom )
		CCM_OnClassKillBuilding(player.userid, buildref);
	
	return Plugin_Continue;
}
public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	//int client = GetClientOfUserId(event.GetInt("userid"));
	//int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	CustomClass victim = CustomClass( event.GetInt("userid") , true );
	CustomClass killer = CustomClass( event.GetInt("attacker") , true );
	int deathflags = event.GetInt("death_flags");

	if ( killer.bIsCustom ) {
		CCM_OnClassKill(victim.userid, killer.userid);
		if ( deathflags & (TF_DEATHFLAG_KILLERDOMINATION|TF_DEATHFLAG_ASSISTERDOMINATION) )
			CCM_OnClassKillDomination(victim.userid, killer.userid);

		if ( (deathflags & (TF_DEATHFLAG_KILLERREVENGE|TF_DEATHFLAG_ASSISTERREVENGE)) )
			CCM_OnClassKillRevenge(victim.userid, killer.userid);

		if ( deathflags & TF_DEATHFLAG_DEADRINGER )
			CCM_OnClassKillDeadRinger(victim.userid, killer.userid);
		
		if ( deathflags & TF_DEATHFLAG_FIRSTBLOOD )
			CCM_OnClassKillFirstBlood(victim.userid, killer.userid);
	}
	if ( victim.bIsCustom ) {
		CCM_OnClassKilled(victim.userid, killer.userid);
		if ( deathflags & (TF_DEATHFLAG_KILLERDOMINATION|TF_DEATHFLAG_ASSISTERDOMINATION) )
			CCM_OnClassKilledDomination(victim.userid, killer.userid);

		if ( (deathflags & (TF_DEATHFLAG_KILLERREVENGE|TF_DEATHFLAG_ASSISTERREVENGE)) )
			CCM_OnClassKilledRevenge(victim.userid, killer.userid);
		
		if ( deathflags & TF_DEATHFLAG_DEADRINGER )
			CCM_OnClassKilledDeadRinger(victim.userid, killer.userid);
		
		if ( deathflags & TF_DEATHFLAG_FIRSTBLOOD )
			CCM_OnClassKilledFirstBlood(victim.userid, killer.userid);
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
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	int medic = GetClientOfUserId(event.GetInt("userid"));
	int ubered = GetClientOfUserId(event.GetInt("targetid"));

	CustomClass doctor = CustomClass(medic);
	CustomClass patient = CustomClass(ubered);

	if ( patient.bIsCustom )
		CCM_OnClassUbered(patient.userid, doctor.userid);
	if ( doctor.bIsCustom )
		CCM_OnClassDeployUber(patient.userid, doctor.userid);

	return Plugin_Continue;
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	CustomClass player;
	for (int i=MaxClients ; i ; --i) {
		if (!IsValidClient(i, false))
			continue;

		player = CustomClass(i);
		if ( player.bIsCustom )
			CreateTimer(10.0, TimerEquipClass, player.userid);
	}
	return Plugin_Continue;
}
public Action TimerEquipClass(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client)) {
		CustomClass player = CustomClass(client);
		if (!player.bIsCustom)
			return Plugin_Continue;
		//TF2_RemoveAllWeapons(client);
		CCM_OnClassEquip(player.userid);
	}
	return Plugin_Continue;
}