// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModSbUiVoiceLinesList extends CModUiFilteredList {
    private var durations: array<float>;
	// ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var data: C2dArray;
        var i: int;

        data = LoadCSV(path);

        items.Clear();

        // first entry of list is defined as no voice line (id == 0)!
        items.PushBack(SModUiCategorizedListItem(0, "- no voiceline -"));
        durations.PushBack(-1.0);

        // csv: CAT1;CAT2;CAT3;id;caption;duration
        for (i = 0; i < data.GetNumRows(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                data.GetValueAt(3, i),
                data.GetValueAt(4, i),
                data.GetValueAt(0, i),
                data.GetValueAt(1, i),
                data.GetValueAt(2, i)
            ));
            durations.PushBack(StringToFloat(data.GetValueAt(5, i), -1.1));
        }
    }
    // ------------------------------------------------------------------------
    public function addExtraLines(cat1: String, templates: array<SSbUiExtraLines>) {
        var topCat: String;
        var i: int;

        topCat = GetLocStringByKeyExt("SBUI_ExtraVoiceLinesCat");

        for (i = 0; i < templates.Size(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                templates[i].id,
                templates[i].caption,
                topCat,
                templates[i].subCategory1,
                templates[i].subCategory2));

            durations.PushBack(templates[i].duration);
        }
    }
    // ------------------------------------------------------------------------
    public function getDuration(id: String) : float {
        var i, s: int;

        s = items.Size();
        // not pretty...
        for (i = 0; i < s; i += 1) {
            if (items[i].id == id) {
                return durations[i];
            }
        }

        return -1.0;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Management of voicelines for actor assets per storyboard shot.
//
class CModStoryBoardVoiceLinesListsManager {
    // ------------------------------------------------------------------------
	private var voiceLines: CModSbUiVoiceLinesList;
    private var dataLoaded: Bool;
    // ------------------------------------------------------------------------
    public function init() { }
    // ------------------------------------------------------------------------
    private function lazyLoad() {
        voiceLines = new CModSbUiVoiceLinesList in this;
        voiceLines.loadCsv("dlc\storyboardui\data\actor_voicelines.csv");
        voiceLines.addExtraLines("XTRA", SBUI_getExtraActorVoiceLines());
        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function activate() {}
    // ------------------------------------------------------------------------
    public function deactivate() {}
    // ------------------------------------------------------------------------
    public function getDuration(id: String) : float {
        return voiceLines.getDuration(id);
    }
    // ------------------------------------------------------------------------
    public function getVoiceLinesList(actor: CModStoryBoardActor)
        : CModSbUiVoiceLinesList
    {
        if (!dataLoaded) { lazyLoad(); }
        // maybe load on demand different csv partitioned by voicetag?
        return voiceLines;
    }
    // ------------------------------------------------------------------------
    public function getLinesCount() : int {
        if (!dataLoaded) { lazyLoad(); }

        return voiceLines.getTotalCount();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
