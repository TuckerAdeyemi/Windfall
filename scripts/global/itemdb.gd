extends Node

# Consumables
var potion: Item = preload("res://items/potion.tres")
var hipotion: Item = preload("res://items/Hi-Potion.tres")
var antidote: Item = preload("res://items/Antidote.tres")
var elixir: Item = preload("res://items/Elixir.tres")

# Weapons
var fe_sword: Item = preload("res://items/weapons/iron_sword.tres")
var fe_dagger: Item = preload("res://items/weapons/iron_dagger.tres")
var fe_lance: Item = preload("res://items/weapons/iron_lance.tres")
var fe_rod: Item = preload("res://items/weapons/iron_rod.tres")
var ragna: Item = preload("res://items/weapons/ragnarok.tres")
var zeph: Item = preload("res://items/weapons/Zephyros.tres")

# === Lookup Table ===
var item_table: Dictionary = {}

func _ready():
	# Register all items by name
	item_table = {
		potion.name: potion,
		hipotion.name: hipotion,
		antidote.name: antidote,
		elixir.name: elixir,
		fe_sword.name: fe_sword,
		fe_dagger.name: fe_dagger,
		fe_lance.name: fe_lance,
		fe_rod.name: fe_rod,
		ragna.name: ragna,
		zeph.name: zeph,
	}

# === Get item by name (used in save/load) ===
func get_item(name: String) -> Item:
	if item_table.has(name):
		return item_table[name]
	return null
