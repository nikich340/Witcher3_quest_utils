// -----------------------------------------------------------------------------
//
// BUGS:
//  - renaming to empty names possible
//  - multiple cloning explodes name size => cut at some point
//  - hiding items with SetVisibility not possible (imported by CActor)
//  - idle animation probing is stupid -> provide default idle anim directly in
//      actor_templates?
//
//  TODO
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
abstract class CModStoryBoardAsset {
    // ------------------------------------------------------------------------
    protected var id: String;
    // settings from currently selected shot. this will be overwritten on every
    // shot change by the shotviewer when displaying a specific shot.
    protected var shotSettings: SStoryBoardShotAssetSettings;
    protected var templatePath: String;
    protected var assetname: String; default assetname = "asset";
    // ------------------------------------------------------------------------
    // flag to decide if asset was named by user
    protected var userSetName: bool;
    // ------------------------------------------------------------------------
    // default spawning/respawning positions
    private var defaultPlacement: SStoryBoardPlacementSettings;

    protected var entity: CEntity;
    // flag to indicate a respawn is required (e.g. actor appearance change disables mimics)
    protected var needsRespawn: bool;
    // ------------------------------------------------------------------------
    public function cloneFrom(id: String, src: CModStoryBoardAsset) {
        this.id = id;

        assetname = src.getName() + GetLocStringByKeyExt("SBUI_AssetNameCloned");

        templatePath = src.templatePath;
    }
    // ------------------------------------------------------------------------
    public final function getId() : String {
        return id;
    }
    // ------------------------------------------------------------------------
    public final function getName(optional escaped: bool) : String {
        if (escaped) {
            return StrReplaceAll(assetname, " ", "_");
        } else {
            return assetname;
        }
    }
    // ------------------------------------------------------------------------
    public final function setName(newName: String, optional userSetName: bool) {
        // auto naming only if user did not name it already
        if ((!this.userSetName || userSetName) && newName != "") {
            assetname = newName;
        }
        this.userSetName = this.userSetName || userSetName;
    }
    // ------------------------------------------------------------------------
    public function setTemplatePath(path: String) {
        templatePath = path;
        respawn();
    }
    // ------------------------------------------------------------------------
    public function getTemplatePath() : String {
        return templatePath;
    }
    // ------------------------------------------------------------------------
    public function setShotSettings(
        optional newSettings: SStoryBoardShotAssetSettings)
    {
        var defaultSettings: SStoryBoardShotAssetSettings;

        // defaultSettings are "empty" here
        if (defaultSettings != newSettings) {
            shotSettings = newSettings;
        } else {
            // create defaultsettings
            defaultSettings.assetId = id;
            defaultSettings.placement = defaultPlacement;

            shotSettings = defaultSettings;
        }
    }
    // ------------------------------------------------------------------------
    public function getShotSettings() : SStoryBoardShotAssetSettings {
        return shotSettings;
    }
    // ------------------------------------------------------------------------
    public function getEntity() : CEntity {
        return entity;
    }
    // ------------------------------------------------------------------------
    public function needsRespawn() : bool {
        return needsRespawn;
    }
    // ------------------------------------------------------------------------
    public function respawn() {
        despawn();
        spawn();
    }
    // ------------------------------------------------------------------------
    public function spawn() {
        var template: CEntityTemplate;
        var placement: SStoryBoardPlacementSettings;

        if (!entity) {
            template = (CEntityTemplate)LoadResource(templatePath, true);
            // if this is a respawn (e.g. template update) use shot settings
            if (placement != shotSettings.placement) {
                placement = shotSettings.placement;
            } else {
                placement = defaultPlacement;
            }
            entity = theGame.CreateEntity(template, placement.pos, placement.rot);

            needsRespawn = false;
        }
    }
    // ------------------------------------------------------------------------
    public function despawn() {
        var emptyEntity: CEntity;

        if (entity) {
            entity.StopAllEffects();
            entity.Destroy();
            // overwrite entity directly because it takes some time to despawn it
            // and re/spawn uses var as flag
            entity = emptyEntity;
        }
    }
    // ------------------------------------------------------------------------
    public function setDefaultPlacement(
        placement: SStoryBoardPlacementSettings, updateShotSettings: bool)
    {
        // store placement if asset is not spawned yet (otherwise it spawns at 0,0,0)
        defaultPlacement = placement;
        setPlacement(placement, !updateShotSettings);
    }
    // ------------------------------------------------------------------------
    public function setPlacement(
        newPlacement: SStoryBoardPlacementSettings, optional dontUpdateShotSettings: bool)
    {
        if (entity) {
            if (!dontUpdateShotSettings) {
                shotSettings.placement = newPlacement;
            }
            setVisibility(newPlacement.isHidden);
            entity.TeleportWithRotation(newPlacement.pos, newPlacement.rot);
        }
    }
    // ------------------------------------------------------------------------
    public function getCurrentPlacement() : SStoryBoardPlacementSettings {
        var placement: SStoryBoardPlacementSettings;

        placement.pos = entity.GetWorldPosition();
        placement.rot = entity.GetWorldRotation();
        placement.isHidden = isHidden();

        return placement;
    }
    // ------------------------------------------------------------------------
    public function setVisibility(isHidden: bool);
    // ------------------------------------------------------------------------
    public function isHidden() : bool;
    // ------------------------------------------------------------------------
    public function freeze();
    // ------------------------------------------------------------------------
    public function unfreeze();
    // ------------------------------------------------------------------------
    public function isMeshSizeAvailable() : bool {
        var size: Vector;

        getMeshSize(size);

        return size.X != 0.5 && size.Y != 0.5 && size.Z != 0.5;
    }
    // ------------------------------------------------------------------------
    public function getMeshSize(out meshSize: Vector) : bool;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// TODO could be used to prefilter animations (=> less dupes)
// FIXME enum are bytes (-127..128) need more clever partitioning (or subtypes)
enum EStoryBoardActorType {
    ESB_AT_Untested = -2,
    ESB_AT_Unknown = -1,
    // 0 - 29
    ESB_AT_Human = 0,
    ESB_AT_Woman = 1,
    ESB_AT_Man = 2,
    ESB_AT_Child = 10,
    ESB_AT_Dwarf = 20,
    // 30 - 59
    ESB_AT_WildHunt = 31,
    // 60 - 89
    ESB_AT_Animal = 60,
    ESB_AT_AnimalSheep = 61,
    ESB_AT_AnimalCat = 62,
    ESB_AT_AnimalPig = 63,
    ESB_AT_AnimalGoat = 64,
    // 90 - 120
    ESB_AT_Monster = 90,
    ESB_AT_MonsterWerewolf = 91,
    ESB_AT_MonsterWitch = 92,
    ESB_AT_MonsterKatakan = 93,
    ESB_AT_MonsterMiscreant = 94,
    ESB_AT_MonsterEndriaga = 95,
    ESB_AT_MonsterDrowner = 96,
}
// ----------------------------------------------------------------------------
function SBUI_getMeshBox(entity: CEntity, optional minSize: float) : Box {
    var meshComps : array<CComponent>;
    var i: int;

    var compBox: Box;
    var box: Box;

    // some meshes don't have any bounding box defined (?)
    // set minimal bounding box for camera position calculations
    minSize = MaxF(minSize / 2.0, 0.5);

    box.Min = Vector(0, 0, 0, 1);
    box.Max = Vector(0, 0, 0, 1);

    meshComps = entity.GetComponentsByClassName('CMeshComponent');

    for (i = 0; i < meshComps.Size(); i += 1) {
        compBox = ((CMeshComponent)meshComps[i]).mesh.boundingBox;

        if (box.Min.X > compBox.Min.X) { box.Min.X = compBox.Min.X; }
        if (box.Min.Y > compBox.Min.Y) { box.Min.Y = compBox.Min.Y; }
        if (box.Min.Z > compBox.Min.Z) { box.Min.Z = compBox.Min.Z; }

        if (box.Max.X < compBox.Max.X) { box.Max.X = compBox.Max.X; }
        if (box.Max.Y < compBox.Max.Y) { box.Max.Y = compBox.Max.Y; }
        if (box.Max.Z < compBox.Max.Z) { box.Max.Z = compBox.Max.Z; }
    }
    return box;
}
// ----------------------------------------------------------------------------
function SBUI_extractMeshBoxSize(box: Box, optional minSize: float) : Vector {
    var result: Vector;

    if (minSize == 0.0) {
        minSize = 1.0;
    }

    result.X = MaxF(box.Max.X - box.Min.X, minSize);
    result.Y = MaxF(box.Max.Y - box.Min.Y, minSize);
    result.Z = MaxF(box.Max.Z - box.Min.Z, minSize);
    result.W = 1;

    return result;
}
// ----------------------------------------------------------------------------
class CModStoryBoardActor extends CModStoryBoardAsset {
    default templatePath = "characters\npc_entities\main_npc\avallach.w2ent";
    // ------------------------------------------------------------------------
    // determines a *compatible* idle animation to use if no pose was selected
    // (yet/removed). has to be probed on adjusted on every template change!
    private var defaultIdleAnim: CName;
    default defaultIdleAnim = 'high_standing_determined_idle';
    // ------------------------------------------------------------------------
    // special doppler template for cloning player entity
    private var playerCloneTemplate: String;
    // NOTE: DO NOT CHANGE! this must be exactly as the entry in the template csv!
    default playerCloneTemplate = "dlc\modtemplates\storyboardui\geralt_npc.w2ent";
    // ------------------------------------------------------------------------
    private var appearanceNames: array<CName>;
    private var appearanceId: int;
    private var mimicsTriggerScene: CStoryScene;

