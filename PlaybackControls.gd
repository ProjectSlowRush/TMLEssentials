class_name PlaybackControls extends VBoxContainer

func onStepBackPressed() -> void:
	Global.frame -= 1
	Global.advanceFrame.emit()

func onStepForwardPressed() -> void:
	Global.frame += 1
	Global.advanceFrame.emit()

func onPlayPausePressed() -> void:
	var pause = %PlayPause.iconName == "pause"
	%PlayPause.iconName = "play" if pause else "pause"
	%PlayPause.tooltip_text = ("Play" if pause else "Pause") + " Playback"
	Global.playPausePlayback.emit(pause)

func onSpeedSliderValueChanged(value: float) -> void:
	%SpeedSlider.tooltip_text = "Playback Speed: x" + str(value)
	Global.setPlaybackSpeed.emit(value)
