extends Node

## Lightweight procedural blips so the runner has feedback without asset files.

var _player: AudioStreamPlayer
var _stream_jump: AudioStream
var _stream_collect: AudioStream
var _stream_hit: AudioStream
var _stream_slide: AudioStream


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	_stream_jump = _make_tone(420.0, 0.075, 0.2)
	_stream_collect = _make_tone(720.0, 0.055, 0.18)
	_stream_hit = _make_tone(95.0, 0.14, 0.35)
	_stream_slide = _make_tone(280.0, 0.06, 0.15)


func play_jump() -> void:
	_play(_stream_jump)


func play_collect() -> void:
	_play(_stream_collect)


func play_hit() -> void:
	_play(_stream_hit)


func play_slide() -> void:
	_play(_stream_slide)


func _play(stream: AudioStream) -> void:
	if stream == null or _player == null:
		return
	_player.stream = stream
	_player.play()


func _make_tone(freq_hz: float, duration_sec: float, volume_linear: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var n: int = maxi(1, int(sample_rate * duration_sec))
	var data := PackedByteArray()
	data.resize(n * 2)
	var amp := volume_linear * 0.22 * 32767.0
	for i in n:
		var t := float(i) / float(sample_rate)
		var s := sin(TAU * freq_hz * t) * amp
		var v: int = int(clampf(s, -32768.0, 32767.0))
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
