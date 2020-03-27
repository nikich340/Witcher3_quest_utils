// ----------------------------------------------------------------------------
//
// BUGS:
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModStoryBoardShot {
    private var shotname: String;
    private var camSettings: SStoryBoardCameraSettings;
    // settings for all assets
    private var assetSettings: array<SStoryBoardShotAssetSettings>;
    // ------------------------------------------------------------------------
    public function init(optional statedata: SStoryBoardShotStateData) {
        var null: SStoryBoardShotStateData;

        if (statedata != null) {
            shotname = statedata.shotname;
            camSettings = statedata.camera;
            assetSettings = statedata.assets;
        } else {
            shotname = GetLocStringByKeyExt("SBUI_ShotNameEmpty");
            camSettings = SBUI_createCamSettingsFor(SBUICam_EmptyShot);
        }
    }
    // ------------------------------------------------------------------------
    public function getState() : SStoryBoardShotStateData {
        return SStoryBoardShotStateData(shotname, camSettings, assetSettings);
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CModStoryBoardShot) {
        var i: int;
        // TODO cut final str len
        shotname = src.getName() + GetLocStringByKeyExt("SBUI_ShotNameCloned");

        // --- clone all settings
        // -- one cam per shot
        camSettings = src.getCameraSettings();

        // -- all actors per shot
        assetSettings = src.getAssetSettings();
    }
    // ------------------------------------------------------------------------
    // no blanks and brackets
    public function getEscapedName() : String {
        return StrReplaceAll(
            StrReplaceAll(
                StrReplaceAll(shotname, " ", "_"),
            "(", "_"),
        ")", "_");
    }
    // ------------------------------------------------------------------------
    public function getName() : String {
        return shotname;
    }
    // ------------------------------------------------------------------------
    public function setName(newName: String) {
        if (StrLen(newName) > 0) {
            shotname = newName;
        }
    }
    // ------------------------------------------------------------------------
    public function getCameraSettings() : SStoryBoardCameraSettings {
        return camSettings;
    }
    // ------------------------------------------------------------------------
    public function setCameraSettings(newSettings: SStoryBoardCameraSettings) {
        camSettings = newSettings;
    }
    // ------------------------------------------------------------------------
    public function getAssetSettings() : array<SStoryBoardShotAssetSettings> {
        // Note: it's an array of structs => will be copied!
        return assetSettings;
    }
    // ------------------------------------------------------------------------
    public function setAssetSettings(newSettings: array<SStoryBoardShotAssetSettings>)
    {
        // Note: array of structs => will be copied
        assetSettings = newSettings;
    }
    // ------------------------------------------------------------------------
    public function onDeleteAsset(assetId: String) {
        var clonedSettings: SStoryBoardShotAssetSettings;
        var newAssetSettings: array<SStoryBoardShotAssetSettings>;
        var i: int;

        // in place manipulation of settings doesn't work: removing changes slots
        // positions and following in place updates would work with wrong slot!
        for (i = 0; i < assetSettings.Size(); i += 1) {
            if (assetSettings[i].assetId != assetId) {
                // check if other settings reference this id
                clonedSettings = assetSettings[i];
                if (clonedSettings.lookAt.lookAtActor == assetId) {
                    clonedSettings.lookAt.enabled = false;
                    clonedSettings.lookAt.lookAtActor = "";
                }

                newAssetSettings.PushBack(clonedSettings);
            }
        }
        assetSettings = newAssetSettings;
    }
    // ------------------------------------------------------------------------
    public function hasUnsavedChanges() : bool {
        return false;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
