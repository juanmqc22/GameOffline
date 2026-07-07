class_name BlockBuilder
extends RefCounted
## Helper estático pra montar visuais de caixas (estilo Minecraft) em código —
## mesma filosofia da UI procedural: sem assets externos, fácil de revisar à mão.


static func box(parent: Node3D, box_size: Vector3, box_position: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = box_size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position = box_position
	parent.add_child(mesh_instance)
	return mesh_instance


## Nó vazio usado como pivô de animação (ombro, quadril) — a caixa filha fica
## deslocada pra baixo, então girar o pivô balança o membro.
static func pivot(parent: Node3D, pivot_position: Vector3) -> Node3D:
	var node := Node3D.new()
	node.position = pivot_position
	parent.add_child(node)
	return node
