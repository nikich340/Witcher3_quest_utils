// ----------------------------------------------------------------------------
quest function NTRDoorChangeState(tag : name, newState : string, optional keyItemName : name, optional removeKeyOnUse : bool, optional smoooth : bool, optional dontBlockInCombat : bool ) 
{
	switch(newState) {
			case "EDQS_Open":
				DoorChangeState(tag, EDQS_Open, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Close":
				DoorChangeState(tag, EDQS_Close, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Enable":
				DoorChangeState(tag, EDQS_Enable, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Disable":
				DoorChangeState(tag, EDQS_Disable, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_RemoveLock":
				DoorChangeState(tag, EDQS_RemoveLock, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Lock":
				DoorChangeState(tag, EDQS_Lock, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;			
	}
}
// ----------------------------------------------------------------------------

/* !!! - better use vanilla
PlayEffectQuest ( entityTag : name, effectName : name, activate : bool, persistentEffect : bool, deactivateAll : bool, preventEffectStacking : bool )
*/
/*quest function NTRPlayEffect( tag : name, effect : name ) 
{
	var NPCs : array <CNewNPC>;
	var i      : int;
	
	theGame.GetNPCsByTag(tag, NPCs);
	LogQuest( "NTR <<Play effect>>: tag: " + tag + " found npcs: " + NPCs.Size());	
	for (i = 0; i < NPCs.Size(); i += 1 )
	{	
		NPCs[i].PlayEffect(effect);
	}
}*/
// ----------------------------------------------------------------------------
quest function NTRPlayMusic( areaName : string, eventName : string, optional saveType : string ) 
{
	if ( areaName == "toussaint" )
		theSound.InitializeAreaMusic( (EAreaName)AN_Dlc_Bob );
	else
		theSound.InitializeAreaMusic( AreaNameToType(areaName) );

	switch (saveType) {
		case "SESB_Save":
			SoundEventQuest(eventName, SESB_Save);
			break;
		default:
			SoundEventQuest(eventName, SESB_ClearSaved);
			break;
	}
}
// -------------------------------------------------------------------------------
quest function NTRTuneNPC( tag : name, level : int, attitude : string, mortality : string )
{
	var NPCs   : array <CNewNPC>;
	var i      : int;
	
	theGame.GetNPCsByTag(tag, NPCs);
	// LogQuest( "<<Tune NPC>>> tag: " + tag + " found npcs: " + NPCs.Size());	- uncomment it to check if NPCs are found
	
	for (i = 0; i < NPCs.Size(); i += 1 )
	{	
		/* SET LEVEL */
		NPCs[i].SetLevel(level);
		NPCs[i].RemoveAbilityAll('NPCDoNotGainBoost');
		NPCs[i].RemoveAbilityAll('NPCLevelBonusDeadly');
		NPCs[i].RemoveAbilityAll('VesemirDamage');
		NPCs[i].RemoveAbilityAll('BurnIgnore');
		NPCs[i].RemoveAbilityAll('_q403Follower');
		//NPCs[i].RemoveAbilityAll('DisableFinishers'); - may be also useful
		
		/* SET ATTITUDE TO PLAYER */
		switch(attitude) {
			case "Friendly":
				NPCs[i].SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Friendly );
				thePlayer.SetAttitude( NPCs[i], AIA_Friendly );
				break;
			case "Hostile":
				NPCs[i].SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Hostile );
				thePlayer.SetAttitude( NPCs[i], AIA_Hostile );
				break;
			case "Neutral":
				NPCs[i].SetTemporaryAttitudeGroup( 'neutral_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Neutral );
				thePlayer.SetAttitude( NPCs[i], AIA_Neutral );
				break;
		}
		
		/* SET MORTALITY */
		switch(mortality) {
			case "None":
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_IsAttackableByPlayer );
				break;
			case "Unconscious":
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_IsAttackableByPlayer );
				break;
			case "Invulnerable":
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_IsAttackableByPlayer );
				break;
			case "Immortal":
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_IsAttackableByPlayer );
				break;
		}
	}
}