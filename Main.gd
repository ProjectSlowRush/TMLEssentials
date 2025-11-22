extends Control

const PREVIEW_PANEL = preload("uid://c8xuk4t0oy2w3")

@onready var previewContainer: ScrollContainer = $VBoxContainer/HBoxContainer/HSplitContainer/MarginContainer/ScrollContainer2
@export var playbackControls: PlaybackControls

var directory: String
var textureFiles: Array[String]

func _ready() -> void:
	get_window().focus_entered.connect(func():
		for i in %PreviewContainer.get_children():
			var panel = i as PreviewPanel
			panel.reloadTextures()
		)
	%HTTPRequest.request("https://api.github.com/repos/EtherealCrusaders/TMLEssentials/releases/latest", ["User-Agent: GodotGame"])

	previewContainer.custom_minimum_size.x = get_viewport().get_visible_rect().size.x * 0.5
	Global.deletePreview.connect(func(newCount: int):
		if newCount <= 0:
			playbackControls.hide()
			%Tooltip.show()
		)

	Global.maximizePreview.connect(func(preview: PreviewPanel):
		%Popup.show()
		%MaximizedPreviewContainer.show()

		var panel = PREVIEW_PANEL.instantiate() as PreviewPanel
		panel.textures = preview.textures
		panel.shouldArmsResize = preview.shouldArmsResize
		panel.armSize = preview.armSize
		panel.isMaximized = true
		playbackControls.reparent(panel)
		%MaximizedPreviewContainer.add_child(panel)
		)

	Global.playPausePlayback.connect(func(paused: bool):
		%AnimationTimer.paused = paused
		)

	Global.setPlaybackSpeed.connect(func(speed: float):
		%AnimationTimer.wait_time = 0.05 / speed
		)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		hidePopup()

func onChooseDirectoryPressed() -> void:
	%FileDialog.current_dir = directory
	%FileDialog.show()
	%ChooseDirectory.disabled = true

func onFileDialogDirSelected(dir: String) -> void:
	%ChooseDirectory.disabled = false
	directory = dir
	textureFiles = getImageFilesFromDirectory(dir)

	for i in %TextureList.get_children():
		i.queue_free()

	%SearchFiles.text = ""
	%InfoContainer.visible = len(textureFiles) > 0
	%Tooltip.text = "Select desired textures to create a preview. Each preview can have at most one of each EquipType" if len(textureFiles) > 0 else "[color=red]You selected a directory with no valid image files. Only those with an EquipType suffixed in its name (e.g. x_Head) can be used."

	for i in textureFiles:
		var checkbox = CheckBox.new()
		checkbox.text = i.split("/")[-1]
		checkbox.set_meta("fullPath", i)
		checkbox.connect("toggled", Callable(self, "onTextureCheckBoxToggled").bind(checkbox))
		%TextureList.add_child(checkbox)

func onFileDialogCanceled() -> void:
	%ChooseDirectory.disabled = false

func getImageFilesFromDirectory(dir: String) -> Array[String]:
	var result: Array[String] = []
	var dirAccess := DirAccess.open(dir)
	if dirAccess == null:
		return result

	dirAccess.list_dir_begin()
	var file := dirAccess.get_next()
	while file != "":
		if dirAccess.current_is_dir():
			result.append_array(getImageFilesFromDirectory(dir + "/" + file))
		else:
			if "." + file.get_extension().to_lower() in [".png", ".jpg", ".jpeg"] and Global.EquipType.keys().any(func(e): return file.get_basename().ends_with("_" + e)):
				result.append(dir + "/" + file)
		file = dirAccess.get_next()
	dirAccess.list_dir_end()

	return result

func onTextureCheckBoxToggled(toggled_on: bool, checkbox: CheckBox) -> void:
	%CreatePreviewContainer.visible = %TextureList.get_children().any(func(e): return e.button_pressed)
	for i in %TextureList.get_children().filter(func(e): return e != checkbox and e.text.split("_")[-1] == checkbox.text.split("_")[-1]):
		i.disabled = toggled_on

func onCreatePreviewPressed() -> void:
	var preview := PREVIEW_PANEL.instantiate() as PreviewPanel
	preview.textures = %TextureList.get_children().filter(func(e): return e.button_pressed).map(func(e): return e.get_meta("fullPath"))
	%PreviewContainer.add_child(preview)
	%Tooltip.hide()
	playbackControls.visible = true

	for i in %TextureList.get_children():
		i.button_pressed = false

func onAnimationTimerTimeout() -> void:
	Global.frame += 1
	Global.advanceFrame.emit()

func onHttpRequestRequestCompleted(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return

	var latest_tag = JSON.parse_string(body.get_string_from_utf8())["tag_name"]
	var current_version = ProjectSettings.get_setting("application/config/version")
	if latest_tag != current_version:
		%Popup.visible = true

func onPopupGuiInput(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouseEvent := event as InputEventMouseButton
	if mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed:
		hidePopup()

func hidePopup():
	%Popup.hide()
	%UpdatePanel.hide()
	playbackControls.reparent(%PlaybackControlsContainer)
	for i in %MaximizedPreviewContainer.get_children():
		i.queue_free()

	%MaximizedPreviewContainer.hide()

func onSearchFilesTextChanged(new_text: String) -> void:
	for i in %TextureList.get_children():
		if new_text == "":
			i.show()
			continue

		var button = i as CheckBox
		var shouldHide = new_text not in button.text.to_lower()
		if shouldHide and button.button_pressed:
			button.button_pressed = false
		button.visible = not shouldHide
