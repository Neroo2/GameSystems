extends Node
class_name SoundManager

@export var audios: Dictionary = {
	"steam_audio":
		"res://sounds/weapons/steam_audio.wav",

}


func play_audio(audio_name: String, min_pitch: float, max_pitch: float):
	if !audios.has(audio_name):
		return
	

	
	var audioPlayer = AudioStreamPlayer.new()
	var audio = load(audios[audio_name])
	audioPlayer.stream = audio
	audioPlayer.pitch_scale = randf_range(min_pitch, max_pitch)
	add_child(audioPlayer)
	audioPlayer.play()
	
	await  audioPlayer.finished
	audioPlayer.queue_free()
