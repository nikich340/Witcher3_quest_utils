enum EInterpMethodType
{
    	IMT_UseNewAutoTangents,
    	IMT_UseFixedTangentEval,
    	IMT_UseBrokenTangentEval
};

enum EInterpCurveMode
{
    	CIM_Constant,
    	CIM_Linear,
    	CIM_CurveAuto,
    	CIM_CurveBreak,
    
};

enum ECompareOp
{
    	CO_Lesser,
    	CO_LesserEq,
    	CO_Greater,
    	CO_GreaterEq,
    	CO_Equal,
    	CO_NotEqual
};

enum ESpaceFillMode
{
    	ESFM_JustifyLeft,
    	ESFM_JustifyRight
};

enum EComboAttackResponse
{
    	CAR_HitFront,
    	CAR_HitBack,
    	CAR_ParryFront,
    	CAR_ParryBack,
    
};

enum ECameraState
{
    	CS_Exploration,
    	CS_Combat,
    	CS_FocusModeNC,
    	CS_FocusModeCombat,
    	CS_AimThrow,
    	CS_Horse,
    	CS_Boat,
    
};

enum ECameraShakeState
{
    	CSS_Normal,
    	CSS_Drunk,
    	CSS_Elevator
};

enum ECameraShakeMagnitude
{
    	CSM_0	=	0,
    	CSM_1	=	1,
    	CSM_2	=	2,
    	CSM_3	=	3,
    	CSM_4	=	4,
    	CSM_5	=	5
};

enum EDismembermentEffectTypeFlags
{
    	DETF_Base		= 1,
    	DETF_Igni		= 2,
    	DETF_Aaard		= 4,
    	DETF_Yrden		= 8,
    	DETF_Quen		= 16,
    	DETF_Mutation6	= 32,
    
};

enum ETriggerChannels
{
    	TC_Default			= 1,
    	TC_Player			= 2,
    	TC_Camera			= 4,
    	TC_NPC				= 8,
    	TC_SoundReverbArea	= 16,
    	TC_SoundAmbientArea	= 32,
    	TC_Quest			= 64,
    	TC_Projectiles		= 128,
    	TC_Horse			= 256,
    	TC_Custom0			= 65536,
    	TC_Custom1			= 131072,
    	TC_Custom2			= 262144,
    	TC_Custom3			= 524288,
    	TC_Custom4			= 1048576,
    	TC_Custom5			= 2097152,
    	TC_Custom6			= 4194304,
    	TC_Custom7			= 8388608,
    	TC_Custom8			= 16777216,
    	TC_Custom9			= 33554432,
    	TC_Custom10			= 67108864,
    	TC_Custom11			= 134217728,
    	TC_Custom12			= 268435456,
    	TC_Custom13			= 536870912,
    	TC_Custom14			= 1073741824,
    
};

enum EDayPart
{
    	EDP_Undefined,
    	EDP_Dawn,
    	EDP_Noon,
    	EDP_Dusk,
    	EDP_Midnight
};

enum EGameplayMimicMode
{
    	GMM_Default,
    	GMM_Combat,
    	GMM_Work,
    	GMM_Death,
    	PGMM_Sleep,
    	GMM_Tpose
};

enum EPlayerGameplayMimicMode
{
    	PGMM_None,
    	PGMM_Default,
    	PGMM_Combat,
    	PGMM_Inventory,
    
};

enum ESoundGameState
{
    	ESGS_Default,
    	ESGS_Exploration,
    	ESGS_ExplorationNight,
    	ESGS_Focus,
    	ESGS_FocusNight,
    	ESGS_FocusUnderwater,
    	ESGS_Combat,
    	ESGS_CombatMonsterHunt,
    	ESGS_Dialog,
    	ESGS_DialogNight,
    	ESGS_Cutscene,
    	ESGS_Minigame,
    	ESGS_Death,
    	ESGS_Movie,
    	ESGS_Boat,
    	ESGS_MusicOnly,
    	ESGS_Underwater,
    	ESGS_UnderwaterCombat,
    	ESGS_Paused,
    	ESGS_Gwent,
    	ESGS_FocusUnderwaterCombat,
    
};

enum ESoundEventSaveBehavior
{
    	SESB_Save,
    	SESB_DontSave,
    	SESB_ClearSaved
};

enum EStaticCameraAnimState
{
    	SCAS_Default,
    	SCAS_Collapsed,
    	SCAS_Window,
    	SCAS_ShakeTower,
    
};

enum EStaticCameraGuiEffect
{
    	SCGE_None = 0,
    	SCGE_Hole,
    
};

enum is not a custom camera!!!" );		else		
{
    cachedHeal,
    hudModuleHealScheduledUpdate,
    cachedDoTDamage,
    hudModuleDoTScheduledUpdate
};

enum ECharacterPowerStats
{
    	CPS_AttackPower,
    	CPS_SpellPower,
    	CPS_Undefined
};

enum ECharacterRegenStats
{
    	CRS_Undefined,
    	CRS_Vitality,
    	CRS_Essence,
    	CRS_Morale,
    	CRS_UNUSED,
    	CRS_Stamina,
    	CRS_Air,
    	CRS_Panic,
    	CRS_SwimmingStamina,
    
};

enum EDirection
{
    	D_Front,
    	D_Right,
    	D_Back,
    	D_Left,
    	D_Front_60deg,
    	D_Front_30deg
};

enum EDirectionZ
{
    	DZ_Undefined,
    	DZ_Up,
    	DZ_Down,
    	DZ_Left,
    	DZ_Right
};

enum EMoonState
{
    	EMS_NotFull,
    	EMS_Full,
    	EMS_Red,
    	EMS_Any
};

enum EWeatherEffect
{
    	EWE_Clear,
    	EWE_Rain,
    	EWE_Snow,
    	EWE_Storm,
    	EWE_None,
    	EWE_Any
};

enum EScriptedEventCategory
{
    	SEC_Empty,
    	SEC_OnReusableClueUsed,
    	SEC_OnItemEquipped,
    	SEC_OnOilApplied,
    	SEC_OnAmmoChanged,
    	SEC_GameplayFact,
    	SEC_AlchemyRecipe,
    	SEC_CraftingSchematics,
    	SEC_OnMapPinChanged,
    	SEC_OnHudTimeOut,
    
};

enum EScriptedEventType
{
    	SET_Unknown,
    
};

enum EInputDeviceType
{
    	IDT_Xbox1 = 0,
    	IDT_PS4 = 1,
    	IDT_Steam = 2,
    	IDT_KeyboardMouse = 3,
    	IDT_Tablet = 4,
    	IDT_Unknown = 5
};

enum Platform
{
    	Platform_PC = 0,
    	Platform_Xbox1 = 1,
    	Platform_PS4 = 2,
    	Platform_Unknown = 3
};

enum EncumbranceBoyMode
{
    	EBM_Swap,
    	EBM_On,
    	EBM_Off
};

enum EActorImmortalityMode
{
    	AIM_None,
    	AIM_Immortal,
    	AIM_Invulnerable,
    	AIM_Unconscious
};

enum EActorImmortalityChanel
{
    	AIC_Default = 1,
    	AIC_Combat = 2,
    	AIC_Scene = 4,
    	AIC_Mutation11 = 8,
    	AIC_Fistfight = 16,
    	AIC_SyncedAnim = 32,
    	AIC_WhiteRaffardsPotion = 64,
    	AIC_IsAttackableByPlayer = 128
};

enum ETerrainType
{
    	TT_Normal,
    	TT_Rough,
    	TT_Swamp,
    	TT_Water
};

enum EAreaName
{
    	AN_Undefined,
    	AN_NMLandNovigrad,
    	AN_Skellige_ArdSkellig,
    	AN_Kaer_Morhen,
    	AN_Prologue_Village,
    	AN_Wyzima,
    	AN_Island_of_Myst,
    	AN_Spiral,
    	AN_Prologue_Village_Winter,
    	AN_Velen,
    	AN_CombatTestLevel,
    
};

enum EDlcAreaName
{
    	AN_Dlc_Bob = 11,
    
};

enum EZoneName
{
    	ZN_Undefined,
    	ZN_NML_CrowPerch,
    	ZN_NML_SpitfireBluff,
    	ZN_NML_TheMire,
    	ZN_NML_Mudplough,
    	ZN_NML_Grayrocks,
    	ZN_NML_TheDescent,
    	ZN_NML_CrookbackBog,
    	ZN_NML_BaldMountain,
    	ZN_NML_Novigrad,
    	ZN_NML_Homestead,
    	ZN_NML_Gustfields,
    	ZN_NML_Oxenfurt,
    
};

enum EHitReactionType
{
    	EHRT_None,
    	EHRT_Light,
    	EHRT_Heavy,
    	EHRT_Igni,
    	EHRT_Reflect,
    	EHRT_LightClose
};

enum EFocusHitReaction
{
    	EFHR_None,
    	EFHR_Type1,
    	EFHR_Type2,
    	EFHR_Type3,
    	EFHR_Type4,
    	EFHR_Type5
};

enum EAttackSwingType
{
    	AST_Horizontal,
    	AST_Vertical,
    	AST_DiagonalUp,
    	AST_DiagonalDown,
    	AST_Jab,
    	AST_NotSet
};

enum EAttackSwingDirection
{
    	ASD_UpDown,
    	ASD_DownUp,
    	ASD_LeftRight,
    	ASD_RightLeft,
    	ASD_NotSet
};

enum EManageGravity
{
    	EMG_DisableGravity,
    	EMG_EnableGravity,
    	EMG_SwitchGravity
};

enum ECounterAttackSwitch
{
    	CAS_Disabled,
    	CAS_Enabled
};

enum EAttitudeGroupPriority
{
    	AGP_Default,
    	AGP_SpawnTree,
    	AGP_Axii,
    	AGP_Fistfight,
    	AGP_Scenes
};

enum ETimescaleSource
{
    	ETS_None,
    	ETS_PotionBlizzard,
    	ETS_SlowMoTask,
    	ETS_HeavyAttack,
    	ETS_ThrowingAim,
    	ETS_RadialMenu,
    	ETS_CFM_PlayAnim,
    	ETS_CFM_On,
    	ETS_DebugInput,
    	ETS_SkillFrenzy,
    	ETS_RaceSlowMo,
    	ETS_HorseMelee,
    	ETS_FinisherInput,
    	ETS_TutorialFight,
    	ETS_InstantKill
};

enum EMonsterCategory
{
    	MC_NotSet,
    	MC_Relic,
    	MC_Necrophage,
    	MC_Cursed,
    	MC_Beast,
    	MC_Insectoid,
    	MC_Vampire,
    	MC_Specter,
    	MC_Draconide,
    	MC_Hybrid,
    	MC_Troll,
    	MC_Human,
    MC_Unused,
    	MC_Magicals,
    	MC_Animal
};

enum EButtonStage
{
    	BS_Released,
    	BS_Pressed,
    	BS_Hold,
    
};

enum EStaminaActionType
{
    	ESAT_Undefined,
    	ESAT_LightAttack,
    	ESAT_HeavyAttack,
    	ESAT_SuperHeavyAttack,
    	ESAT_Parry,
    	ESAT_Counterattack,
    	ESAT_Dodge,
    	ESAT_Evade,
    	ESAT_Swimming,
    	ESAT_Sprint,
    	ESAT_Jump,
    	ESAT_UsableItem,
    	ESAT_Ability,
    	ESAT_FixedValue,
    	ESAT_Roll,
    	ESAT_LightSpecial,
    	ESAT_HeavySpecial,
    
};

