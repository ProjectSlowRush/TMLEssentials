extends Node

# Front -> Back
# enum EquipType { Shield, Face, Beard, Head, Neck, HandsOff, Waist, Body, Shoes, Legs, Balloon, Back, Wings }
enum EquipType { Shield, Face, Beard, Head, Neck, Waist, Body, Shoes, Legs }
enum DrawnFrames { Shield, FrontShoulder, FrontArm, Face, Beard, Head, Neck, Waist, Body, Shoes, Legs, Balloon, BackArm, BackShoulder, Wings }

var frame = 0
@warning_ignore("unused_signal")
signal advanceFrame
@warning_ignore("unused_signal")
signal deletePreview(newCount: int)
@warning_ignore("unused_signal")
signal maximizePreview(panel: PreviewPanel)
@warning_ignore("unused_signal")
signal playPausePlayback(paused: bool)
@warning_ignore("unused_signal")
signal setPlaybackSpeed(speed: float)
