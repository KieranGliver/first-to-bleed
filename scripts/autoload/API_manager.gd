extends Node

signal request_completed(success: bool, response_code: int, response_body: String)

const BASE_URL = "https://firsttobleed-api.onrender.com"
const API_KEY = "8012199c-93d7-4bfd-95fd-e3c9ec716d23"

func post_http(endpoint: String, data: Dictionary) -> void:
	var url = BASE_URL + endpoint
	var json_body = JSON.stringify(data)
	var headers = [
		"Content-Type: application/json",
		"X-API-Key: " + API_KEY
	]

	var request_node = HTTPRequest.new()
	add_child(request_node)
	request_node.request_completed.connect(self._on_temp_request_completed.bind(request_node))
	var err = request_node.request(url, headers, HTTPClient.METHOD_POST, json_body)

	if err != OK:
		request_node.queue_free()
		request_completed.emit(false, 0, "Failed to start request")

func get_http(endpoint: String, query: Dictionary = {}, callable: Callable = func():return) -> void:
	var url = BASE_URL + endpoint
	if not query.is_empty():
		var parts = []
		for key in query.keys():
			parts.append(str(key) + "=" + str(query[key]))
		url += "?" + "&".join(parts)
	var headers = [
		"X-API-Key: " + API_KEY
	]

	var request_node = HTTPRequest.new()
	add_child(request_node)
	request_node.request_completed.connect(self._on_temp_request_completed.bind(request_node))
	request_node.request_completed.connect(callable)
	var err = request_node.request(url, headers, HTTPClient.METHOD_GET)

	if err != OK:
		request_node.queue_free()
		request_completed.emit(false, 0, "Failed to start GET request")

func _on_temp_request_completed(_result, response_code, _headers, body, request_node):
	remove_child(request_node)
	request_node.queue_free()

	var body_text = body.get_string_from_utf8()
	var success = response_code >= 200 and response_code < 300

	request_completed.emit(success, response_code, body_text)
