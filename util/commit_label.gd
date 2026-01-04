extends Label

@export var branch: String = "main"

const REPO_OWNER: String = "Charpurrr"
const REPO_NAME: String = "SuperMarioSolarEngine"

var http_request: HTTPRequest = HTTPRequest.new()

var remote_sha: String = "~ Fetching ~"
var local_sha: String = "~ Fetching ~"


func _ready() -> void:
	_set_remote_sha()
	await http_request.request_completed
	_set_local_sha()

	text = "~ %s%s ~" % [local_sha, " ⚠️" if local_sha != remote_sha else ""]


func _set_remote_sha() -> void:
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	add_child(http_request)

	var url: String = "https://api.github.com/repos/%s/%s/commits/%s" % [REPO_OWNER, REPO_NAME, branch]
	http_request.request(url)


func _on_request_completed(
		_result: int,
		response_code: int,
		_headers: PackedStringArray,
		body: PackedByteArray
	) -> void:
	if response_code == 200:
		var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

		if json.has("sha"):
			remote_sha = json["sha"].left(7)
		else:
			push_warning("Failed to parse commit SHA")
	else:
		push_warning("Failed to fetch commit SHA, response code: ", response_code)


func _set_local_sha() -> void:
	var file: FileAccess = FileAccess.open("res://.git/HEAD", FileAccess.READ)

	if not file:
		push_warning("Failed to open .git/HEAD.")
		return

	var ref: String = file.get_line().replace("ref: ", "").strip_edges()
	var sha_file: FileAccess = FileAccess.open("res://.git/" + ref, FileAccess.READ)

	if sha_file:
		local_sha = sha_file.get_line().strip_edges().left(7)
	else:
		push_warning("Failed to read commit SHA from ref.")

	return
