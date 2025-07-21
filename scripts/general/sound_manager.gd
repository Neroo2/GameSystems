extends Node
class_name SoundManager

var audios: Dictionary = {
	"vector_shoot":
		"res://sounds/weapons/vector2.wav",
	
}

func _ready() -> void:
	play_audio("vector_shoot")

func play_audio(audio_name: String):
	if !audios.has(audio_name):
		return
	
	
	
	var audioPlayer = AudioStreamPlayer.new()
	var audio = load(audios[audio_name])
	audioPlayer.stream = audio
	add_child(audioPlayer)
	audioPlayer.play()
	
	await  audioPlayer.finished
	audioPlayer.queue_free()