enum EFocusModeSoundEffectType
{
    	FMSET_Gray,
    	FMSET_Red,
    	FMSET_Green,
    	FMSET_None,
    
};

enum EStatistic
{
    	ES_Undefined,
    	ES_BleedingBurnedPoisoned,
    	ES_FinesseKills,
    	ES_CharmedNPCKills,
    	ES_AardFallKills,
    	ES_EnvironmentKills,
    	ES_CounterattackChain,
    	ES_DragonsDreamTriggers,
    	ES_FundamentalsFirstKills,
    	ES_DestroyedNests,
    	ES_KnownPotionRecipes,
    	ES_KnownBombRecipes,
    	ES_ReadBooks,
    	ES_HeadShotKills,
    	ES_SelfArrowKills,
    	ES_ActivePotions,
    	ES_KilledCows,
    	ES_SlideTime
};

enum EAchievement
{
    	EA_Undefined,
    	EA_FoundYennefer,
    	EA_FreedDandelion,
    	EA_YenGetInfoAboutCiri,
    	EA_FindBaronsFamily,
    	EA_FindCiri,
    	EA_ConvinceGeelsToBetrayEredin,
    	EA_DefeatEredin,
    	EA_FinishTheGameEasy,
    	EA_FinishTheGameNormal,
    	EA_FinishTheGameHard,
    	EA_CompleteWitcherContracts,
    	EA_CompleteSkelligeRaceForCrown,
    	EA_CompleteWar,
    	EA_CompleteKeiraMetz,
    	EA_GetAllForKaerMorhenBattle,
    	EA_Dendrology,
    	EA_EnemyOfMyFriend,
    	EA_FusSthSth,
    	EA_EnvironmentUnfriendly,
    	EA_TrainedInKaerMorhen,
    	EA_TheEvilestThing,
    	EA_TechnoProgress,
    	EA_LearningTheRopes,
    	EA_FundamentalsFirst,
    	EA_TrialOfGrasses,
    	EA_BreakingBad,
    	EA_Bombardier,
    	EA_Swank,
    	EA_Rage,
    	EA_GwintMaster,
    EA_Unused,
    	EA_MonsterHuntFogling,
    	EA_MonsterHuntEkimma,
    	EA_MonsterHuntLamia,
    	EA_MonsterHuntFiend,
    	EA_MonsterHuntDao,
    	EA_MonsterHuntDoppler,
    	EA_BrawlMaster,
    	EA_NeedForSpeed,
    	EA_Brawler,
    	EA_Finesse,
    	EA_PowerOverwhelming,
    	EA_Cerberus,
    	EA_Bookworm,
    	EA_Immortal,
    	EA_FistOfTheSouthStar,
    	EA_Explorer,
    	EA_PestControl,
    	EA_FireInTheHole,
    	EA_FullyArmed,
    	EA_GwintCollector,
    	EA_Allin,
    	EA_GeraltandFriends,
    	EA_ToadPrince,
    	EA_PartyAnimal,
    	EA_Auctioneer,
    	EA_TheCompletePicture,
    	EA_HeartsOfStone,
    	EA_KillEtherals,
    	EA_FeatherStrongerThanSword,
    	EA_Thirst,
    	EA_DivineWhip,
    	EA_LatestFashion,
    	EA_WantedDeadOrBovine,
    	EA_Slide,
    	EA_KilledIt,
    	EA_BeauclairWelcomeTo,
    	EA_HeroOfBeauclair,
    	EA_BeauclairMostWanted,
    	EA_ChampionOfBeauclair,
    	EA_LikeAVirgin,
    	EA_HomeSweetHome,
    	EA_TurnedEveryStone,
    	EA_GotToHaveThemAll,
    	EA_BloodAndWine,
    	EA_ReadyToRoll,
    	EA_SchoolOfTheMutant,
    	EA_HastaLaVista,
    	EA_Goliath
};

enum ETutorialHintDurationType
{
    	ETHDT_NotSet,
    	ETHDT_Short,
    	ETHDT_Long,
    	ETHDT_Infinite,
    	ETHDT_Custom,
    	ETHDT_Input
};

enum ETutorialHintPositionType
{
    	ETHPT_DefaultGlobal,
    	ETHPT_DefaultDialog,
    	ETHPT_DefaultCombat,
    	ETHPT_Custom,
    	ETHPT_DefaultUI,
    	ETHPT_DefaultRadialMenu
};

enum ESpeedType
{
    	EST_Undefined,
    	EST_Stopped,
    	EST_SlowWalk,
    	EST_Walk,
    	EST_Run,
    	EST_FastRun,
    	EST_Sprint
};

enum EBloodType
{
    	BT_Undefined,
    	BT_Red,
    	BT_Yellow,
    	BT_Black,
    	BT_Green
};

enum EStatOwner
{
    	SO_NPC,
    	SO_Target,
    	SO_ActionTarget
};

enum ETestSubject
{
    	ETS_Player,
    	ETS_Owner
};

enum ETargetName
{
    	TN_Me,
    	TN_CombatTarget,
    	TN_ActionTarget,
    	TN_CustomTarget,
    	TN_NamedTarget
};

enum EMonsterTactic
{
    	EMT_None,
    	EMT_FarSurround
};

enum EOperator
{
    	EO_Equal,
    	EO_NotEqual,
    	EO_Less,
    	EO_LessEqual,
    	EO_Greater,
    	EO_GreaterEqual,
    
};

enum ESpawnPositionPattern
{
    	ESPP_AroundTarget,
    	ESPP_AroundSpawner,
    	ESPP_AroundBoth
};

enum ESpawnRotation
{
    	ESR_BackAtSpawner,
    	ESR_TowardsSpawner,
    	ESR_TowardsTarget,
    	ESR_SameAsSpawner,
    	ESR_OppositeOfSpawner
};

enum EFlyingCheck
{
    	EFC_TakeOff,
    	EFC_Landing,
    
};

enum ECriticalEffectCounterType
{
    	CECT_Human,
    	CECT_NonHuman,
    	CECT_Undefined
};

enum EFairytaleWitchAction
{
    	EFWA_GoBackToFlight
};

enum EActionInfoType
{
    	EAIT_ApproachAttack,
    	EAIT_ApproachAttackEnd,
    	EAIT_Attack,
    	EAIT_AttackEnd,
    	EAIT_BecomeAwareAndCanAttack,
    	EAIT_BecomeUnawareOrCannotAttack,
    	EAIT_BeingWarnedStart,
    	EAIT_BeingWarnedStop,
    	EAIT_CanFindPath,
    	EAIT_CannotFindPath,
    
};

enum EBossAction
{
    	EBA_Parry,
    	EBA_Siphon,
    	EBA_Dodge,
    	EBA_StaminaRegen,
    	EBA_PhaseChange
};

enum EBossSpecialAttacks
{
    	EBSA_Lightbringer,
    	EBSA_Meteorites,
    	EBSA_IceSpikes,
    	EBSA_BlinkCombo,
    	EBSA_SpecialAttacks
};

enum EEredinPhaseChangeAction
{
    	EEPCA_PreparePartOne,
    	EEPCA_PartOne,
    	EEPCA_PreparePartTwo,
    	EEPCA_PartTwo,
    	EEPCA_AdjustRotation
};

enum ESpawnCondition
{
    	SC_Always,
    	SC_PlayerInRange,
    
};

enum ENPCCollisionStance
{
    	NCS_InPlace		,
    	NCS_PushGentle	,
    	NCS_Push		,
    	NCS_PushHard	,
    
};

enum ENPCBaseType
{
    	ENBT_Man	,
    	ENBT_Woman	,
    	ENBT_Dwarf	,
    
};

enum EGuardState
{
    	GS_Idle,
    	GS_Chase,
    	GS_Retreat,
    
};

enum ENPCType
{
    	ENT_AdultMale,
    	ENT_AdultFemale,
    	ENT_ChildMale,
    	ENT_ChildFemale
};

enum EChosenTarget
{
    	ECT_CombatTarget,
    	ECT_AlwaysPlayer,
    	ECT_Self,
    	ECT_SpecifiedTag
};

enum ETeleportType
{
    	TT_ToPlayer,
    	TT_ToTarget,
    	TT_AwayFromTarget,
    	TT_FromLastPosition,
    	TT_Random,
    	TT_ToSelf,
    	TT_ToNode,
    	TT_OnRightPlayerSide,
    	TT_OnLeftPlayerSide,
    
};

enum ECameraAnimPriority
{
    	CAP_Lowest,
    	CAP_Low,
    	CAP_Normal,
    	CAP_High,
    	CAP_Highest
};

enum ECameraBlendSpeedMode
{
    	ECBSM_Time		= 0,
    	ECBSM_Distance	= 1,
    	ECBSM_Height	= 2,
    
};

enum EMerchantMapPinType
{
    	EMMPT_Shopkeeper,
    	EMMPT_Blacksmith,
    	EMMPT_Armorer,
    	EMMPT_BoatBuilder,
    	EMMPT_Hairdresser,
    	EMMPT_Herbalist,
    	EMMPT_Alchemist,
    	EMMPT_Innkeeper,
    	EMMPT_Enchanter,
    	EMMPT_DyeTrader,
    	EMMPT_WineTrader,
    	EMMPT_Cammerlengo
};

enum EScriptedDetroyableComponentState
{
    	DC_Idle,
    	DC_PreDestroy,
    	DC_Destroy,
    	DC_PostDestroy
};

enum EFoodGroup
{
    	FG_Corpse 		= 1,
    	FG_Meat			= 2,
    	FG_Vegetable	= 4,
    	FG_Water		= 8,
    	FG_Monster		= 16
};

enum EClimbProbeUsed
{
    	ECPU_None	,
    	ECPU_Top	,
    	ECPU_Bottom	,
    
};

enum ESideSelected
{
    	SS_SelectedNone		,
    	SS_SelectedLeft		,
    	SS_SelectedRight	,
    	SS_SelectedCenter	,
    
};

enum EPlayerCollisionStance
{
    	GCS_Idle	,
    	GCS_Walk	,
    	GCS_Run		,
    	GCS_Sprint	,
    	GCS_Combat	,
    
};

enum EMovementCorrectionType
{
    	EMCT_None			= 0	,
    	EMCT_Collision			,
    	EMCT_Push				,
    	EMCT_Physics			,
    	EMCT_NavMesh			,
    	EMCT_Exploration		,
    	EMCT_Door				,
    	EMCT_Fall				,
    	EMCT_Size				,
    
};

enum EGameplayContextInput
{
    	EGCI_Ignore			,
    	EGCI_Exploration	,
    	EGCI_JumpClimb		,
    	EGCI_Combat			,
    	EGCI_Swimming		,
    
};

enum EExplorationStateType
{
    	EST_None		,
    	EST_Idle		,
    	EST_OnAir		,
    	EST_Swim		,
    	EST_Skate		,
    	EST_Critical	,
    	EST_Locked		,
    	EST_Unchanged	,
    
};

enum EBehGraphConfirmationState
{
    	BGCS_None			,
    	BGCS_Waiting		,
    	BGCS_Confirmed		,
    	BGCS_NotConfirmed	,
    
};

enum EAirCollisionSide
{
    	EACS_Left	= 0,
    	EACS_Center	= 1,
    	EACS_Right	= 2,
    
};

