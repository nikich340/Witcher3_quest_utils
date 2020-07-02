// ----------------------------------------------------------------------------
class CRadishCommunityActor extends CRadishCommunityElement {
    // ------------------------------------------------------------------------
    var tmplAppearances: array<name>;
    // ------------------------------------------------------------------------
    protected var settings: SRadishCommunityActorData;
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishCommunityActorData {
        return settings;
    }
    // ------------------------------------------------------------------------
    private function loadAppearanceNames() {
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource(settings.template, true);
        GetAppearanceNames(template, tmplAppearances);
    }
    // ------------------------------------------------------------------------
    // returns full list of template appearance
    public function getTemplateAppearances() : array<name> {
        if (tmplAppearances.Size() == 0) {
            loadAppearanceNames();
        }
        return tmplAppearances;
    }
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content, defs: SEncValue;
        // TODO
        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CEncodedRadishCommunityActor extends CRadishCommunityActor {
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(communityId: String, metaInfo: array<SDbgInfo>) {
        var i, s: int;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            // parse encoded meta information in dbgInfo
            switch (metaInfo[i].type) {
                case "id":          settings.id = metaInfo[i].s; break;
                case "template":    settings.template = metaInfo[i].s; break;
                case "tag":         settings.tags.PushBack(metaInfo[i].s); break;
                case "appearance":  settings.appearances.PushBack(metaInfo[i].n); break;
                case "reacttorain": settings.reactToRain = metaInfo[i].i == 1; break;
            }
        }
        // TODO initFromData
        this.setId(settings.id);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
