class_name HealthComponent
extends Node

@export_range(0.0, 200.0, 1.0) var _max_health: float = 100.0
@export_range(0.0, 100.0, 1.0) var _health: float = 100.0
@export_range(0.0, 5.0, 0.1) var _health_regen_value: float = 1.5

@export var character_overlap: Area3D

@onready var health_regen_timer: Timer = %HealthRegenTimer
@onready var health_regen_delay_timer: Timer = %HealthRegenDelayTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if character_overlap:
		character_overlap.body_entered.connect(_on_damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_damage(body: Node3D) -> void:
	if body.owner.is_in_group("Damage"):
		var body_damage_comp: DamageComponent = body.get_node("../DamageComponent")
		if body_damage_comp:
			print("Damage on: ", owner.name)
			_health -= body_damage_comp.damage_value
			## Will restart the timer if damaged within Delay Window
			print("Begin Regen Delay")
			health_regen_timer.stop()
			health_regen_delay_timer.start(-1)
		else:
			printerr("Object does not contain Damage Component")
	else:
		print("Not in Damage Group")


func _on_health_regen_timer_timeout() -> void:
	if _health < _max_health:
		_health = clampf(_health + _health_regen_value, 0, _max_health)
	if _health == _max_health:
		health_regen_timer.stop()
	print("Owner Health: ", _health)


func _on_health_regen_delay_timer_timeout() -> void:
	print("Begin Regen")
	health_regen_timer.start()
