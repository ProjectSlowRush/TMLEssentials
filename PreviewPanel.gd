class_name PreviewPanel extends PanelContainer

var directory: String
var textures: Array
var shouldArmsResize := true
var armSize: int:
	set(value):
		if armSize != value:
			setArmFrame(value)

		armSize = value

func _ready() -> void:
	Global.advanceFrame.connect(advanceFrame)

	for texture in textures:
		var equipType = texture.get_basename().split("_")[-1]
		var image := Image.new()
		if image.load(directory + "/" + texture) != OK:
			continue

		for container in [%IdleFrameContainer, %JumpFrameContainer, %WalkingAnimationContainer, %SwingingAnimationContainer] as Array[Node]:
			var framePosition = Vector2.ZERO
			var jump = container == %JumpFrameContainer
			var showShoulders = container in [%IdleFrameContainer, %WalkingAnimationContainer]

			if equipType != "Body":
				framePosition = Vector2(0, 5) if jump else Vector2.ZERO
				createTexture(image, directory + "/" + texture, equipType, framePosition, container)
			else:
				if showShoulders:
					createTexture(image, directory + "/" + texture, "BackShoulder", Vector2.ONE, container)
				createTexture(image, directory + "/" + texture, "BackArm", Vector2(2, 3 if jump else 2), container)
				createTexture(image, directory + "/" + texture, equipType, Vector2.RIGHT if jump else Vector2.ZERO, container)
				createTexture(image, directory + "/" + texture, "FrontArm", Vector2(2, 1 if jump else 0), container)
				if showShoulders:
					createTexture(image, directory + "/" + texture, "FrontShoulder", Vector2.DOWN, container)

			var textureRects = container.get_children()
			textureRects.sort_custom(func(a, b): return Global.DrawnFrames.keys().find(a.name) > Global.DrawnFrames.keys().find(b.name))

			for i in container.get_children():
				container.move_child(i, textureRects.find(i))

func _process(_delta: float) -> void:
	armSize = 3 - floor(clampf(get_global_mouse_position().distance_to(%IdleFrameContainer.global_position) / 512.0, 0.0, 1.0) * 3)

func onShowIdleFrameToggled(toggled_on: bool) -> void:
	%IdleFrameContainer.visible = toggled_on

func onShowJumpFrameToggled(toggled_on: bool) -> void:
	%JumpFrameContainer.visible = toggled_on

func onShowWalkingAnimationToggled(toggled_on: bool) -> void:
	%WalkingAnimationContainer.visible = toggled_on

func onShowSwingingAnimationToggled(toggled_on: bool) -> void:
	%SwingingAnimationContainer.visible = toggled_on

func advanceFrame():
	for container in [%WalkingAnimationContainer, %SwingingAnimationContainer] as Array[Node]:
		var walk := container == %WalkingAnimationContainer
		for textureRect in container.get_children():
			var framePosition = -Vector2.ONE
			if textureRect.name in ["Head", "Legs"]:
				framePosition = Vector2(0, ((Global.frame % 13) + 7) if walk else 0)
			elif textureRect.name in ["BackArm", "FrontArm"]:
				framePosition = Vector2(([0, 1, 1, 1, 1, 0, 0, 0, 2, 3, 3, 2, 0][Global.frame % 13] if walk else [0, 1, 2, 3][Global.frame % 8 * 0.5]) + 3, (1 if walk else 0) + (2 if textureRect.name == "BackArm" else 0))

			if framePosition != -Vector2.ONE:
				textureRect.texture.region = Rect2(framePosition.x * 40, framePosition.y * 56, 40, 56)

			if walk and textureRect.name not in ["Head", "Legs"] and (Global.frame % 13) in [0, 1, 2, 7, 8, 9]:
				textureRect.texture.margin = Rect2(0, -2, 0, 0)
			else:
				textureRect.texture.margin = Rect2(0, 0, 0, 0)

func createTexture(image: Image, fullPath: String, equipType: String, framePosition: Vector2, container: Node):
	var atlasTexture := AtlasTexture.new()
	atlasTexture.atlas = ImageTexture.create_from_image(image)

	atlasTexture.region = Rect2(framePosition.x * 40, framePosition.y * 56, 40, 56)

	var textureRect := TextureRect.new()
	textureRect.name = equipType
	textureRect.set_meta("fullPath", fullPath)
	textureRect.texture = atlasTexture
	textureRect.set_anchors_preset(Control.PRESET_FULL_RECT)
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(textureRect)

func onDeletePressed() -> void:
	Global.deletePreview.emit(get_parent().get_child_count() - 1)
	queue_free()

func onRotateResizeArmsToggled(toggled_on: bool) -> void:
	shouldArmsResize = toggled_on
	setArmFrame(armSize)

func setArmFrame(frame: int):
	for i in %IdleFrameContainer.get_children().filter(func(e): return e.name in ["BackArm", "FrontArm"]):
		i.texture.region = Rect2(((7 if i.name == "FrontArm" else 8) if shouldArmsResize else 2) * 40, ((frame if shouldArmsResize else (2 if i.name == "BackArm" else 0))) * 56, 40, 56)

func reloadTextures():
	for texture in textures:
		var image := Image.new()
		if image.load(directory + "/" + texture) != OK:
			continue

		for container in [%IdleFrameContainer, %JumpFrameContainer, %WalkingAnimationContainer, %SwingingAnimationContainer] as Array[Node]:
			for textureRect in container.get_children().filter(func(e): return e.get_meta("fullPath") == directory + "/" + texture):
				textureRect.texture.atlas = ImageTexture.create_from_image(image)
