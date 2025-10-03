extends Abilities

class_name Magic

@export_enum("Neutral", "Fire", "Ice", "Lightning", "Earth", "Wind", "Light", "Dark", "Time") var element: String = "Neutral"
@export_enum("Black", "Grey", "White") var magic_type: String = "Black"#Black (Offensive) or White (Defensive) or Grey (Other)
@export var tier: int = 1


const ELEMENT_ORDER = {
	"Fire": 0,
	"Wind": 1,
	"Ice": 2,
	"Lightning": 3,
	"Earth": 4,
	"Light": 5,
	"Dark": 6,
	"Time": 7,
	"Neutral": 99
}

const type_order := {
		"Black": 0,
		"White": 1,
		"Grey": 2
	}
