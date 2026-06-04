extends AudioStreamPlayer

var playback: AudioStreamPlaybackPolyphonic
@export var audio: Dictionary[StringName, AudioStream]

func _ready() -> void:
	play()
	playback = get_stream_playback()
	
func play_sfx(name: StringName):
	var stream = audio.get(name)
	assert(stream != null, "You tried to play %s while existing audios are %s" % [name, audio.keys()])
	playback.play_stream(stream)
