extends AudioStreamPlayer

var playback: AudioStreamPlaybackPolyphonic
@export var audio: Dictionary[StringName, AudioStream]

func _ready() -> void:
	play()
	playback = get_stream_playback()
	
func play_sound(sound_name: StringName):
	var stream_found = audio.get(sound_name)
	assert(stream_found != null, "You tried to play %s while existing audios are %s" % [sound_name, audio.keys()])
	playback.play_stream(stream_found)