enum EClimbRequirementType
{
    	ECRT_Landed			= 0,
    	ECRT_Jumping		= 1,
    	ECRT_AirColliding	= 2,
    	ECRT_Swimming		= 3,
    	ECRT_Running		= 4,
    
};

enum EClimbRequirementVault
{
    	ECRV_NoVault	= 0,
    	ECRV_Vault		= 1,
    
};

enum EClimbRequirementPlatform
{
    	ECRV_NoPlatform	= 0,
    	ECRV_Platform	= 1,
    
};

enum EClimbHeightType
{
    	ECHT_Step		= 0,
    	ECHT_VerySmall	= 1,
    	ECHT_Small		= 2,
    	ECHT_Medium		= 3,
    	ECHT_High		= 4,
    	ECHT_VeryHigh	= 5,
    
};

enum EClimbDistanceType
{
    	ECDT_Normal	= 0,
    	ECDT_Close	= 1,
    	ECDT_Far	= 2,
    
};

enum EClimbEndReady
{
    	ECR_NotReady	= 0,
    	ECR_Walk		= 1,
    	ECR_Run			= 2,
    	ECR_Fall		= 3,
    	ECR_Idle		= 4,
    
};

enum EOutsideCapsuleState
{
    	EOCS_Inactive		= 0,
    	EOCS_Starting		= 1,
    	EOCS_PerfectFollow	= 2,
    	EOCS_Recover		= 3,
    
};

enum EPlayerIdleSubstate
{
    	PIS_None	,
    	PIS_Idle	,
    	PIS_Walk	,
    	PIS_Run		,
    	PIS_Sprint
};

enum ExplorationInteractionType
{
    	EIT_Ladder	= 0,
    	EIT_Boat	= 1,
    	EIT_Ledge	= 2,
    
};

enum EJumpSubState
{
    	JSS_TakingOff		,
    	JSS_Flight			,
    	JSS_Inertial		,
    	JSS_PredictingLand	,
    
};

enum EJumpType
{
    	EJT_Fall			= 0,
    	EJT_Idle			= 1,
    	EJT_IdleToWalk		= 2,
    	EJT_Walk			= 3,
    	EJT_WalkHigh		= 4,
    	EJT_Run				= 5,
    	EJT_Sprint			= 6,
    	EJT_Slide			= 7,
    	EJT_Hit				= 8,
    	EJT_Vault			= 9,
    	EJT_ToWater			= 10,
    	EJT_Skate			= 11,
    	EJT_KnockBack		= 12,
    	EJT_KnockBackFall	= 13,
    
};

enum ELandPredictionType
{
    	ELPT_FlatLand		= 0,
    	ELPT_SlopedLand		= 1,
    	ELPT_Water			= 2,
    
};

enum ELandType
{
    	LT_Death				= 0,
    	LT_Damaged				= 1,
    	LT_Crouch				= 2,
    	LT_Normal				= 3,
    	LT_Higher				= 4,
    	LT_Panther				= 5,
    	LT_KnockBack			= 6,
    	LT_FrontAircollision	= 7,
    
};

enum ELandRunForcedMode
{
    	LRFM_NotForced	= 0	,
    	LRFM_Idle		= 1	,
    	LRFM_Walk		= 2	,
    	LRFM_Run		= 3	,
    
};

enum PrepareJumpSubState
{
    	PJSS_Start	,
    	PJSS_Loop	,
    	PJSS_End	,
    
};

enum EPushSide
{
    	EPIS_Front	,
    	EPIS_Left	,
    	EPIS_Back	,
    	EPIS_Right	,
    
};

enum ESlidingSubState
{
    	SSS_Entering	= 0,
    	SSS_Sliding		= 1,
    	SSS_HardSliding	= 2,
    	SSS_Exiting		= 3,
    	SSS_Exited		= 4,
    
};

enum ESlideCameraShakeState
{
    	SCSS_None	,
    	SCSS_Soft	,
    	SCSS_Hard	,
    
};

enum EFallType
{
    	FT_Idle		,
    	FT_Walk		,
    	FT_Run		,
    	FT_Sprint	,
    
};

enum ECollisionTrajecoryStatus
{
    	CTS_AllClear		= 0 ,
    	CTS_LandLow			= 1 ,
    	CTS_LandOK			= 2 ,
    	CTS_LandHigh		= 3 ,
    	CTS_LandBlocked		= 4 ,
    
};

enum ECollisionTrajecoryExplorationStatus
{
    	CTES_None			,
    	CTES_Jump			,
    	CTES_Explore		,
    
};

enum ECollisionTrajectoryPart
{
    	ECTP_Start			,
    	ECTP_Up				,
    	ECTP_Peak			,
    	ECTP_Down			,
    	ECTP_Fall			,
    	ECTP_FallLow		,
    	ECTP_GroundClose	,
    	ECTP_GroundFar		,
    	ECTP_GroundFarAfter	,
    	ECTP_None			,
    
};

enum ECollisionTrajectoryToWaterState
{
    	ECTTWS_NoWater		,
    	ECTTWS_ToWaterClose	,
    	ECTTWS_ToWaterFar	,
    
};

enum EDoorMarkingState
{
    	EDMCT_Nothing		,
    	EDMCT_Considered	,
    	EDMCT_Selected		,
    
};

enum AQMTN_EntityType
{
    	AQMTN_Actor,
    	AQMTN_NonActor,
    
};

enum ESkillColor
{
    	SC_None,
    	SC_Blue,
    	SC_Green,
    	SC_Red,
    	SC_Yellow
};

enum ESkillPath
{
    	ESP_NotSet,
    	ESP_Sword,
    	ESP_Signs,
    	ESP_Alchemy,
    	ESP_Perks
};

enum ESkillSubPath
{
    	ESSP_NotSet,
    	ESSP_Sword_StyleStrong,
    	ESSP_Sword_StyleFast,
    	ESSP_Sword_Crossbow,
    	ESSP_Sword_Utility,
    	ESSP_Sword_BattleTrance,
    	ESSP_Sword_Offense,
    	ESSP_Sword_Defence,
    	ESSP_Sword_General,
    	ESSP_Signs_Aard,
    	ESSP_Signs_Igni,
    	ESSP_Signs_Yrden,
    	ESSP_Signs_Quen,
    	ESSP_Signs_Axi,
    	ESSP_Signs_Offense,
    	ESSP_Signs_Defence,
    	ESSP_Signs_General,
    	ESSP_Alchemy_Potions,
    	ESSP_Alchemy_Oils,
    	ESSP_Alchemy_Bombs,
    	ESSP_Alchemy_Mutagens,
    	ESSP_Alchemy_Grasses,
    	ESSP_Alchemy_Offense,
    	ESSP_Alchemy_Defence,
    	ESSP_Alchemy_General,
    	ESSP_Perks,
    	ESSP_Perks_col1,
    	ESSP_Perks_col2,
    	ESSP_Perks_col3,
    	ESSP_Perks_col4,
    	ESSP_Perks_col5,
    	ESSP_Core
};

enum EPlayerMutationType
{
    	EPMT_None,
    	EPMT_Mutation1,
    	EPMT_Mutation2,
    	EPMT_Mutation3,
    	EPMT_Mutation4,
    	EPMT_Mutation5,
    	EPMT_Mutation6,
    	EPMT_Mutation7,
    	EPMT_Mutation8,
    	EPMT_Mutation9,
    	EPMT_Mutation10,
    	EPMT_Mutation11,
    	EPMT_Mutation12,
    	EPMT_MutationMaster
};

enum EActionHitAnim
{
    	EAHA_Default,
    	EAHA_ForceYes,
    	EAHA_ForceNo
};

enum EAlchemyExceptions
{
    	EAE_NoException,
    	EAE_MissingIngredient,
    	EAE_NotEnoughIngredients,
    	EAE_NoRecipe,
    	EAE_CannotCookMore,
    	EAE_CookNotAllowed,
    	EAE_InCombat,
    	EAE_Mounted
};

enum EAlchemyCookedItemType
{
    	EACIT_Undefined,
    	EACIT_Potion,
    	EACIT_Bomb,
    	EACIT_Oil,
    EACIT_Substance,
    	EACIT_Bolt,
    	EACIT_MutagenPotion,
    	EACIT_Alcohol,
    	EACIT_Quest,
    	EACIT_Dye
};

enum EBirdType
{
    	Crow,
    	Pigeon,
    	Seagull,
    	Sparrow
};

enum EWhaleMovementPatern
{
    	EWMP_bySpawnPoint,
    	EWMP_towardsPlayer,
    	EWMP_awayFromPlayer
};

enum EJobTreeType
{
    	EJTT_NothingSpecial,
    	EJTT_Praying,
    	EJTT_InfantInHand,
    	EJTT_Sitting,
    	EJT_PlayingMusic,
    	EJTT_CatOnLap,
    
};

enum ECraftsmanType
{
    	ECT_Undefined,
    	ECT_Smith,
        ECT_Armorer,
        ECT_Crafter,
    	ECT_Enchanter
};

enum ECraftingException
{
    	ECE_NoException,
    	ECE_TooLowCraftsmanLevel,
    	ECE_MissingIngredient,
    	ECE_TooFewIngredients,
    	ECE_WrongCraftsmanType,
    	ECE_NotEnoughMoney,
    	ECE_UnknownSchematic,
    	ECE_CookNotAllowed
};

enum ECraftsmanLevel
{
    	ECL_Undefined,
    	ECL_Journeyman,
    	ECL_Master,
    	ECL_Grand_Master,
    	ECL_Arch_Master
};

enum EItemUpgradeException
{
    	EIUE_NoException,
    	EIUE_NotEnoughGold,
    	EIUE_MissingIngredient,
    	EIUE_NotEnoughIngredient,
    	EIUE_MissingRequiredUpgrades,
    	EIUE_AlreadyPurchased,
    	EIUE_ItemNotUpgradeable,
    	EIUE_NoSuchUpgradeForItem
};

enum EElevatorSwitchType
{
    	DownSwitch,
    	UpSwitch
};

enum ETrapOperation
{
    	TO_Activate,
    	TO_Deactivate,
    
};

enum EEffectInteract
{
    	EI_Undefined,
    	EI_Deny,
    	EI_Override,
    	EI_Pass,
    	EI_Cumulate
};

