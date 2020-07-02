// ----------------------------------------------------------------------------
class CRadishQuestLayerWaypointManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "waypoint";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        switch (specialization) {
            case "wander":  return new CRadishQuestLayerWanderpoint in layer;
            default:        return new CRadishQuestLayerWaypoint in layer;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
