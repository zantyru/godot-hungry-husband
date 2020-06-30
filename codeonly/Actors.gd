extends Reference
class_name Actors


const Dog: PackedScene = preload("res://scenes/Actor_Dog.tscn")
const Husband: PackedScene = preload("res://scenes/Actor_Husband.tscn")

const ENEMIES: Array = [
    Dog,
]
const PLAYABLE: Array = [
    Husband,
]