enum EEffectType
{
    	EET_Undefined,
    	EET_AutoVitalityRegen,
    	EET_AutoStaminaRegen,
    	EET_AutoEssenceRegen,
    	EET_AutoMoraleRegen,
    	EET_Confusion,
    	EET_HeavyKnockdown,
    	EET_Hypnotized,
    	EET_Immobilized,
    	EET_Knockdown,
    	EET_KnockdownTypeApplicator,
    	EET_Frozen,
    	EET_Paralyzed,
    	EET_Stagger,
    	EET_Blindness,
    	EET_PoisonCritical,
    	EET_Bleeding,
    	EET_BleedingTracking,
    	EET_Burning,
    	EET_Poison,
    	EET_DoTHPRegenReduce,
    	EET_Toxicity,
    	EET_BlackBlood,
    	EET_Blizzard,
    	EET_Cat,
    	EET_FullMoon,
    	EET_GoldenOriole,
    	EET_MariborForest,
    	EET_PetriPhiltre,
    	EET_Swallow,
    	EET_TawnyOwl,
    	EET_Thunderbolt,
    EET_Unused1,
    	EET_WhiteHoney,
    	EET_WhiteRaffardDecoction,
    	EET_KillerWhale,
    	EET_AxiiGuardMe,
    	EET_IgnorePain,
    	EET_StaggerAura,
    	EET_OverEncumbered,
    	EET_Edible,
    	EET_LowHealth,
    	EET_Slowdown,
    	EET_Fact,
    	EET_WellFed,
    	EET_SlowdownFrost,
    	EET_LongStagger,
    	EET_WellHydrated,
    	EET_BattleTrance,
    	EET_YrdenHealthDrain,
    	EET_AdrenalineDrain,
    	EET_WeatherBonus,
    	EET_Swarm,
    	EET_Pull,
    	EET_AbilityOnLowHealth,
    	EET_Oil,
    	EET_CounterStrikeHit,
    	EET_Drowning,
    	EET_Snowstorm,
    	EET_AutoAirRegen,
    	EET_ShrineAard,
    	EET_ShrineAxii,
    	EET_ShrineIgni,
    	EET_ShrineQuen,
    	EET_ShrineYrden,
    	EET_Ragdoll,
    	EET_AutoPanicRegen,
    	EET_VitalityDrain,
    	EET_DoppelgangerEssenceRegen,
    	EET_FireAura,
    	EET_BoostedEssenceRegen,
    	EET_AirDrain,
    	EET_SilverDust,
    	EET_Mutagen01,
    	EET_Mutagen02,
    	EET_Mutagen03,
    	EET_Mutagen04,
    	EET_Mutagen05,
    	EET_Mutagen06,
    	EET_Mutagen07,
    	EET_Mutagen08,
    	EET_Mutagen09,
    	EET_Mutagen10,
    	EET_Mutagen11,
    	EET_Mutagen12,
    	EET_Mutagen13,
    	EET_Mutagen14,
    	EET_Mutagen15,
    	EET_Mutagen16,
    	EET_Mutagen17,
    	EET_Mutagen18,
    	EET_Mutagen19,
    	EET_Mutagen20,
    	EET_Mutagen21,
    	EET_Mutagen22,
    	EET_Mutagen23,
    	EET_Mutagen24,
    	EET_Mutagen25,
    	EET_Mutagen26,
    	EET_Mutagen27,
    	EET_Mutagen28,
    	EET_AirDrainDive,
    	EET_BoostedStaminaRegen,
    	EET_WitchHypnotized,
    	EET_AirBoost,
    	EET_StaminaDrainSwimming,
    	EET_AutoSwimmingStaminaRegen,
    	EET_Drunkenness,
    	EET_WraithBlindness,
    	EET_Choking,
    	EET_StaminaDrain,
    	EET_EnhancedArmor,
    	EET_EnhancedWeapon,
    	EET_SnowstormQ403,
    	EET_SlowdownAxii,
    	EET_PheromoneNekker,
    	EET_PheromoneDrowner,
    	EET_PheromoneBear,
    	EET_Tornado,
    	EET_WolfHour,
    	EET_WeakeningAura,
    	EET_Weaken,
    	EET_Tangled,
    	EET_Runeword8,
    	EET_LynxSetBonus,
    	EET_GryphonSetBonus,
    	EET_GryphonSetBonusYrden,
    	EET_POIGorA10,
    	EET_Mutation7Buff,
    	EET_Mutation7Debuff,
    	EET_Mutation10,
    	EET_Perk21InternalCooldown,
    	EET_Mutation11Buff,
    	EET_Mutation11Debuff,
    	EET_Acid,
    	EET_WellRested,
    	EET_HorseStableBuff,
    	EET_BookshelfBuff,
    	EET_PolishedGenitals,
    	EET_Mutation12Cat,
    	EET_Mutation11Immortal,
    	EET_Aerondight,
    	EET_Trap,
    	EET_Mutation3,
    	EET_Mutation4,
    	EET_Mutation5,
    	EET_ToxicityVenom,
    	EET_BasicQuen,
    EET_EffectTypesSize,
    EET_ForceEnumTo16Bit = 10000
};

enum ECriticalHandling
{
    	ECH_HandleNow,
    	ECH_Postpone,
    	ECH_Abort
};

enum EEncounterMonitorCounterType
{
    	EMCT_KIlledByEntry,
    	EMCT_SpawnedByEntry,
    	EMCT_CurrentlySpawnedByEntry,
    	EMCT_LostByEntry,
    
};

enum EEncounterSpawnGroup
{
    	ESG_Quest,
    	ESG_Important,
    	ESG_CoreCommunity,
    	ESG_SecondaryCommunity,
    	ESG_OptionalCommunity,
    
};

enum EFocusModeChooseEntityStrategy
{
    	FMCES_ChooseNearest,
    	FMCES_ChooseMostIntense,
    
};

enum ETriggeredDamageType
{
    	ETDT_Roots,
    	ETDT_Poison
};

enum EIllusionDiscoveredOneliner
{
    	EIDO_PlayOnFirstDiscoveryInThisSession,
    	EIDO_PlayOnFirstDiscovery,
    	EIDO_PlayAlways,
    	EIDO_DontPlay
};

enum W3TableState	
{
    		TS_Clue,
    		TS_Table,
    	
};

enum EDoorOperation
{
    	DO_Open,
    	DO_Close,
    	DO_Toggle,
    	DO_Lock,
    	DO_Unlock,
    	DO_ToggleLock,
    
};

enum EMonsterNestType
{
    	EMNT_Regular,
    	EMNT_InfestedWineyard
};

enum ENestType
{
    	EN_Drowner,
    	EN_Draconid,
    	EN_Endriaga,
    	EN_Ghoul,
    	EN_Harpy,
    	EN_Nekker,
    	EN_Rotfiend,
    	EN_Siren,
    	EN_Wyvern,
    	EN_None,
    	EN_BlackSpider,
    	EN_Kikimora,
    	EN_Archespore,
    	EN_Scolopendromorph
};

enum ENewDoorOperation
{
    	NDO_Open,
    	NDO_Close,
    	NDO_Toggle,
    	NDO_Lock,
    	NDO_Unlock,
    	NDO_ToggleLock,
    
};

enum EShrineBuffs
{
    	ESB_Aard,
    	ESB_Axii,
    	ESB_Igni,
    	ESB_Quen,
    	ESB_Yrden
};

enum EToxicCloudOperation
{
    	TCO_Enable,
    	TCO_Disable
};

enum EOilBarrelOperation
{
    	OBO_Ignite,
    	OBO_Explode,
    
};

enum EArmorType
{
    	EAT_Undefined,
    	EAT_Light,
    	EAT_Medium,
    	EAT_Heavy
};

enum EEquipmentSlots
{
    	EES_InvalidSlot,
    	EES_SilverSword,
    	EES_SteelSword,
    	EES_Armor,
    	EES_Boots,
    	EES_Pants,
    	EES_Gloves,
    	EES_Petard1,
    	EES_Petard2,
    	EES_RangedWeapon,
    	EES_Quickslot1,
    	EES_Quickslot2,
    EES_Unused,
    	EES_Hair,
    	EES_Potion1,
    	EES_Potion2,
    	EES_Mask,
    	EES_Bolt,
    	EES_PotionMutagen1,
    	EES_PotionMutagen2,
    	EES_PotionMutagen3,
    	EES_PotionMutagen4,
    	EES_SkillMutagen1,
    	EES_SkillMutagen2,
    	EES_SkillMutagen3,
    	EES_SkillMutagen4,
    	EES_HorseBlinders,
    	EES_HorseSaddle,
    	EES_HorseBag,
    	EES_HorseTrophy,
    	EES_Potion3,
    	EES_Potion4
};

enum EItemGroup
{
    	EIG_PLAYER,
    	EIG_HORSE
};

enum EInventoryFilterType
{
    	IFT_None,
    	IFT_Weapons,
    	IFT_Armors,
    	IFT_AlchemyItems,
    	IFT_Ingredients,
    	IFT_QuestItems,
    	IFT_Default,
    	IFT_HorseItems,
    	IFT_Books,
    	IFT_AllExceptHorseItem
};

enum EInventoryActionType
{
    	IAT_None,
    	IAT_Equip,
    	IAT_UpgradeWeapon,
    	IAT_UpgradeWeaponSteel,
    	IAT_UpgradeWeaponSilver,
    	IAT_UpgradeArmor,
    	IAT_Consume,
    	IAT_Read,
    	IAT_Drop,
    	IAT_Transfer,
    	IAT_Sell,
    	IAT_Buy,
    	IAT_Repair,
    	IAT_Divide,
    	IAT_Socket
};

enum ECompareType
{
    	ECT_Incomparable,
    	ECT_Compare
};

enum ESpendablePointType
{
    	ESkillPoint,
    	EExperiencePoint
};

enum EEP2PoiType
{
    	EPT_Default,
    	EPT_Belgard,
    	EPT_Coronata,
    	EPT_Vermentino,
    
};

enum EPhysicalDamagemechanismOperation
{
    	EPDM_Activate,
    	EPDM_Deactivate,
    
};

enum ESwitchState
{
    	SS_Undefined,
    	SS_Off,
    	SS_SwitchingOn,
    	SS_On,
    	SS_SwitchingOff,
    
};

enum EResetSwitchMode
{
    	RSM_Default,
    	RSM_Current,
    	RSM_True,
    	RSM_False
};

enum PhysicalSwitchAnimationType
{
    	PSAT_Undefined,
    	PSAT_Lever,
    	PSAT_Button,
    
};

enum ERequiredSwitchState
{
    	ERSS_ON,
    	ERSS_OFF
};

enum EEncounterOperation
{
    	EO_Enable,
    	EO_Disable,
    	EO_Toggle
};

enum EFactOperation
{
    	FO_AddFact,
    	FO_RemoveFact
};

enum EOcurrenceTime
{
    	OT_AllDay,
    	OT_DayOnly,
    	OT_NightOnly,
    
};

enum ELogicalOperator
{
    	AND,
    	OR
};

enum EBoidClueState
{
    	BCS_Default,
    	BCS_Above
};

enum EMonsterCluesTypes
{
    	MCT_MonsterSize,
    	MCT_MonsterSound,
    	MCT_DamageMarks,
    	MCT_VictimState,
    	MCT_MonsterApperance,
    	MCT_SkinFacture,
    	MCT_MonsterMovement,
    	MCT_MonsterBehaviour,
    	MCT_MonsterAttitude,
    	MCT_AttackTime,
    	MCT_MonsterHideout
};

enum EMonsterSize
{
    	MS_Human,
    	MS_Giant,
    	MS_SmallHuman,
    	MS_BigHuman,
    	MS_Child,
    	MS_GiantSnake,
    	MS_Dog,
    	MS_Cart,
    	MS_Horse
};

enum EMonsterEmittedSound
{
    	MES_Growling,
    	MES_Mumbling,
    	MES_Hissing,
    	MES_Roaring,
    	MES_Shrieking,
    	MES_Yelling,
    	MES_Clattering,
    	MES_Murmuring,
    	MES_Sneering,
    	MES_Silent
};

enum EMonsterDamageMarks
{
    	DM_PoisonousBite,
    	DM_Bruises,
    	DM_FleshRips,
    	DM_SharpBites,
    	DM_BluntClaws,
    	DM_BluntBites,
    	DM_Claws,
    	DM_Crippled,
    	DM_Scaldings,
    	DM_RazorSharpCuts,
    	DM_BleachedHair,
    	DM_Frozen,
    	DM_BrokenBones,
    	DM_PiercedWounds,
    	DM_StrangleGrip,
    	DM_BlueTongue,
    	DM_StickyMucus,
    	DM_Drained
};

