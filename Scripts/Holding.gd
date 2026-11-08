extends Marker3D

@export var PlayerNode: Player

var CurrentPlayerInventory: PlayerInventory
var CurrentSlot: int = -1

var HandsFull: bool = false
var UsableSlotFull: bool = false

var Slot1: InventorySlot
var Slot2: InventorySlot
var Slot3: InventorySlot
var UsableSlot: InventorySlot
var Slot1Value: float



#func _ready() -> void:
	#CurrentPlayerInventory = PlayerNode.player_inventory
	#
	#Slot1 = CurrentPlayerInventory.get_slot(0)
	#Slot2 = CurrentPlayerInventory.get_slot(1)
	#Slot3 = CurrentPlayerInventory.get_slot(2)
	#
	#Slot1.changed.connect(UpdateSlots)
	#Slot2.changed.connect(UpdateSlots)
	#Slot3.changed.connect(UpdateSlots)



func _process(_delta: float) -> void:
	if PlayerNode.is_multiplayer_authority() and not PlayerNode.InputBlocked:
		
		CurrentPlayerInventory = PlayerNode.player_inventory
		Slot1 = CurrentPlayerInventory.get_slot(0)
		Slot2 = CurrentPlayerInventory.get_slot(1)
		Slot3 = CurrentPlayerInventory.get_slot(2)
		UsableSlot = CurrentPlayerInventory.get_slot(3)
		
		#if not Slot1.changed.is_connected(UpdateSlots):
			#Slot1.changed.connect(UpdateSlots)
			#Slot2.changed.connect(UpdateSlots)
			#Slot3.changed.connect(UpdateSlots)
		#
		#
		#
		#if Input.is_action_just_pressed("1"):
			#HandsFull = !HandsFull
			#if get_child_count() > 0:
				#var Equipable: Node3D = get_child(0)
				#if Equipable != null:
					#Equipable.visible = HandsFull
					#if Equipable.has_method("Enable"):
						#Equipable.Enable(HandsFull)
		#
		#if Input.is_action_just_pressed("2"):
			#HandsFull = !HandsFull
			#if get_child_count() > 0:
				#var Equipable: Node3D = get_child(1)
				#if Equipable != null:
					#Equipable.visible = HandsFull
					#if Equipable.has_method("Enable"):
						#Equipable.Enable(HandsFull)
		#
		#if Input.is_action_just_pressed("3"):
			#HandsFull = !HandsFull
			#if get_child_count() > 0:
				#var Equipable: Node3D = get_child(2)
				#if Equipable != null:
					#Equipable.visible = HandsFull
					#if Equipable.has_method("Enable"):
						#Equipable.Enable(HandsFull)
		
		
		
		
		
		
		if Input.is_action_just_pressed("1"):
			print("1 Pressed")
			Equip(1)
		
		if Input.is_action_just_pressed("2"):
			Equip(2)
			
			#if get_child_count() > 0:
				#remove_child(get_child(0))
			#
			#if HandsFull == false:
				#var SlotToId = ItemDatabase.get_item(Slot2.item_id)
				#if Slot2.item_id != "":
					#var SlotItemScene: PackedScene = SlotToId.scene
					#if Slot2 != null and SlotItemScene != null and SlotToId != null:
						#var Equipable: Node3D = SlotItemScene.instantiate()
						#add_child(Equipable, true)
						#CurrentSlot = 1
						#SlotToId.special_value_1 = Slot1Value
						#HandsFull = true
						#if Equipable.has_method("Enable"):
							#Equipable.Enable(HandsFull)
						##rpc(WeaponChanged(Equipable))
					#else:
						#HandsFull = false
						#CurrentSlot = -1
						#Slot1Value = SlotToId.special_value_1
						##rpc(HandsEmptied())
			#else:
				#CurrentSlot = -1
				#HandsFull = false
				##rpc(HandsEmptied())
		
		if Input.is_action_just_pressed("3"):
			Equip(3)   
			
			#if get_child_count() > 0:
				#remove_child(get_child(0))
			#
			#if HandsFull == false:
				#var SlotToId = ItemDatabase.get_item(Slot3.item_id)
				#if Slot3.item_id != "":
					#var SlotItemScene: PackedScene = SlotToId.scene
					#if Slot3 != null and SlotItemScene != null and SlotToId != null:
						#var Equipable: Node3D = SlotItemScene.instantiate()
						#add_child(Equipable, true)
						#CurrentSlot = 2
						#SlotToId.special_value_1 = Slot1Value
						#HandsFull = true
						#if Equipable.has_method("Enable"):
							#Equipable.Enable(HandsFull)
						##rpc(WeaponChanged(Equipable))
					#else:
						#HandsFull = false
						#CurrentSlot = -1
						#Slot1Value = SlotToId.special_value_1
						##rpc(HandsEmptied())
			#else:
				#HandsFull = false
				#CurrentSlot = -1
				##rpc(HandsEmptied())
		
		### Usable slot
		#if Input.is_action_just_pressed("Secondary Ability"):
			#if $"../Usable".get_child_count() > 0:
				#$"../Usable".remove_child($"../Usable".get_child(0))
			#
			#if UsableSlotFull == false:
				#var SlotToId = ItemDatabase.get_item(UsableSlot.item_id)
				#if UsableSlot.item_id != "":
					#var SlotItemScene: PackedScene = SlotToId.scene
					#if UsableSlot != null and SlotItemScene != null and SlotToId != null:
						#var Usable: Node3D = SlotItemScene.instantiate()
						#$"../Usable".add_child(Usable, true)
						#
						#UsableSlotFull = true
						#if Usable.has_method("Enable"):
							#UsableSlot.Enable(UsableSlotFull)
					#else:
						#UsableSlotFull = false
			#else:
				#UsableSlotFull = false
		
		
		
		if Input.is_action_just_pressed("Drop"):
			Drop()