    // current look at state
    private var isStaticLookAt: bool;
    private var isActiveLookAt: bool;

    // coarse classification for prefiltering animations
    private var cachedActorType: EStoryBoardActorType; default cachedActorType = ESB_AT_Untested;
    // ------------------------------------------------------------------------
    public function cloneFrom(id: String, src: CModStoryBoardAsset) {
        super.cloneFrom(id, src);

        defaultIdleAnim = ((CModStoryBoardActor)src).getDefaultIdleAnim();
    }
    // ------------------------------------------------------------------------
    public function init(id: String, optional statedata: SStoryBoardActorStateData)
    {
        var null: SStoryBoardActorStateData;

        if (statedata != null) {
            this.id = statedata.id;
            this.assetname = statedata.assetname;
            this.userSetName = statedata.userSetName;
            this.templatePath = statedata.templatePath;
            this.appearanceId = statedata.appearanceId;
            this.defaultIdleAnim = statedata.defaultIdleAnim;
        } else {
            this.id = id;
            assetname = "avallach";
        }

        mimicsTriggerScene = (CStoryScene)LoadResource(
            "dlc/storyboardui/data/mimicstrigger.w2scene", true);
    }
    // ------------------------------------------------------------------------
    public function getState() : SStoryBoardActorStateData {
        return SStoryBoardActorStateData(
            id, assetname, userSetName, templatePath, appearanceId, defaultIdleAnim);
    }
    // ------------------------------------------------------------------------
    public function setShotSettings(
        optional newSettings: SStoryBoardShotAssetSettings)
    {
        super.setShotSettings(newSettings);
        if (shotSettings.pose.idleAnimId == 0) {
            shotSettings.pose.idleAnimName = defaultIdleAnim;
        }
    }
    // ------------------------------------------------------------------------
    public function getActorType() : EStoryBoardActorType {
        var actor: CActor;
        var mac: CMovingAgentComponent;

        if ((int)cachedActorType < 0) {
            cachedActorType = ESB_AT_Unknown;

            actor = (CActor)entity;

            mac = actor.GetMovingAgentComponent();
            if (mac) {
                switch (mac.GetName()) {
                    case "woman_base":      cachedActorType = ESB_AT_Woman; break;
                    case "man_base":        cachedActorType = ESB_AT_Man; break;
                    case "dwarf_base":      cachedActorType = ESB_AT_Dwarf; break;
                    case "child_base":      cachedActorType = ESB_AT_Child; break;
                    case "wild_hunt_base":  cachedActorType = ESB_AT_WildHunt; break;
                    //case "uma_base":

                    case "werewolf_base":   cachedActorType = ESB_AT_MonsterWerewolf; break;
                    case "witch_base":      cachedActorType = ESB_AT_MonsterWitch; break;
                    case "katakan_base":    cachedActorType = ESB_AT_MonsterKatakan; break;
                    //case "ghoul_base":      includes gravehag
                    case "miscreant_base":  cachedActorType = ESB_AT_MonsterMiscreant; break;
                    case "endriaga_base":   cachedActorType = ESB_AT_MonsterEndriaga; break;

                    case "bear_berserker":  cachedActorType = ESB_AT_Animal; break;
                    case "sheep_base":      cachedActorType = ESB_AT_AnimalSheep; break;
                    case "cat_base":        cachedActorType = ESB_AT_AnimalCat; break;
                    case "pig_base":        cachedActorType = ESB_AT_AnimalPig; break;
                    case "goat_base":       cachedActorType = ESB_AT_AnimalGoat; break;
                    //TODO more?

                    default:
                        if (StrContains(templatePath, "drowner")) {
                            cachedActorType = ESB_AT_MonsterDrowner;
                        }
                }

            }
            if (cachedActorType == ESB_AT_Unknown) {

                if (actor.IsMonster()) {
                    cachedActorType = ESB_AT_Monster;

                } else if (actor.IsAnimal()) {
                    cachedActorType = ESB_AT_Animal;

                } else if (actor.IsHuman()) {
                    // this should be already resolved by the above switch
                    cachedActorType = ESB_AT_Human;

                    if (actor.IsMan()) {
                        cachedActorType = ESB_AT_Man;
                    } else if (actor.IsWoman()) {
                        cachedActorType = ESB_AT_Woman;
                    } else {
                        cachedActorType = ESB_AT_Child;
                    }
                }
            }
        }
        return cachedActorType;
    }
    // ------------------------------------------------------------------------
    public function setTemplatePath(path: String) {
        var prevType: EStoryBoardActorType;

        prevType = cachedActorType;
        cachedActorType = ESB_AT_Untested;
        appearanceId = 0;

        super.setTemplatePath(path);

        // check if previously set idle anim is compatible (for all humanoid actors
        // this should work). for monsters/animals it may require to probe the
        // predefined set of idle anims
        if (prevType != getActorType() || !isCompatibleAnimation(defaultIdleAnim)) {
            defaultIdleAnim = '';
        }
    }
    // ------------------------------------------------------------------------
    public function setAppearance(appearanceId: int, optional isFirstTime: bool) {
        var actor: CActor;

        if (isPlayerClone()) {
            this.appearanceId = 0;
        } else {
            this.appearanceId = appearanceId;
        }
        ((CActor)entity).SetAppearance(appearanceNames[appearanceId]);

        // appearance change on a spawned actor seems to disable mimics capability.
        // it works setting the appearance first time, though (timing before it's
        // "really" spawned?)
        needsRespawn = !isFirstTime;
    }
    // ------------------------------------------------------------------------
    private function loadAppearanceNames() {
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource(templatePath, true);
        GetAppearanceNames(template, appearanceNames);
    }
    // ------------------------------------------------------------------------
    public function getAppearanceName(optional prettyPrinted: bool) : String {
        if (prettyPrinted) {
            return NameToString(appearanceNames[appearanceId]) +
                " (" + IntToString(appearanceId + 1) + "/" + appearanceNames.Size() + ")";
        } else {
            return NameToString(appearanceNames[appearanceId]);
        }
    }
    // ------------------------------------------------------------------------
    public function changeAppearance(bySlots : int) {
        var newSlot: int;

        newSlot = appearanceId + bySlots;
        if (newSlot < 0) {
            newSlot += appearanceNames.Size();
        }
        setAppearance(newSlot % appearanceNames.Size());
    }
    // ------------------------------------------------------------------------
    private function cloneFromPlayer(witcher: W3PlayerWitcher) {
        var equipmentToClone: array<EEquipmentSlots>;
        var inv: CInventoryComponent;
        var item: SItemUniqueId;
        var ids: array<SItemUniqueId>;
        var i: int;
        var comp: array<CComponent>;
        var head: name;

        // -- equipment
        equipmentToClone.PushBack(EES_Armor);
        equipmentToClone.PushBack(EES_Boots);
        equipmentToClone.PushBack(EES_Pants);
        equipmentToClone.PushBack(EES_Gloves);
        equipmentToClone.PushBack(EES_RangedWeapon);
        equipmentToClone.PushBack(EES_SilverSword);
        equipmentToClone.PushBack(EES_SteelSword);

        inv = ((CNewNPC)entity).GetInventory();

        for (i = 0; i < equipmentToClone.Size(); i += 1) {
            if (witcher.GetItemEquippedOnSlot(equipmentToClone[i], item)) {
                ids = inv.AddAnItem(witcher.inv.GetItemName(item));
                inv.MountItem(ids[0]);
            }
        }

        // -- scabbards
        //FIXME doesn't work for now
        ids = thePlayer.GetInventory().GetItemsByCategory('silver_scabbards');
        if (ids.Size() > 0) { inv.MountItem(ids[0]); }
        ids = thePlayer.GetInventory().GetItemsByCategory('steel_scabbards');
        if (ids.Size() > 0) { inv.MountItem(ids[0]); }

        // -- hair
        ids = witcher.inv.GetItemsByCategory('hair');
        for (i = 0; i < ids.Size(); i += 1) {
            if (witcher.inv.GetItemName(ids[i]) != 'Preview Hair'
                && witcher.inv.IsItemMounted(ids[i]))
            {
                ids = inv.AddAnItem(witcher.inv.GetItemName(ids[i]));
                inv.MountItem(ids[0]);
            }
        }

        // -- head
        comp = witcher.GetComponentsByClassName('CHeadManagerComponent');
        head = ((CHeadManagerComponent)comp[0]).GetCurHeadName();
        ids = inv.AddAnItem(head);
        inv.MountItem(ids[0]);
    }
    // ------------------------------------------------------------------------
    public function getPlayerTemplatePath() : String {
        return playerCloneTemplate;
    }
    // ------------------------------------------------------------------------
    public function isPlayerClone() : bool {
        return templatePath == playerCloneTemplate;
    }
    // ------------------------------------------------------------------------
    public function enableCollisions(enable: bool) {
        var mac: CMovingPhysicalAgentComponent;

        ((CActor)entity).EnableCollisions(enable);
        mac = (CMovingPhysicalAgentComponent)((CNewNPC)entity).GetMovingAgentComponent();
        if (mac) {
            mac.SetEnabledFeetIK(enable);
        }
    }
    // ------------------------------------------------------------------------
    public function spawn() {
        var mac: CMovingPhysicalAgentComponent;
        var forceActionId: int;
        var aiTree: CAIIdleTree;
        var actor: CActor;
        var t: CMovingAgentComponent;
        var b: bool;

        super.spawn();

        isActiveLookAt = false;

        // get equipment and appearance from player
        if (isPlayerClone()) {
            cloneFromPlayer(GetWitcherPlayer());
        }

        loadAppearanceNames();
        setAppearance(appearanceId, true);

        actor = (CActor)entity;

        actor.EnableCharacterCollisions(false);
        // make sure *everybody* is friendly or they attack player while in
        // storyboard mode
        actor.SetTemporaryAttitudeGroup('q104_avallach_friendly_to_all', AGP_Default);
        enableCollisions(false);

        // trigger mimics capability for new entity
        actor.AddTag('MimicsTrigger');
        theGame.GetStorySceneSystem().PlayScene(mimicsTriggerScene, "trigger");
        actor.RemoveTag('MimicsTrigger');

        // force actor to stay in place
        aiTree = new CAIIdleTree in actor;
        aiTree.OnCreated();
        forceActionId = actor.ForceAIBehavior(aiTree, BTAP_AboveCombat);
    }
    // ------------------------------------------------------------------------
    public function freeze() {
        var animatedComponent: CAnimatedComponent;

        animatedComponent = (CAnimatedComponent)((CActor)entity)
            .GetComponentByClassName('CAnimatedComponent');

        animatedComponent.FreezePose();
    }
    // ------------------------------------------------------------------------
    public function unfreeze() {
        var animatedComponent: CAnimatedComponent;
        var actor: CActor;

        animatedComponent = (CAnimatedComponent)((CActor)entity)
            .GetComponentByClassName('CAnimatedComponent');

        if (animatedComponent.HasFrozenPose()) {

            actor = (CActor)entity;
            actor.SetBehaviorVariable('requestedFacingDirection',
                AngleNormalize(shotSettings.placement.rot.Yaw));

            animatedComponent.UnfreezePose();
        }
    }
    // ------------------------------------------------------------------------
    public function resetItems() {
        var inv: CInventoryComponent;

        inv = ((CActor)entity).GetInventory();
        if (inv) {
            inv.UnmountItem(inv.GetItemFromSlot('r_weapon'), true);
            inv.UnmountItem(inv.GetItemFromSlot('l_weapon'), true);
        }
    }
    // ------------------------------------------------------------------------
    public function despawn() {
        var actor: CActor;

        actor = (CActor)entity;

        actor.ResetTemporaryAttitudeGroup(AGP_Default);
        actor.EnableCharacterCollisions(true);
        actor.EnableCollisions(true);

        super.despawn();
    }
    // ------------------------------------------------------------------------
    private function preventBehTreeRotation() {
        var movementAdjustor: CMovementAdjustor;
        var ticket : SMovementAdjustmentRequestTicket;

        movementAdjustor = ((CActor)entity).GetMovingAgentComponent().GetMovementAdjustor();
        // prevent beh tree to turn around
        movementAdjustor.CancelByName('RotateAwayEvent');
        movementAdjustor.CancelByName('RotateEvent');

        ticket = movementAdjustor.CreateNewRequest('RotateAwayEvent');
        movementAdjustor.Continuous(ticket);
        movementAdjustor.RotateTo(ticket, shotSettings.placement.rot.Yaw);
    }
    // ------------------------------------------------------------------------
    public function setPlacement(
        newPlacement: SStoryBoardPlacementSettings, optional dontUpdateShotSettings: bool)
    {
        super.setPlacement(newPlacement, dontUpdateShotSettings);

        // Teleporting with rotation makes the actor rotate back (don't know
        // how to properly rotate without animation). workaround is to setup
        // a (fast) rotate request in the movement adjuster
        if (!dontUpdateShotSettings){
            preventBehTreeRotation();
        }
    }
    // ------------------------------------------------------------------------
    public function setVisibility(isHidden: bool) {
        var actor: CActor;

        if (isHidden() != isHidden) {
            actor = (CActor)entity;
            actor.SetVisibility(!isHidden);
        }
    }
    // ------------------------------------------------------------------------
    public function isHidden() : bool {
        var isVisible: bool;
        isVisible = ((CActor)entity).GetVisibility();

        return !isVisible;
    }
    // ------------------------------------------------------------------------
    public function rotateToFace(asset: CModStoryBoardAsset) {
        var newPlacement: SStoryBoardPlacementSettings;
        var pos1, pos2: Vector;
        var rot: EulerAngles;

        pos1 = entity.GetWorldPosition();
        pos2 = asset.getEntity().GetWorldPosition();

        newPlacement = shotSettings.placement;
        newPlacement.pos = pos1;
        newPlacement.rot.Yaw = VecHeading(pos2 - pos1);

        setPlacement(newPlacement);
    }
    // ------------------------------------------------------------------------
    public function getHeadPosition() : Vector {
        var actor: CActor;
        var headBoneIdx: int;

        actor = (CActor)entity;
        headBoneIdx = actor.GetHeadBoneIndex();
        if (headBoneIdx >= 0) {
            return MatrixGetTranslation(actor.GetBoneWorldMatrixByIndex(headBoneIdx));
        } else {
            return actor.GetWorldPosition();
        }
    }
    // ------------------------------------------------------------------------
    public function getMeshSize(out meshSize: Vector) : bool {
        var boundingBox: Box;
        var entityPos: Vector;
        var headPos: Vector;
        var headHeight: float;

        // try boundingbox first
        entity.CalcBoundingBox(boundingBox);
        meshSize = SBUI_extractMeshBoxSize(boundingBox, 0.25);

        if (meshSize.X == 0.25 && meshSize.Y == 0.25 && meshSize.Z == 0.25) {
            // entity doesn't have a boundingbox (yet?) return default box
            meshSize = Vector(0.5, 0.5, 0.5, 1.0);
            return true;
        }

        boundingBox = SBUI_getMeshBox(entity);
        // prefer extracted mesh box but take bounding box meshsize as fallback
        if (boundingBox.Max - boundingBox.Min != Vector()) {
            entityPos = entity.GetWorldPosition();
            headPos = getHeadPosition();
            headHeight = ClampF(headPos.Z - entityPos.Z, 1.0, 20.0);

            meshSize = SBUI_extractMeshBoxSize(boundingBox, headHeight);
        }

        return meshSize.X > 500 || meshSize.Y > 500 || meshSize.Z > 500;
    }
    // ------------------------------------------------------------------------
    public function dynamicLookAt(node: CNode) {
        isActiveLookAt = true;
        isStaticLookAt = false;
        ((CActor)entity).EnableDynamicLookAt(node, 9999999);
    }
    // ------------------------------------------------------------------------
    public function staticLookAt(node: CNode) {
        isActiveLookAt = true;
        isStaticLookAt = true;
        ((CActor)entity).EnableDynamicLookAt(node, 9999999);
    }
    // ------------------------------------------------------------------------
    public function disableLookAt() {
        isActiveLookAt = false;
        ((CActor)entity).DisableLookAt();
    }
    // ------------------------------------------------------------------------
    public function isDynamicLookAt() : bool {
        return isActiveLookAt && !isStaticLookAt;
    }
    // ------------------------------------------------------------------------
    public function isStaticLookAt() : bool {
        return isActiveLookAt && isStaticLookAt;
    }
    // ------------------------------------------------------------------------
    public function setIdlePose(optional newPose: SStoryBoardPoseSettings) {
        if (entity) {
            // make sure pose contains *always* an idle animation
            if (newPose.idleAnimId < 1) {
                shotSettings.pose = SStoryBoardPoseSettings(0, defaultIdleAnim);
            } else {
                shotSettings.pose = newPose;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function setAnimation(newAnimation: SStoryBoardAnimationSettings) {
        if (entity) {
            shotSettings.animation = newAnimation;
        }
    }
    // ------------------------------------------------------------------------
    public function setMimicsAnimation(newMimics: SStoryBoardAnimationSettings) {
        if (entity) {
            shotSettings.mimics = newMimics;
        }
    }
    // ------------------------------------------------------------------------
    public function setLookAt(newLookAt: SStoryBoardLookAtSettings) {
        if (entity) {
            shotSettings.lookAt = newLookAt;
        }
    }
    // ------------------------------------------------------------------------
    public function setVoiceLine(newAudio: SStoryBoardAudioSettings) {
        if (entity) {
            shotSettings.audio = newAudio;
        }
    }
    // ------------------------------------------------------------------------
    public function isCompatibleAnimation(animId: CName) : bool {
        var animatedComponent: CAnimatedComponent;

        animatedComponent = (CAnimatedComponent)((CActor)entity)
            .GetComponentByClassName('CAnimatedComponent');

        return animatedComponent.PlaySlotAnimationAsync(animId, 'NPC_ANIM_SLOT');
    }
    // ------------------------------------------------------------------------
    public function isCompatibleMimicsAnimation(animId: CName) : bool {
        return ((CActor)entity).PlayMimicAnimationAsync(animId);
    }
    // ------------------------------------------------------------------------
    public function resetCompatibilityCheckAnimations() {
        // just try to playback an invalid anim
        isCompatibleAnimation('none');
        isCompatibleMimicsAnimation('none');
    }
    // ------------------------------------------------------------------------
    public function getDefaultIdleAnim() : CName {
        return defaultIdleAnim;
    }
    // ------------------------------------------------------------------------
    public function setDefaultIdleAnim(idlePoseAnim: CName) {
        defaultIdleAnim = idlePoseAnim;
        // (re)init pose settings
        setIdlePose();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModStoryBoardItem extends CModStoryBoardAsset {
    default templatePath = "items\bodyparts\ciri_items\scabbard_01_wa__ciri.w2ent";
    // ------------------------------------------------------------------------
    public function init(id: String, optional statedata: SStoryBoardItemStateData) {
        var null: SStoryBoardItemStateData;

        if (statedata != null) {
            this.id = statedata.id;
            this.templatePath = statedata.templatePath;
            this.assetname = statedata.assetname;
            this.userSetName = statedata.userSetName;
        } else {
            this.id = id;
            assetname = "scabbard 01 wa ciri";
        }
    }
    // ------------------------------------------------------------------------
    public function getState() : SStoryBoardItemStateData {
        return SStoryBoardItemStateData(id, assetname, userSetName, templatePath);
    }
    // ------------------------------------------------------------------------
    public function setVisibility(isHidden: bool) {
        //TODO is this even possible for all CEntities?
    }
    // ------------------------------------------------------------------------
    public function setPlacement(
        newPlacement: SStoryBoardPlacementSettings, optional dontUpdateShotSettings: bool)
    {
        super.setPlacement(newPlacement, dontUpdateShotSettings);

        // some assets do not teleport their collision/height information and
        // should be respawned after replacement (aka interactive placement)
        if (!dontUpdateShotSettings){
            needsRespawn = true;
        }
    }
    // ------------------------------------------------------------------------
    public function getMeshSize(out meshSize: Vector) : bool {
        var boundingBox: Box;

        // try boundingbox first
        entity.CalcBoundingBox(boundingBox);
        meshSize = SBUI_extractMeshBoxSize(boundingBox, 0.25);

        if (meshSize.X == 0.25 && meshSize.Y == 0.25 && meshSize.Z == 0.25) {
            // entity doesn't have a boundingbox (yet?) return default box
            meshSize = Vector(0.5, 0.5, 0.5, 1.0);
            return true;
        }

        return meshSize.X > 500 || meshSize.Y > 500 || meshSize.Z > 500;
    }
    // ------------------------------------------------------------------------
    public function isHidden() : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function freeze() {}
    // ------------------------------------------------------------------------
    public function unfreeze() {}
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
