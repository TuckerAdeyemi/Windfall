extends Resource
class_name Quest

@export var id: String = ""       # Unique key for saves/flags
@export var title: String = ""    # Display name
@export var description: String = ""  # Flavor text
@export var requirements: Dictionary = {} # e.g. { "kill_slimes": 5 }
@export var rewards: Dictionary = {}     # e.g. { "gold": 100, "item": "Potion" }
@export var is_main: bool = false        # Story quest or side request?
