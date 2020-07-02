class CRadishCommunityPhaseDbgInitializer extends ISpawnTreeScriptedInitializer {
    private var dbgPhaseIdTag: name;
    // ------------------------------------------------------------------------
    function Init(actor: CActor) : bool {
        var tags: array<name>;
        var newTags: array<name>;
        var i, s: int;

        tags = actor.GetTags();
        s = tags.Size();
        for (i = 0; i < s; i += 1) {
            if (StrFindFirst(tags[i], "radish_comm_phase") != 0) {
                newTags.PushBack(tags[i]);
            }
        }
        newTags.PushBack(dbgPhaseIdTag);

        actor.SetTags(newTags);
        return true;
    }
    // ------------------------------------------------------------------------
    function GetEditorFriendlyName() : String {
        return "Radish Community Phase Debugger";
    }
    // ------------------------------------------------------------------------
}
