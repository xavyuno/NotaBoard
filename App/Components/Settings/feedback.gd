extends TextEdit

@onready var submit_req: HTTPRequest = $"../Top/SubmitFeedback/SubmitReq"

func _on_submit_feedback_pressed() -> void:
	if text == "":
		return
	submit_req.request(System.GetAPI(0), ["Content-type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"content" :
		text + "\n-# " + $"../../../../Version".text}))

func _on_submit_req_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code == 204:
		System.CreateNotif("Thank you for your feedback! :)")
	else :
		System.CreateNotif("Failed to submit feedback", true)