enum EMonsterVictimState
{
    	VS_PartiallyEaten,
    	VS_Drained,
    	VS_Drowned,
    	VS_TornApart,
    	VS_Swollen,
    	VS_Hemorrhaged,
    	VS_Beaten,
    	VS_Paralyzed,
    	VS_Buldgeoned,
    	VS_Burned,
    	VS_Suffocated,
    
};

enum EMonsterApperance
{
    	MAE_Muscular,
        MAE_GlowingEyes,
        MAE_Skinny,
        MAE_Stocky,
        MAE_Beautiful,
        MAE_Mandibles,
        MAE_SkinWings,
        MAE_Trinkets,
        MAE_Pieces_of_Armor,
        MAE_PowerfulJaws,
        MAE_Massive,
        MAE_Terrifying,
        MAE_Tentacles,
        MAE_BigMandibles,
        MAE_Hungering,
        MAE_LongTail,
        MAE_Owl_like
};

enum EMonsterSkinFacture
{
    	MSF_Callous,
        MSF_VeinySmooth,
        MSF_DirtyDecomposed,
        MSF_PaleOily,
        MSF_AlabasterPale,
        MSF_ScorchedEarth_like,
        MSF_Feathers,
        MSF_RuggedSkin,
        MSF_ShellSegments,
        MSF_Ethereal,
        MSF_Scales,
        MSF_Fur
};

enum EMonsterMovement
{
    	MM_FastWalk,
        MM_VeryFastRun,
        MM_SluggishWalk,
        MM_LightningFastRun,
        MM_Walk,
        MM_Flight,
        MM_Swim,
        MM_Crawl,
        MM_Float,
        MM_Jump,
        MM_Roll,
        MM_NoMovement
};

enum EMonsterBehaviour
{
    	MB_Lurking,
    	MB_Ambushing,
    	MB_Attracting,
    	MB_Wandering,
    	MB_Stalking
};

enum EMonsterAttitude
{
    	MA_Aggressive,
    	MA_Cunning,
    	MA_Careful,
    	MA_Vicious
};

enum EMonsterAttackTime
{
    	AT_AllDay,
    	AT_Day,
    	AT_AfterDark,
    	AT_Night
};

enum EMonsterHideout
{
    	MH_Crypt,
    	MH_Cave,
    	MH_UnderwaterCave,
    	MH_MountainCave,
    	MH_MountainCliff,
    	MH_RuinedBuilding,
    	MH_Forest,
    	MH_Underground,
    	MH_Catacombs,
    	MH_Ravine,
    	MH_Basement,
    	MH_Swamp,
    	MH_Glade
};

enum EFocusClueAttributeAction
{
    	FCAA_ForceSet,
    	FCAA_SetToTrue,
    	FCAA_SetToFalse,
    	FCAA_Switch,
    
};

enum EClueOperation
{
    	CO_Enable,
    	CO_Disable,
    	CO_None,
    
};

enum EFocusClueMedallionReaction
{
    	EFCMR_FirstDiscoveryInThisSession,
    	EFCMR_FirstDiscovery,
    	EFCMR_Always,
    	EFCMR_Never
};

enum EPlayerVoicesetType
{
    	EPVT_MonsterNestDrowners,
    	EPVT_MiscFreshTracks,
    	EPVT_MiscFollowingTracks,
    	EPVT_MiscBloodTrail,
    	EPVT_MiscInvestigateArea,
    	EPVT_MiscHideoutFound,
    	EPVT_MiscFindOtherWay,
    	EPVT_MiscAnotherVictim,
    	EPVT_MiscUnevenFight,
    	EPVT_MiscALotOfBlood,
    	EPVT_MiscGenericRemarks,
    	EPVT_About_trophy,
    	EPVT_FasterHorse,
    	EPVT_None,
    
};

enum EMonsterClueAnim
{
    	MCA_None,
    	MCA_SirenTreeKill,
    	MCA_WarriorDeath_01_quest,
    	MCA_WarriorDeath_02_quest,
    	MCA_WarriorDeath_03_quest,
    	MCA_WarriorDeath_quick_01_quest,
    	MCA_WarriorDeath_quick_02_quest,
    	MCA_WarriorDeath_quick_03_quest,
    	MCA_WarriorDeath_quick_04_quest,
    	MCA_WarriorDeath_quick_05_quest,
    	MCA_WarriorDeath_quick_06_quest,
    	MCA_WarriorDeath_quick_07_quest,
    	MCA_InjuredLeg_quest,
    	MCA_WomanWalking_quest,
    	MCA_ManWalking_quest,
    	MCA_Avallach_kill_Nithral_quest,
    	MCA_Nithral_pushed_back_quest,
    	MCA_Nithral_attack_quest,
    	MCA_Woman_being_hit_quest,
    	MCA_Avallach_surrounded_quest,
    	MCA_Ciri_surrounded_quest,
    	MCA_Wildhunt1_surrounded_quest,
    	MCA_Wildhunt2_surrounded_quest,
    	MCA_Wildhunt3_surrounded_quest,
    	MCA_Wildhunt4_surrounded_quest,
    	MCA_Wildhunt5_surrounded_quest,
    	MCA_Wildhunt6_surrounded_quest,
    	MCA_q106_step_back,
    	MCA_q106_standing_leaning,
    	MCA_q106_fall_kneel,
    	MCA_q106_devastated_attack,
    	MCA_q106_brush_floor,
    	MCA_q106_crawl
};

