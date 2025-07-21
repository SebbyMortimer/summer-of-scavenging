extends MeshInstance3D

const SPEED = 0.5


func _process(delta: float) -> void:
	mesh.material.uv1_offset += Vector3(1, 1, 0) * SPEED * delta
