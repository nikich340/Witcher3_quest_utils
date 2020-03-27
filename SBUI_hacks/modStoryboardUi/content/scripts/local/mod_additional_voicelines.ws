// ----------------------------------------------------------------------------
// Storyboard UI: additional actor voice lines can be added dynamically, these
// are the required infos:
struct SSbUiExtraLines {
    var id: int;
    var subCategory1: String;
    var subCategory2: String;
    var caption: String;
    var duration: float;
}
// ----------------------------------------------------------------------------
// add custom mod voicelines for actors here:
// ----------------------------------------------------------------------------
function SBUI_getExtraActorVoiceLines() : array<SSbUiExtraLines> {
    var actorLines: array<SSbUiExtraLines>;

    // Note: order must be sorted by subCategory1, subCategory2, duration
    //actorLines.PushBack(SSbUiExtraLines(1000015, "geralt", , "Can we talk?", 1.078081));
    //actorLines.PushBack(SSbUiExtraLines(1000020, "geralt", , "So long.", 0.93352264));

    return actorLines;
}
// ----------------------------------------------------------------------------
