// -----------------------------------------------------------------------------
//
// BUGS:
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
struct SStoryBoardCameraDofSettings {
    var strength: float;
    var blurNear: float;
    var blurFar: float;
    var focusNear: float;
    var focusFar: float;
}
// ----------------------------------------------------------------------------
struct SStoryBoardCameraSettings {
    var pos: Vector;
    var rot: EulerAngles;
    var fov: float;
    var dof: SStoryBoardCameraDofSettings;
}
// ----------------------------------------------------------------------------
struct SStoryBoardPlacementSettings {
    var pos: Vector;
    var rot: EulerAngles;
    var isHidden: bool;
}
// ----------------------------------------------------------------------------
struct SStoryBoardPoseSettings {
    var idleAnimId: int;
    var idleAnimName: CName;
}
// ----------------------------------------------------------------------------
struct SStoryBoardAnimationSettings {
    // since animationid are CNames which cannot be saved/restored the numerical
    // id is saved, too
    var animId: int;
    var animName: CName;
    // for now not used but it may be added later since it's possible to specify
    // on playback
    //var blendIn: float;
    //var blendOut: float;
    var enabledCollisions: bool;
}
// ----------------------------------------------------------------------------
struct SStoryBoardLookAtSettings {
    var enabled: bool;
    var lookAtActor: String;
    var rot: EulerAngles;
    var distance: Float;
}
// ----------------------------------------------------------------------------
struct SStoryBoardAudioSettings {
    var lineId: int;
    var duration: float;
}
// ----------------------------------------------------------------------------
// settings for one asset which may change for every shot
// Note: this must be a struct to make sure it gets not modified when passed to
// other classes (structs are not passed by reference but copied)
struct SStoryBoardShotAssetSettings {
    // since there are no hashmaps an identifier must be baked into settings to
    // find settings for specific assetid
    var assetId: String;
    var placement: SStoryBoardPlacementSettings;
    var pose: SStoryBoardPoseSettings;
    var animation: SStoryBoardAnimationSettings;
    var mimics: SStoryBoardAnimationSettings;
    var lookAt: SStoryBoardLookAtSettings;
    var audio: SStoryBoardAudioSettings;
}
// ----------------------------------------------------------------------------
