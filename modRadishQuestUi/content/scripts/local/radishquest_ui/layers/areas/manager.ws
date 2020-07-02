// ----------------------------------------------------------------------------
class CRadishQuestLayerAreaManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "area";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        switch (specialization) {
            case "env":     return new CRadishQuestLayerEnvArea in layer;
            case "sound":   return new CRadishQuestLayerAmbientSoundArea in layer;
            default:        return new CRadishQuestLayerArea in layer;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
