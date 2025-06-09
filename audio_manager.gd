extends Node

@onready var background_music: AudioStreamPlayer = $"Background Music"

func play_background_music(music_track: AudioStreamWAV, volume: float = 0.0, pitch: float = 1.0) -> void:
	background_music.stream = music_track
	background_music.volume_db = volume
	background_music.pitch_scale = pitch
	background_music.stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD
	background_music.stream.loop_begin = 0 * music_track.mix_rate
	background_music.stream.loop_end = music_track.get_length() * music_track.mix_rate
	background_music.play()

func stop_background_music() -> void:
	background_music.stop()

func play_sfx(sfx_stream: AudioStream, volume: float = 0.0, pitch: float = 1.0, pitch_randomness: float = 0.0):
	var new_sfx = AudioStreamPlayer2D.new()
	new_sfx.stream = sfx_stream
	new_sfx.volume_db = volume
	new_sfx.pitch_scale = pitch
	new_sfx.pitch_scale += randf_range(-pitch_randomness, pitch_randomness)
	new_sfx.bus = "SFX"
	add_child(new_sfx)
	new_sfx.play()
	new_sfx.finished.connect(new_sfx.queue_free)
