// ----------------------------------------------------------------------------
class CRadishCommunityActorEditor extends CRadishCommunityElementEditor {
    // ------------------------------------------------------------------------
    private var actor: CRadishCommunityActor;
    // ------------------------------------------------------------------------
    protected function setElement(element: IRadishQuestSelectableElement) {
        this.actor = (CRadishCommunityActor)element;
    }
    // ------------------------------------------------------------------------
    protected function refreshSettingsList() {
        var template: String;
        var unused: bool;
        var i, s, a, as: int;
        var settings: SRadishCommunityActorData;
        var appearances: array<name>;

        settings = actor.getSettings();
        appearances = actor.getTemplateAppearances();
        as = appearances.Size();

        settingsList.clear();

        template = settings.template;
        if (StrLen(template) > 30) {
            template = "..." + StrRight(template, 30);
        }
        settingsList.addSetting("template", "template: " + template);
        settingsList.addSetting_bool_opt("reacttorain", settings.reactToRain, "reacts to rain", false);

        // -- tags
        // auto tag is always added
        settingsList.addSetting("tags:0", "[auto-tag]", "tags");
        s = settings.tags.Size();
        for (i = 0; i < s; i += 1) {
            settingsList.addSetting("tags:" + (i+1), settings.tags[i], "tags");
        }
        // -- appearances (TODO extract all for template, mark those used)
        s = settings.appearances.Size();
        if (s == 0) {
            // mark all
            for (a = 0; a < as; a += 1) {
                settingsList.addSetting("appearances:" + a, appearances[a], "appearances");
            }
        } else {
            // mark those which are selected
            for (a = 0; a < as; a += 1) {
                unused = true;
                for (i = 0; i < s; i += 1) {
                    if (appearances[a] == settings.appearances[i]) {
                        unused = false;
                        break;
                    }
                }
                if (unused) {
                    settingsList.addSetting("appearances:" + a,
                        "<font color=\"#666666\">" + appearances[a] + "</font>", "appearances [ " + s + "]");
                } else {
                    settingsList.addSetting("appearances:" + a,
                        appearances[a], "appearances [ " + s + "]");
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    protected function getAsUiSetting(selectedId: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (selectedId) {
            case "tags":    return ReadOnlyUiSetting(this);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSelectedSetting() {
        //switch (selectedId) {
        //    case "category":settings.category = UiSettingToString(editedSetting); break;
        //}
        //entity.setSettings(settings);
        //refreshSettingsList();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
