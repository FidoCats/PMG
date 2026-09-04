extends Marker3D

var CurrentPlayerInventory: PlayerInventory
var CurrentSlot: int = -1

var HandsFull: bool = false
var UsableSlotFull: bool = false

var Slot1: InventorySlot
var Slot2: InventorySlot
var Slot3: InventorySlot
var UsableSlot: InventorySlot

var IsMultiplayerAuthority: bool



#func _enter_tree():
	#set_multiplayer_authority(str(name).to_int())



func _process(_delta: float) -> void:
	IsMultiplayerAuthority = $"../..".is_multiplayer_authority()
	
	if not IsMultiplayerAuthority: return # the switched guns dont work on client side !!!!
	
	CurrentPlayerInventory = $"../..".player_inventory
	Slot1 = CurrentPlayerInventory.get_slot(0)
	Slot2 = CurrentPlayerInventory.get_slot(1)
	Slot3 = CurrentPlayerInventory.get_slot(2)
	UsableSlot = CurrentPlayerInventory.get_slot(3)
	
	
	
	if Input.is_action_just_pressed("1"):
		if get_child_count() > 0:
			remove_child(get_child(0))
		
		if HandsFull == false:
			var SlotToId = ItemDatabase.get_item(Slot1.item_id)
			if Slot1.item_id != "":
				var SlotItemScene: PackedScene = SlotToId.scene
				if Slot1 != null and SlotItemScene != null and SlotToId != null:
					var Equipable: Node3D = SlotItemScene.instantiate()
					add_child(Equipable)
					CurrentSlot = 0
					HandsFull = true
					#rpc(WeaponChanged(Equipable))
				else:
					HandsFull = false
					CurrentSlot = -1
					#rpc(HandsEmptied())
		else:
			HandsFull = false
			CurrentSlot = -1
			#rpc(HandsEmptied())
	
	if Input.is_action_just_pressed("2"):
		if get_child_count() > 0:
			remove_child(get_child(0))
		
		if HandsFull == false:
			var SlotToId = ItemDatabase.get_item(Slot2.item_id)
			if Slot2.item_id != "":
				var SlotItemScene: PackedScene = SlotToId.scene
				if Slot2 != null and SlotItemScene != null and SlotToId != null:
					var Equipable: Node3D = SlotItemScene.instantiate()
					add_child(Equipable)
					CurrentSlot = 1
					HandsFull = true
					#rpc(WeaponChanged(Equipable))
				else:
					CurrentSlot = -1
					HandsFull = false
					#rpc(HandsEmptied())
		else:
			CurrentSlot = -1
			HandsFull = false
			#rpc(HandsEmptied())
	
	if Input.is_action_just_pressed("3"):
		if get_child_count() > 0:
			remove_child(get_child(0))
		
		if HandsFull == false:
			var SlotToId = ItemDatabase.get_item(Slot3.item_id)
			if Slot3.item_id != "":
				var SlotItemScene: PackedScene = SlotToId.scene
				if Slot3 != null and SlotItemScene != null and SlotToId != null:
					var Equipable: Node3D = SlotItemScene.instantiate()
					add_child(Equipable)
					CurrentSlot = 2
					HandsFull = true
					#rpc(WeaponChanged(Equipable))
				else:
					CurrentSlot = -1
					HandsFull = false
					#rpc(HandsEmptied())
		else:
			HandsFull = false
			CurrentSlot = -1
			#rpc(HandsEmptied())
	
	## Usable slot
	if Input.is_action_just_pressed("Secondary Ability"):
		if $"../Usable".get_child_count() > 0:
			$"../Usable".remove_child($"../Usable".get_child(0))
		
		if UsableSlotFull == false:
			var SlotToId = ItemDatabase.get_item(UsableSlot.item_id)
			if UsableSlot.item_id != "":
				var SlotItemScene: PackedScene = SlotToId.scene
				if UsableSlot != null and SlotItemScene != null and SlotToId != null:
					var Usable: Node3D = SlotItemScene.instantiate()
					$"../Usable".add_child(Usable)
					UsableSlotFull = true
				else:
					UsableSlotFull = false
		else:
			UsableSlotFull = false
	
	if Input.is_action_just_pressed("Drop"):
		if HandsFull and CurrentSlot != -1:
			var SelectedSlot = CurrentPlayerInventory.get_slot(CurrentSlot)
			SelectedSlot.remove_item(1)
			if get_child_count() > 0:
				remove_child(get_child(0))


@rpc("any_peer")
func WeaponChanged(_Weapon: Node3D):
	pass

@rpc("any_peer")
func HandsEmptied():
	pass

@rpc("any_peer")
func WeaponDropped(_DroppedWeapon: Node3D):
	pass
