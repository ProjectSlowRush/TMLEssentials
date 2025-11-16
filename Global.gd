extends Node

enum EquipType { Head, Body, Legs }
enum DrawnFrames { FrontShoulder, FrontArm, Head, Body, Legs, BackArm, BackShoulder }

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