enum  the more precise player has to aim with the camera";	hint stopAnimSoundEvent = "Name of the sound event played on animation finished";	hint activatedByFact = "Name of the fact that activates clue";	saved var spawnPosWasSaved 				
{
    		super.OnSpawned( spawnData );		SetBehaviorVariable( 'MonsterAnimEnum'
};

enum EReputationLevel
{
    	RL_Hated,
    	RL_Disliked,
    	RL_Neutral,
    	RL_Liked,
    	RL_Respectable
};

enum EFactionName
{
    	FN_NoMansLandPoor = 0,
    	FN_NovigradNobles = 1,
    	FN_SkelligeUndvik = 2,
    	FN_MaxEnum = 3,
    
};

enum ETutorialMessageType
{
    	ETMT_Undefined,
    	ETMT_Hint,
    	ETMT_Message
};

enum EUITutorialTriggerCondition
{
    	EUITTC_OnMenuOpen
};

enum EUserDialogButtons
{
    	UDB_Ok,
    	UDB_OkCancel,
    	UDB_YesNo,
    	UDB_None
};

enum EUniqueMessageIDs
{
    	UMID_SignedOut = 666,
    	UMID_ControllerDisconnected = 789,
    	UMID_KinectMissing = 667,
    	UMID_QuitGameMessage = 69,
    	UMID_SigningInPleaseWait = 668,
    	UMID_UserSettingsCorrupted = 777,
    	UMID_CorruptedSaveDataOverwrite = 778,
    	UMID_LoadingFailed = 779,
    	UMID_SaveCompatWarning = 780,
    	UMID_MissingContentOnLoadError = 218793,
    	UMID_MissingContentOnDialogError = 129038,
    	UMID_LoadingFailedDamagedData = 865,
    	UMID_ForceManualSaveWindow = 129039,
    	UMID_GraphicsRefreshing = 9999,
    	UMID_QuestBlockMessage = 10,
    	UMID_NoFeedbackRequired,
    	UMID_SkipGwintTutorial = 11
};

enum ELockedControlScheme
{
    	LCS_None,
    	LCS_Gamepad,
    	LCS_KbMouse
};

enum EGamepadType
{
    	GT_Xbox,
    	GT_PS4,
    	GT_Steam
};

enum ECursorType
{
    	CT_None,
    	CT_Default,
    	CT_Rotate
};

enum EGuiSceneControllerRenderFocus
{
    	GSCRF_Body,
    	GSCRF_Head,
    	GSCRF_Torso,
    	GSCRF_Legs,
    	GSCRF_Max
};

enum EQuantityTransferFunction
{
    	QTF_Sell,
    	QTF_Buy,
    	QTF_Give,
    	QTF_Take,
    	QTF_Drop,
    	QTF_Dismantle,
    	QTF_MoveToStash
};

enum EHudVisibilitySource
{
    	HVS_System,
    	HVS_User,
    	HVS_Scene,
    	HVS_RadialMenu,
    
};

enum EFloatingValueType
{
    	EFVT_None,
    	EFVT_Critical,
    	EFVT_Block,
    	EFVT_InstantDeath,
    	EFVT_DoT,
    	EFVT_Heal,
    	EFVT_Buff
};

enum HudItemInfoBinding
{
    	HudItemInfoBinding_item1 = 0,
    	HudItemInfoBinding_potion1 = 1,
    	HudItemInfoBinding_potion2 = 2,
    	HudItemInfoBinding_potion3 = 3,
    	HudItemInfoBinding_potion4 = 4
};

enum EUpdateEventType
{
    	EUET_StartedTracking,
    	EUET_TrackedQuest,
    	EUET_TrackedQuestObjective,
    	EUET_TrackedQuestObjectiveCounter,
    	EUET_HighlightedQuestObjective,
    
};

enum EMutationFeedbackType
{
    	MFT_PlayHide,
    	MFT_PlayOnce,
    	MFT_PlayRepeat
};

enum InGameMenuActionType
{
    	IGMActionType_CommonMenu 		= 0,
    	IGMActionType_Close		 		= 1,
    	IGMActionType_MenuHolder 		= 2,
    	IGMActionType_MenuLastHolder	= 3,
    	IGMActionType_Load 				= 4,
    	IGMActionType_Save 				= 5,
    	IGMActionType_Quit			 	= 6,
    	IGMActionType_Preset 			= 7,
    	IGMActionType_Toggle 			= 8,
    	IGMActionType_List 				= 9,
    	IGMActionType_Slider 			= 10,
    	IGMActionType_LoadLastSave 		= 11,
    	IGMActionType_Tutorials 		= 12,
    	IGMActionType_Credits 			= 13,
    	IGMActionType_Help 				= 14,
    	IGMActionType_Controls 			= 15,
    	IGMActionType_ControllerHelp 	= 16,
    	IGMActionType_NewGame 			= 17,
    	IGMActionType_CloseGame 		= 18,
    	IGMActionType_UIRescale 		= 19,
    	IGMActionType_Gamma 			= 20,
    	IGMActionType_DebugStartQuest 	= 21,
    	IGMActionType_Gwint 			= 22,
    	IGMActionType_ImportSave 		= 23,
    	IGMActionType_KeyBinds 			= 24,
    	IGMActionType_Back				= 25,
    	IGMActionType_NewGamePlus		= 26,
    	IGMActionType_InstalledDLC		= 27,
    	IGMActionType_Options 			= 100
};

enum EIngameMenuConstants
{
    	IGMC_Difficulty_mask	= 	7,
    	IGMC_Tutorials_On		= 	1024,
    	IGMC_Simulate_Import 	= 	2048,
    	IGMC_Import_Save		= 	4096,
    	IGMC_EP1_Save			=   8192,
    	IGMC_New_game_plus		=   16384,
    	IGMC_EP2_Save			=   32768,
    
};

enum CreditsIndex
{
    	CreditsIndex_Wither3 = 0,
    	CreditsIndex_Ep1 = 1,
    	CreditsIndex_Ep2 = 2
};

enum CharacterMenuTabIndexes
{
    	CharacterMenuTab_Sword = 0,
    	CharacterMenuTab_Signs = 1,
    	CharacterMenuTab_Alchemy = 2,
    	CharacterMenuTab_Perks = 3,
    	CharacterMenuTab_Mutagens = 4
};

enum EMutationResourceType
{
    	MRT_SkillPoints,
    	MRT_GreenMutation,
    	MRT_RedMutation,
    	MRT_BlueMutation
};

enum EBonusSkillSlot
{
    	BSS_SkillSlot1 = 13,
    	BSS_SkillSlot2 = 14,
    	BSS_SkillSlot3 = 15,
    	BSS_SkillSlot4 = 16
};

enum EInventoryMenuState
{
    	IMS_Player,
    	IMS_Shop,
    	IMS_Container,
    	IMS_HorseInventory,
    	IMS_Stash
};

enum InventoryMenuTabIndexes
{
    	InventoryMenuTab_Weapons = 4,
    	InventoryMenuTab_Potions = 3,
    	InventoryMenuTab_Default = 2,
    	InventoryMenuTab_QuestItems = 1,
    	InventoryMenuTab_Ingredients = 0,
    	InventoryMenuTab_Books = 5
};

enum InventoryMenuStashTabIndexes
{
    	StashMenuTab_Weapons = 0,
    	StashMenuTab_Default = 1
};

enum ENotificationType
{
    	NT_Info,
    	NT_Warning
};

enum PreparationTrackType
{
    	PrepTrackType_None = 0,
    	PrepTrackType_Journal = 1,
    	PrepTrackType_Environment = 2
};

enum PreparationMenuTabIndexes
{
    	PreparationMenuTab_Bombs = 0,
    	PreparationMenuTab_Potion = 1,
    	PreparationMenuTab_Oils = 2,
    	PreparationMenuTab_Mutagens = 3
};

enum EItemSelectionPopupMode
{
    	EISPM_Default,
    	EISPM_ArmorStand,
    	EISPM_SwordStand,
    	EISPM_Painting,
    
};

enum EUserMessageAction
{
    	UMA_Ok,
    	UMA_Cancel,
    	UMA_Abort,
    	UMA_Yes,
    	UMA_No
};

enum EUserMessageProgressType
{
    	UMPT_None,
    	UMPT_Content,
    	UMPT_GraphicsRefresh
};

enum EPreporationItemType
{
    	PIT_Undefined,
    	PIT_Bomb,
    	PIT_Potion,
    	PIT_Oil,
    	PIT_Mutagen,
    
};

enum EBackgroundNPCWork_Single
{
    	EBNWS_None,
    	EBNWS_Brush,
    	EBNWS_Sit,
    	EBNWS_SitPipe,
    	EBNWS_Spyglass,
    	EBNWS_StandWall,
    	EBNWS_Tired,
    	EBNWS_WarmUp,
    	EBNWS_PlayingFlute,
    	EBNWS_SitSquat,
    	EBNWS_DrunkStandRope,
    	EBNWS_Crouch,
    	EBNWS_WriteList,
    	EBNWS_GuardStand,
    	EBNWS_Rowing,
    	EBNWS_StandTalk1,
    	EBNWS_StandTalk2,
    	EBNWS_StandTalk3,
    	EBNWS_SitDrink,
    	EBNWS_SitEat,
    	EBNWS_Kneel,
    	EBNWS_SitGroundHurt,
    	EBNWS_Scout,
    	EBNWS_Puke,
    	EBNWS_Sex,
    	EBNWS_Fishing
};

enum EBackgroundNPCWork_Paired
{
    	EBNWP_None,
    	EBNWP_DrinkingOpposite,
    	EBNWP_Saw,
    	EBNWP_Q106KilledbyMorowa
};

enum EBgNPCType
{
    	EBNPCT_None,
    	EBNPCT_Master,
    	EBNPCT_Slave
};

enum EBackgroundNPCWomanWork
{
    	EBNWW_None,
    	EBNWW_Listening,
    	EBNWW_Sweeping_floor,
    	EBNWW_Washing_cloth,
    	EBNWW_Brushing_floor_man,
    	EBNWW_Leaning_against_fence,
    	EBNWW_Sex
};

enum EConverserType
{
    	CT_General,
    	CT_Nobleman,
    	CT_Guard,
    	CT_Mage,
    	CT_Bandit,
    	CT_Scoiatael,
    	CT_Peasant,
    	CT_Poor,
    	CT_Child
};

enum EDeathType
{
    	EDT_Default,
    	EDT_IgniDeath,
    	EDT_AardDeath,
    	EDT_Agony
};

enum EFinisherDeathType
{
    	EFDT_None,
    	EFDT_Head,
    	EFDT_Torso,
    	EFDT_ArmLeft,
    	EFDT_ArmRight,
    	EFDT_LegLeft,
    	EFDT_LegRight,
    
};

enum EActionFail
{
    	EAF_ActionFail1,
    	EAF_ActionFail2,
    	EAF_ActionFail3,
    	EAF_ActionFail4,
    	EAF_ActionFail5,
    
};

enum ETauntType
{
    	TT_Taunt1,
    	TT_Taunt2,
    	TT_Taunt3,
    	TT_Taunt4,
    	TT_Taunt5,
    	TT_Taunt6,
    	TT_Taunt7,
    	TT_Taunt8,
    
};

enum EBehaviorGraph
{
    	EBG_None,
    	EBG_Combat_Undefined,
    	EBG_Combat_Shield,
    	EBG_Combat_1Handed_Sword,
    	EBG_Combat_1Handed_Axe,
    	EBG_Combat_1Handed_Blunt,
    	EBG_Combat_1Handed_Any,
    	EBG_Combat_2Handed_Any,
    	EBG_Combat_2Handed_Sword,
    	EBG_Combat_2Handed_Hammer,
    	EBG_Combat_2Handed_Axe,
    	EBG_Combat_2Handed_Halberd,
    	EBG_Combat_2Handed_Spear,
    	EBG_Combat_2Handed_Staff,
    	EBG_Combat_Fists,
    	EBG_Combat_Bow,
    	EBG_Combat_Crossbow,
    	EBG_Combat_Witcher,
    	EBG_Combat_Sorceress,
    	EBG_Combat_WildHunt_Imlerith,
    	EBG_Combat_WildHunt_Imlerith_Second_Stage,
    	EBG_Combat_WildHunt_Caranthir,
    	EBG_Combat_WildHunt_Caranthir_Second_Stage,
    	EBG_Combat_WildHunt_Eredin,
    	EBG_Combat_Olgierd,
    	EBG_Combat_Caretaker,
    	EBG_Combat_Dettlaff_Vampire,
    	EBG_Combat_Gregoire,
    	EBG_Combat_Dettlaff_Minion
};

enum EExplorationMode
{
    	EM_None,
    	EM_Ground,
    	EM_Air,
    	EM_Water,
    
};

enum EAgonyType
{
    	AT_ThroatCut,
    	AT_Knockdown
};

enum ENPCFightStage
{
    	NFS_Stage1,
    	NFS_Stage2,
    	NFS_Stage3,
    	NFS_Stage4,
    	NFS_Stage5
};

enum ECriticalStateType
{
    	ECST_BurnCritical,
    	ECST_HeavyKnockdown,
    	ECST_Knockdown,
    	ECST_LongStagger,
    	ECST_Stagger,
    	ECST_Hypnotized,
    	ECST_Confusion,
    	ECST_Blindness,
    	ECST_Paralyzed,
    	ECST_Immobilize,
    	ECST_CounterStrikeHit,
    	ECST_None,
    	ECST_Swarm,
    	ECST_Pull,
    	ECST_Ragdoll,
    	ECST_PoisonCritical,
    	ECST_Snowstorm,
    	ECST_Frozen,
    	ECST_Tornado,
    	ECST_Trap,
    
};

enum EHitReactionDirection
{
    	EHRD_Forward,
    	EHRD_Back
};

enum EHitReactionSide
{
    	EHRS_None,
    	EHRS_Left,
    	EHRS_Right,
    
};

enum EDetailedHitType
{
    	EDHT_None,
    	EDHT_Straight,
    	EDHT_RightLeft,
    	EDHT_LeftRight
};

enum EAttackType
{
    	EAT_Attack1,
    	EAT_Attack2,
    	EAT_Attack3,
    	EAT_Attack4,
    	EAT_Attack5,
    	EAT_Attack6,
    	EAT_Attack7,
    	EAT_Attack8,
    	EAT_Attack9,
    	EAT_Attack10,
    	EAT_Attack11,
    	EAT_Attack12,
    	EAT_Attack13,
    	EAT_Attack14,
    	EAT_Attack15,
    	EAT_Attack16,
    	EAT_Attack17,
    	EAT_Attack18,
    	EAT_Attack19,
    	EAT_Attack20,
    	EAT_None
};

enum EChargeAttackType
{
    	ECAT_Knockdown,
    	ECAT_Stagger
};

enum EDodgeType
{
    	EDT_Attack_Light,
    	EDT_Attack_Heavy,
    	EDT_Aard,
    	EDT_Igni,
    	EDT_Bomb,
    	EDT_Projectile,
    	EDT_Fear,
    	EDT_Undefined
};

enum EDodgeDirection
{
    	EDD_Back,
    	EDD_Left,
    	EDD_Right,
    	EDD_Forward
};

enum ETurnDirection
{
    	ETD_Left,
    	ETD_Right
};

enum ETargetDirection
{
    	ETD_Direction_0,
    	ETD_Direction_45,
    	ETD_Direction_90,
    	ETD_Direction_135,
    	ETD_Direction_180,
    	ETD_Direction_m180,
    	ETD_Direction_m135,
    	ETD_Direction_m90,
    	ETD_Direction_m45
};

enum ENpcPose
{
    	ENP_LeftFootFront,
    	ENP_RightFootFront
};

enum EFlightStance
{
    	EFS_VerticalTurns,
    	EFS_HorizontalTurns,
    	EFS_Glide,
    
};

enum ENPCRightItemType
{
    	RIT_None,
    	RIT_Axe,
    	RIT_Halberd,
    	RIT_Sword,
    	RIT_Torch,
    	RIT_Crossbow
};

enum ENPCLeftItemType
{
    	LIT_None,
    	LIT_Torch,
    	LIT_Shield,
    	LIT_Bow,
    
};

enum EInventoryFundsType
{
    	EInventoryFunds_Unlimited,
    	EInventoryFunds_Rich,
    	EInventoryFunds_Avg,
    	EInventoryFunds_Poor,
    	EInventoryFunds_RichQuickStart,
    	EInventoryFunds_Broke
};

enum EWeaponSubType1Handed
{
    	EWST1H_Sword,
    	EWST1H_Axe,
    	EWST1H_Blunt,
    
};

enum EWeaponSubType2Handed
{
    	EWST2H_Hammer,
    	EWST2H_Axe,
    	EWST2H_Halberd,
    	EWST2H_Spear,
    	EWST2H_Staff,
    
};

enum EWeaponSubTypeRanged
{
    	EWSTR_Bow,
    	EWSTR_Crossbow,
    
};

enum ENpcWeapons
{
    	ENW_1h_Sword			= 0x0001,
    	ENW_1h_Axe				= 0x0002,
    	ENW_1h_Mace				= 0x0004,
    	ENW_Shield				= 0x0008,
    	ENW_2h_Sword			= 0x0010,
    	ENW_2h_Axe				= 0x0020,
    	ENW_2h_Mace				= 0x0040,
    	ENW_2h_Bow				= 0x0080,
    	ENW_2h_Crossbow			= 0x0100,
    	ENW_2h_Halberd			= 0x0200,
    	ENW_2h_Spear			= 0x0400,
    
};

enum ENpcFightingStyles
{
    	ENFS_Sword 				= 0x0001,
    	ENFS_Mounted			= 0x0003,
    	ENFS_SwordAndShield 	= 0x0009,
    	ENFS_Axe				= 0x0002,
    	ENFS_AxeAndShield		= 0x000a,
    	ENFS_Mace				= 0x0004,
    	ENFS_MaceAndShield		= 0x000c,
    	ENFS_2h_Sword			= 0x0010,
    	ENFS_2h_Axe				= 0x0020,
    	ENFS_2h_Mace			= 0x0040,
    	ENFS_Bow				= 0x0080,
    	ENFS_Crossbow			= 0x0100,
    	ENFS_Halberd			= 0x0200,
    	ENFS_Spear				= 0x0400,
    	ENFS_Hjalmar			= 0x0800,
    
};

enum EAnimalType
{
    	EAT_NotSet,
    	EAT_Peacock,
    	EAT_Pheasant
};

enum EPlayerDeathType
{
    	PDT_Normal		= 0,
    	PDT_Fall		= 1,
    	PDT_KnockBack	= 2,
    
};

enum EAimType
{
    	AT_Bolt,
    	AT_Bomb,
    
};

enum EPlayerMode
{
    	PM_Normal,
    	PM_Safe,
    	PM_Combat,
    
};

enum EForceCombatModeReason
{
    	FCMR_Default    	= 1,
    	FCMR_Trigger   		= 2,
    	FCMR_QuestFunction  = 4,
    
};

enum EGeneralEnum
{
    	GE_0,
    	GE_1,
    	GE_2,
    	GE_3,
    	GE_4,
    	GE_5,
    	GE_6,
    	GE_7,
    	GE_8,
    	GE_9,
    	GE_10,
    
};

enum EPlayerExplorationAction
{
    	PEA_None,
    	PEA_SlotAnimation,
    	PEA_Meditation,
    	PEA_ExamineGround,
    	PEA_ExamineEyeLevel,
    	PEA_SmellHigh,
    	PEA_SmellMid,
    	PEA_SmellLow,
    	PEA_InspectHigh,
    	PEA_InspectMid,
    	PEA_InspectLow,
    	PEA_IgniLight,
    	PEA_AardLight,
    	PEA_SetBomb,
    	PEA_PourPotion,
    	PEA_DispelIllusion,
    	PEA_GoToSleep
};

enum EPlayerBoatMountFacing
{
    	EPBMD_NotSet,
    	EPBMD_Front,
    	EPBMD_Back,
    	EPBMD_Left,
    	EPBMD_Right
};

enum EPlayerAttackType
{
    	PAT_Light,
    	PAT_Heavy
};

enum ESkill
{
    	S_SUndefined,
    	S_Sword_1,
    	S_Sword_2,
    	S_Sword_3,
    	S_Sword_4,
    	S_Sword_5,
    	S_Magic_1,
    	S_Magic_2,
    	S_Magic_3,
    	S_Magic_4,
    	S_Magic_5,
    	S_Alchemy_1,
    	S_Alchemy_2,
    	S_Alchemy_3,
    	S_Alchemy_4,
    	S_Alchemy_5,
    	S_Sword_s01,
    	S_Sword_s02,
    	S_Sword_s03,
    	S_Sword_s04,
    	S_Sword_s05,
    	S_Sword_s06,
    	S_Sword_s07,
    	S_Sword_s08,
    	S_Sword_s09,
    	S_Sword_s10,
    	S_Sword_s11,
    	S_Sword_s12,
    	S_Sword_s13,
    S_UNUSED1,
    	S_Sword_s15,
    	S_Sword_s16,
    	S_Sword_s17,
    	S_Sword_s18,
    	S_Sword_s19,
    	S_Sword_s20,
    	S_Sword_s21,
    	S_Magic_s01,
    	S_Magic_s02,
    	S_Magic_s03,
    	S_Magic_s04,
    	S_Magic_s05,
    	S_Magic_s06,
    	S_Magic_s07,
    	S_Magic_s08,
    	S_Magic_s09,
    	S_Magic_s10,
    	S_Magic_s11,
    	S_Magic_s12,
    	S_Magic_s13,
    	S_Magic_s14,
    	S_Magic_s15,
    	S_Magic_s16,
    	S_Magic_s17,
    	S_Magic_s18,
    	S_Magic_s19,
    	S_Magic_s20,
    S_UNUSED2,
    	S_Alchemy_s01,
    	S_Alchemy_s02,
    	S_Alchemy_s03,
    	S_Alchemy_s04,
    	S_Alchemy_s05,
    	S_Alchemy_s06,
    	S_Alchemy_s07,
    	S_Alchemy_s08,
    	S_Alchemy_s09,
    	S_Alchemy_s10,
    	S_Alchemy_s11,
    	S_Alchemy_s12,
    	S_Alchemy_s13,
    	S_Alchemy_s14,
    	S_Alchemy_s15,
    	S_Alchemy_s16,
    	S_Alchemy_s17,
    	S_Alchemy_s18,
    	S_Alchemy_s19,
    	S_Alchemy_s20,
    	S_Skill_MAX,
    	S_Perk_MIN,
    	S_Perk_01,
    	S_Perk_02,
    	S_Perk_03,
    	S_Perk_04,
    	S_Perk_05,
    	S_Perk_06,
    	S_Perk_07,
    	S_Perk_08,
    	S_Perk_09,
    	S_Perk_10,
    	S_Perk_11,
    	S_Perk_12,
    	S_Perk_13,
    	S_Perk_14,
    	S_Perk_15,
    	S_Perk_16,
    	S_Perk_17,
    	S_Perk_18,
    	S_Perk_19,
    	S_Perk_20,
    	S_Perk_21,
    	S_Perk_22,
    	S_Perk_MAX
};

enum EItemSetBonus
{
    	EISB_Undefined,
    	EISB_Lynx_1,
    	EISB_Lynx_2,
    	EISB_Gryphon_1,
    	EISB_Gryphon_2,
    	EISB_Bear_1,
    	EISB_Bear_2,
    	EISB_Wolf_1,
    	EISB_Wolf_2,
    	EISB_RedWolf_1,
    	EISB_RedWolf_2,
    	EISB_Vampire
};

enum EItemSetType
{
    	EIST_Undefined,
    	EIST_Lynx,
    	EIST_Gryphon,
    	EIST_Bear,
    	EIST_Wolf,
    	EIST_RedWolf,
    	EIST_Vampire,
    	EIST_Viper
};

enum EPlayerCommentary
{
    	PC_MedalionWarning,
    	PC_MonsterReaction,
    	PC_NCFMClueCommentTrace,
    	PC_NCFMClueCommentRemainings,
    	PC_NCFMClueSoundDetected,
    	PC_ColdWaterComment,
    
};

enum EPlayerWeapon
{
    	PW_None,
    	PW_Steel,
    	PW_Silver,
    	PW_Fists
};

enum EPlayerRangedWeapon
{
    	PRW_None	,
    	PRW_Crossbow
};

enum EPlayerCombatStance
{
    	PCS_Normal,
    	PCS_AlertNear,
    	PCS_AlertFar,
    	PCS_Guarded
};

enum ESignType
{
    	ST_Aard,
    	ST_Yrden,
    	ST_Igni,
    	ST_Quen,
    	ST_Axii,
    	ST_None
};

enum EMoveSwitchDirection
{
    	MSD_SlowForwardLeft,
    	MSD_SlowForwardRight,
    	MSD_SlowBackLeft,
    	MSD_SlowBackRight,
    	MSD_FastForwardLeft,
    	MSD_FastForwardRight,
    	MSD_FastBackLeft,
    	MSD_FastBackRight,
    	MSD_None,
    
};

enum EPlayerEvadeType
{
    	PET_Roll,
    	PET_Dodge,
    	PET_Pirouette,
    
};

enum EPlayerEvadeDirection
{
    	PED_Forward,
    	PED_ForwardLeft,
    	PED_Left,
    	PED_LeftBack,
    	PED_Back,
    	PED_BackRight,
    	PED_Right,
    	PED_RightForward,
    
};

enum EPlayerParryDirection
{
    	PPD_Forward,
    	PPD_Left,
    	PPD_Back,
    	PPD_Right,
    
};

enum EPlayerRepelType
{
    	PRT_Random,
    	PRT_Bash,
    	PRT_Kick,
    	PRT_Slash,
    	PRT_SideStepSlash,
    	PRT_RepelToFinisher
};

enum ERotationRate
{
    	RR_0 		= 0,
    	RR_30 		= 30,
    	RR_60 		= 60,
    	RR_90 		= 90,
    	RR_180 		= 180,
    	RR_360 		= 360,
    	RR_1080 	= 1080,
    	RR_2160 	= 2160,
    
};

enum EItemType
{
    	IT_Petard,
    	IT_Bolt,
    
};

enum ESpecialAbilityInput
{
    	SAI_Up,
    	SAI_Down,
    	SAI_Left,
    	SAI_Right,
    
};

enum EThrowStage
{
    	TS_Start,
    	TS_Loop,
    	TS_End,
    	TS_Stop,
    
};

enum EParryStage
{
    	PS_Start,
    	PS_Loop,
    	PS_End,
    	PS_Stop,
    
};

enum EParryType
{
    	PT_Up,
    	PT_UpLeft,
    	PT_Left,
    	PT_LeftDown,
    	PT_Down,
    	PT_DownRight,
    	PT_Right,
    	PT_RightUp,
    	PT_Jab,
    	PT_None,
    
};

enum EAttackSwingRange
{
    	ASR_Short,
    	ASR_Normal,
    	ASR_Long,
    
};

enum EInputActionBlock
{
    	EIAB_Signs,
    	EIAB_DrawWeapon,
    	EIAB_OpenInventory,
    	EIAB_RadialMenu,
    	EIAB_CallHorse,
    	EIAB_FastTravel,
    	EIAB_Movement,
    	EIAB_HighlightObjective,
    	EIAB_Fists,
    	EIAB_OpenPreparation,
    	EIAB_Jump,
    	EIAB_Roll,
    	EIAB_InteractionAction,
    	EIAB_ThrowBomb,
    	EIAB_RunAndSprint,
    	EIAB_OpenMap,
    	EIAB_OpenCharacterPanel,
    	EIAB_OpenJournal,
    	EIAB_OpenAlchemy,
    	EIAB_ExplorationFocus,
    	EIAB_Dive,
    	EIAB_Interactions,
    	EIAB_DismountVehicle,
    	EIAB_Dodge,
    	EIAB_SwordAttack,
    	EIAB_Parry,
    	EIAB_Sprint,
    	EIAB_Explorations,
    	EIAB_Undefined,
    	EIAB_Counter,
    	EIAB_LightAttacks,
    	EIAB_HeavyAttacks,
    	EIAB_QuickSlots,
    	EIAB_Crossbow,
    	EIAB_UsableItem,
    	EIAB_OpenFastMenu,
    	EIAB_OpenGlossary,
    	EIAB_HardLock,
    	EIAB_Climb,
    	EIAB_Slide,
    	EIAB_OpenGwint,
    	EIAB_MeditationWaiting,
    	EIAB_MountVehicle,
    	EIAB_InteractionContainers,
    	EIAB_SpecialAttackLight,
    	EIAB_SpecialAttackHeavy,
    	EIAB_OpenMeditation,
    	EIAB_Noticeboards,
    	EIAB_FastTravelGlobal,
    	EIAB_CameraLock
};

enum EPlayerMoveType
{
    	PMT_Idle,
    	PMT_Walk,
    	PMT_Run,
    	PMT_Sprint,
    
};

enum EPlayerActionToRestore
{
    	PATR_Default,
    	PATR_Crossbow,
    	PATR_CastSign,
    	PATR_ThrowBomb,
    	PATR_CallHorse,
    	PATR_None
};

enum EPlayerInteractionLock
{
    	PIL_Cutscene = 1,
    	PIL_Default = 2,
    	PIL_CombatAction = 4,
    	PIL_Dialog = 8,
    	PIL_RadialMenu = 16,
    	PIL_Vehicle = 32
};

enum EPlayerPreviewInventory
{
    	PPI_default,
    	PPI_Bear_1,
    	PPI_Bear_4,
    	PPI_Lynx_1,
    	PPI_Lynx_4,
    	PPI_Gryphon_1,
    	PPI_Gryphon_4,
    	PPI_Common_1,
    	PPI_Naked,
    	PPI_Viper,
    	PPI_Red_Wolf_1
};

enum EDismembermentWoundTypes
{
    	DWT_Head,
    	DWT_Torso,
    	DWT_TorsoLeft,
    	DWT_TorsoRight,
    	DWT_ArmLeft,
    	DWT_ArmRight,
    	DWT_LegLeft,
    	DWT_LegRight,
    	DWT_Morph_Head,
    	DWT_Morph_Torso,
    	DWT_Morph_TorsoLeft,
    	DWT_Morph_TorsoRight,
    	DWT_Morph_ArmLeft,
    	DWT_Morph_ArmRight,
    	DWT_Morph_LegLeft,
    	DWT_Morph_LegRight,
    	DWT_DLC_Defined
};

enum ERecoilLevel
{
    	RL_1,
    	RL_2,
    	RL_3
};

enum EPlayerMovementLockType
{
    	PMLT_Free		,
    	PMLT_NoSprint	,
    	PMLT_NoRun		,
    
};

enum EHorseMode
{
    	EHM_NotSet,
    	EHM_Normal,
    	EHM_Devil,
    	EHM_Unicorn
};

enum ECustomCameraType
{
    	CCT_None,
    	CCT_CustomController,
    	CCT_RotatedToTarget_OverShoulder,
    	CCT_RotatedToTarget_Medium,
    
};

enum ECustomCameraController
{
    	CCC_NoTarget,
    	CCC_Target_Interior,
    	CCC_Target,
    
};

enum EInitialAction
{
    	IA_None,
    	IA_AttackLight,
    	IA_AttackHeavy,
    	IA_CastSign,
    	IA_ThrowItem,
    	IA_CriticalState,
    
};

enum EDir
{
    	Dir_L180,
    	Dir_L135,
    	Dir_L90,
    	Dir_L45,
    	Dir_F,
    	Dir_R45,
    	Dir_R90,
    	Dir_R135,
    	Dir_R180
};

enum EPlayerStopPose
{
    	EPS_LeftForward,
    	EPS_LeftUp,
    	EPS_RightForward,
    	EPS_RightUp
};

enum EVehicleCombatAction
{
    	EHCA_ShootCrossbow,
    	EHCA_ThrowBomb,
    	EHCA_CastSign,
    	EHCA_Attack
};

enum HorseAttackSide
{
    	HAS_Right,
    	HAS_Left
};

enum EBookDirection
{
    	BD_left,
    	BD_right
};

enum EQuestSword
{
    	EQS_Any,
    	EQS_Steel,
    	EQS_Silver
};

enum EFactValueChangeMethod
{
    	FVCM_Add,
    	FVCM_Substract,
    	FVCM_Multiply,
    	FVCM_Divide,
    
};

enum EMapPinStatus
{
    	EMPS_Undefined,
    	EMPS_Known,
    	EMPS_Discovered,
    	EMPS_Disabled
};

enum EFocusEffectActivationAction
{
    	FEAA_Enable,
    	FEAA_Disable,
    
};

enum ECameraEffect
{
        ECE_None,
        ECE_Drunk
};

enum EQuestReplacerEntities
{
    	EQRE_Geralt,
    	EQRE_Ciri,
    	EQRE_CiriNaked,
    	EQRE_CiriWounded,
    	EQRE_CiriWinter,
    
};

enum EItemSelectionType
{
    	IST_Equipped_Only,
    	IST_All
};

enum EQuestNPCStates
{
    	EQNS_Default,
    	EQNS_Dead,
    	EQNS_Agony,
    	EQNS_KnockedUnconscious,
    	EQNS_DeadNoAgony,
    	EQNS_DeadInstantRagdoll,
    	EQNS_Combat
};

enum EDrawWeaponQuestType
{
    	EDWQT_Steel,
    	EDWQT_Silver,
    	EDWQT_NoWeapon,
    	EDWQT_Fists
};

enum ESwarmStateOnArrival
{
    	SSOA_Idle,
    	SSOA_Shield,
    	SSOA_ClueBall,
    
};

enum EAnimalReaction
{
    	AR_Rearing,
    	AR_Kick,
    	AR_Backing,
    	AR_AddPanicPercents
};

enum EDoorQuestState
{
    	EDQS_Open,
    	EDQS_Close,
    	EDQS_RemoveLock,
    	EDQS_Enable,
    	EDQS_Disable,
    	EDQS_Lock
};

enum EGeraltPath
{
    	EGP_SWORD,
    	EGP_SIGNS,
    	EGP_ALCHEMY
};

enum EDM_MappinType
{
    	EDM_QuestAvailable,
    	EDM_MonsterNest,
    	EDM_Prostitute,
    	EDM_HorseRacingNPC,
    	EDM_NonQuestHorseRace,
    	EDM_QuestAvailableFromNonActor,
    	EDM_EP1QuestAvailable,
    	EDM_EP1QuestAvailableFromNonActor,
    	EDM_EP2QuestAvailable,
    	EDM_EP2QuestAvailableFromNonActor,
    	EDM_Torch,
    	EDM_HorseRaceTarget,
    	EDM_HorseRaceDummy,
    
};

enum EGwentCardFaction
{
    	EGCF_Neutral,
    	EGCF_Kingdoms,
    	EGCF_Nilfgaard,
    	EGCF_Monsters,
    	EGCF_Scoiatael,
    	EGCG_Skellige
};

enum EGwentDeckUnlock
{
    	EGDU_Northern_Kingdom,
    	EGDU_Nilfgaard,
    	EGDU_Scoiatael,
    	EGDU_No_Mans_Land,
    
};

enum EEnableMode
{
    	EEM_AsIs,
    	EEM_Enable,
    	EEM_Disable
};

enum EHudTimeOutAction
{
    	EHTOA_Start,
    	EHTOA_Stop,
    	EHTOA_Add,
    
};

enum EQuestPadVibrationStrength
{
    	EQPVS_VeryLight,
    	EQPVS_Light,
    	EQPVS_Hard,
    	EQPVS_VeryHard
};

enum ELanguageCheckType
{
    	LCT_Text,
    	LCT_Speech,
    	LCT_TextAndSpeech,
    
};

enum ECheckedLanguage
{
    	TL_None,
    	TL_English,
    	TL_Polish,
    	TL_German,
    	TL_Italian,
    	TL_French,
    	TL_Czech,
    	TL_Spanish,
    	TL_Chinese,
    	TL_Russian,
    	TL_Hungarian,
    	TL_Japanese,
    	TL_Turkish,
    	TL_Korean,
    	TL_Brazilian_Portuguese,
    	TL_Latin_American_Spanish,
    	TL_Arabic,
    	TL_Debug,
    
};

enum EQuestConditionDLCType
{
    	QCDT_Undefined,
    	QCDT_EP1,
    	QCDT_EP2,
    	QCDT_NGP,
    
};

enum EContainerMode
{
    	ECM_Empty,
    	ECM_NotEmpty
};

enum EQuestPlayerSkillLevel
{
    	EQPSL_Skill,
    	EQPSL_DialogAxiiLevel
};

enum EQuestPlayerSkillCondition
{
    	EQPSC_Equipped,
    	EQPSC_Learned,
    	EQPSC_LearnedButNotEquipped
};

enum EQuestConditionPlayerState
{
    	QCPS_None,
    	QCPS_Walking,
    	QCPS_Running,
    	QCPS_Sprinting,
    	QCPS_Swimming,
    	QCPS_Diving,
    	QCPS_Climbing,
    	QCPS_CastingSign,
    	QCPS_ParryStance,
    	QCPS_Preparation
};

enum ESwitchStateCondition
{
    	SSC_TurnedOn,
    	SSC_TurnedOff,
    	SSC_Enabled,
    	SSC_Disabled,
    	SSC_Locked,
    	SSC_Unlocked,
    	SSC_MaxUseCountReached,
    
};

enum EPlayerReplacerType
{
    	EPRT_Undefined,
    	EPRT_Geralt,
    	EPRT_Ciri,
    
};

enum EStorySceneOutputAction
{
    	SSOA_None,
    	SSOA_ReturnToPreviousState,
    	SSOA_MountVehicle,
    	SSOA_MountVehicleFast,
    	SSOA_EnterCombatSteel,
    	SSOA_EnterCombatSilver,
    	SSOA_EnterCombatFists
};

enum EStorySceneGameplayAction
{
    	SSGA_None,
    	SSGA_Walk_2m,
    	SSGA_Walk_5m,
    	SSGA_Walk_8m,
    	SSGA_Walk_2m_GoTo_Combat,
    	SSGA_Walk_5m_GoTo_Combat,
    	SSGA_Walk_8m_GoTo_Combat,
    	SSGA_Walk_2m_GoTo_Combat_Silver,
    	SSGA_Walk_5m_GoTo_Combat_Silver,
    	SSGA_Walk_8m_GoTo_Combat_Silver,
    	SSGA_GoTo_Combat_Pose,
    	SSGA_GoTo_Combat_Pose_Silver,
    	SSGA_GoTo_Combat_Pose_Fists,
    	SSGA_EndInWork,
    	SSGA_DelayWork,
    
};

enum ENegotiationResult
{
    	TooMuch,
    	PrettyClose,
    	WeHaveDeal,
    	GetLost
};

enum ECollectItemsRes
{
    	ItemCollected,
    	NothingChanged,
    	WrongItem,
    	AlreadyRecieved,
    	AllItemsCollected
};

enum ECollectItemsCustomRes
{
    	Book1 = 0,
    	Book2 = 1,
    	Book3 = 2,
    	Book4 = 3,
    	Book5 = 4,
    	NothingChangedCus = 5,
    	WrongItemCus = 6,
    	AlreadyRecievedCus = 7,
    	AllItemsCollectedCus = 8
};

enum EHorseWaterTestResult
{
    	HWTR_Normal,
    	HWTR_Adjusted,
    	HWTR_ToDeep
};

