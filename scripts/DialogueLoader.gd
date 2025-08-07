extends Node

var passages = {}
var start_pid = ""

func load_twison(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())

	for passage in json_data["passages"]:
		passages[passage["pid"]] = passage
	start_pid = json_data["startnode"]
