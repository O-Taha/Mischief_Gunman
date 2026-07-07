extends AudioStreamPlayer

var playback: AudioStreamPlaybackPolyphonic
@export var audio: Dictionary[StringName, AudioStream]

signal sound_emitted(volume: int, global_position: Vector2) # used by opponent


func _ready() -> void:
	play()
	playback = get_stream_playback()
	
# Setting sound_volume to -1 means the sound directly set opponent to MAX_ALERT, 
# no matter the position, useful for gunshots
func play_sound(sound_name: StringName, sound_volume: int, global_position: Vector2):
	var stream_found = audio.get(sound_name)
	assert(stream_found != null, "You tried to play %s while existing audios are %s" % [sound_name, audio.keys()])
	
	var db_volume: float = log(sound_volume*1000000)/log(10)
	if is_nan(db_volume) or is_inf(db_volume): db_volume = 0 # probably due to volume = -1 from gunshot
	playback.play_stream(stream_found, 0, db_volume*1.5)
	sound_emitted.emit(sound_volume, global_position)
