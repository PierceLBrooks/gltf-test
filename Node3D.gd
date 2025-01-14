extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello, world!")
	var file = FileAccess.open("res://weight.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var result = json.parse(content.strip_edges())
	if (result != OK):
		print("ERROR0 = "+str(result.error_line))
		return
	var weights = json.data
	if (len(weights) < 2):
		return
	var bones = {}
	for key in weights[0]:
		bones[weights[0][key]] = int(key)
	weights.pop_front()
	var state = GLTFState.new()
	var document = GLTFDocument.new()
	var error = document.append_from_file("res://untitled.gltf", state, 0)
	if (error != OK):
		print("ERROR1 = "+str(error))
		return
	var nodes = state.get_nodes()
	for i in range(len(nodes)):
		var node = nodes[i]
		var mesh = node.get_mesh()
		node.set_skeleton(-1)
		if (mesh < 0):
			continue
		mesh = state.get_meshes()[mesh].get_mesh()
		for j in range(mesh.get_surface_count()):
			var surface = mesh.get_surface_arrays(j)
			if ((surface == null) or (len(surface) <= Mesh.ARRAY_WEIGHTS)):
				continue
			var verticesCount = len(surface[Mesh.ARRAY_VERTEX])
			if (verticesCount < len(weights)):
				print(str(len(weights))+" | "+str(verticesCount))
				continue
			surface = surface[Mesh.ARRAY_WEIGHTS]
			if (surface == null):
				surface = []
			if (len(surface) <= verticesCount):
				var weightsCount = verticesCount/len(weights[0])
				print(str(j)+" @ "+str(i)+" = "+str(weightsCount))
				#for k in range(len(weights))
				break
	var child = document.generate_scene(state)
	state = GLTFState.new()
	error = document.append_from_file("res://../untitled.gltf", state, 32)
	if (error != OK):
		print("ERROR2 = "+str(error))
		return
	nodes = state.get_nodes()
	for i in range(len(nodes)):
		var node = nodes[i]
		node.set_mesh(-1)
		if (node.get_skeleton() >= 0):
			var skeleton = state.get_skeletons()[node.get_skeleton()]
			var roots = skeleton.get_roots()
			if not (roots.has(i)):
				continue
		print(str(i)+" = "+node.resource_name)
		print("\t"+str(node.get_mesh()))
		print("\t"+str(node.get_skin()))
		print("\t"+str(node.get_skeleton()))
		if (node.get_skeleton() >= 0):
			var skeleton = state.get_skeletons()[node.get_skeleton()]
			var roots = skeleton.get_roots()
			var joints = skeleton.get_joints()
			for j in range(len(roots)):
				print("\t\t"+str(roots[j]))
			for j in range(len(joints)):
				print("\t\t"+str(joints[j])+" = "+nodes[joints[j]].resource_name)
		if (node.get_mesh() >= 0):
			var mesh = state.get_meshes()[node.get_mesh()].get_mesh()
			print("\t\t"+str(mesh.get_surface_count()))
			for j in range(mesh.get_surface_count()):
				var surface = mesh.get_surface_arrays(j)
				if ((surface == null) or (len(surface) <= Mesh.ARRAY_WEIGHTS)):
					surface = []
				print("\t\t\t"+str(j)+" = "+str(len(surface[Mesh.ARRAY_WEIGHTS])))
	var scene = document.generate_scene(state)
	var meshes = child.find_children("", "MeshInstance3D", true)
	var skeletons = scene.find_children("", "Skeleton3D", true)
	print(str(meshes))
	print(str(skeletons))
	child.add_child(scene)
	add_child(child)
	for i in range(len(meshes)):
		if (i >= len(skeletons)):
			break
		var skin = Skin.new()
		var skeleton = skeletons[i]
		var path = NodePath(skeleton.get_path())
		for j in range(skeleton.get_bone_count()):
			skin.add_named_bind(skeleton.get_bone_name(j), skeleton.get_bone_rest(j))
		meshes[i].skeleton = path
		meshes[i].skin = skin
	print(str(get_world_3d()))
	for children in get_children():
		print(str(children.get_world_3d()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