func Equip(Slot: int = 1):
	var UsedSlot = CurrentPlayerInventory.get_slot(Slot - 1)

	if get_child_count() > 0:
		remove_child(get_child(0))
	
	if HandsFull == false:
		var SlotToId = ItemDatabase.get_item(UsedSlot.item_id)
		if UsedSlot.item_id != "":
			var SlotItemScene: PackedScene = SlotToId.scene
			if UsedSlot != null and SlotItemScene != null and SlotToId != null:
				var Equipable: Node3D = SlotItemScene.instantiate()
				add_child(Equipable, true)
				CurrentSlot = Slot - 1
				#SlotToId.special_value_1 = UsedSlotValue
				HandsFull = true
				if Equipable.has_method("Enable"):
					Equipable.Enable(true)
			else:
				HandsFull = false
				#UsedSlotValue = SlotToId.special_value_1
				CurrentSlot = -1
	else:
		HandsFull = false
		CurrentSlot = -1
	
	
	
	print("Slot ", Slot, " equipped: ", HandsFull)



func UpdateSlots():
	var SlotToId = ItemDatabase.get_item(Slot1.item_id)
	if Slot1.item_id != "":
		var SlotItemScene: PackedScene = SlotToId.scene
		if Slot1 != null and SlotItemScene != null and SlotToId != null:
			var Equipable: Node3D = SlotItemScene.instantiate()
			add_child(Equipable, true)
			if CurrentPlayerInventory.get_slot(CurrentSlot) != Slot1:
				Equipable.visible = false
	SlotToId = ItemDatabase.get_item(Slot2.item_id)
	if Slot2.item_id != "":
		var SlotItemScene: PackedScene = SlotToId.scene
		if Slot2 != null and SlotItemScene != null and SlotToId != null:
			var Equipable: Node3D = SlotItemScene.instantiate()
			add_child(Equipable, true)
			if CurrentPlayerInventory.get_slot(CurrentSlot) != Slot2:
				Equipable.visible = false
	SlotToId = ItemDatabase.get_item(Slot3.item_id)
	if Slot3.item_id != "":
		var SlotItemScene: PackedScene = SlotToId.scene
		if Slot3 != null and SlotItemScene != null and SlotToId != null:
			var Equipable: Node3D = SlotItemScene.instantiate()
			add_child(Equipable, true)
			if CurrentPlayerInventory.get_slot(CurrentSlot) != Slot3:
				Equipable.visible = false



func Drop():
	if HandsFull and CurrentSlot != -1:
		var SelectedSlot = CurrentPlayerInventory.get_slot(CurrentSlot)
		if not SelectedSlot.is_empty():
			var SelectedItem = ItemDatabase.get_item(SelectedSlot.item_id)
			if SelectedItem.scene != null:
				var DroppedItem: Node3D = SelectedItem.scene.instantiate()
				Global.ObjectSpawner.add_child(DroppedItem, true)
				DroppedItem.global_position = global_position
				if DroppedItem.has_method("Enable"):
					DroppedItem.Enable(false)
			SelectedSlot.remove_item(1)
			if get_child_count() > 0:
				remove_child(get_child(0))
			HandsFull = false



func ClearHands():
	if get_child_count() > 0:
		remove_child(get_child(0))
	CurrentSlot = -1
	HandsFull = false
