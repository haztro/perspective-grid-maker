extends Camera
class_name Camera360


enum Lens {RECTILINEAR, PANINI, FISHEYE, STEREOGRAPHIC, CYLINDRICAL,
		EQUIRECTANGULAR, MERCATOR}


export (float, 10, 360) var fovx = 150 setget set_fovx
export (Lens) var lens = 0 setget set_lens
export (int, 1, 16384) var camera_resolution = 1080
export (float, 0.001, 10) var clip_near = 0.1
export (float, 0.01, 10000) var clip_far = 1000
export (int, 1, 6) var num_cameras = 6
export (int, 1, 20) var render_layer = 11
export (Environment) var camera_environment

var viewports = []
var cameras = []

var render_quad: MeshInstance = null
var mat = ShaderMaterial.new()


func _ready():
	render_layer = int(pow(2, render_layer - 1))
	cull_mask = render_layer
	
	render_quad = MeshInstance.new()
	add_child(render_quad)
	render_quad.translate_object_local(Vector3.FORWARD * (near + 0.1 * (far - near)))
	render_quad.rotate_object_local(Vector3.RIGHT, PI / 2)
	render_quad.mesh = QuadMesh.new()
	render_quad.mesh.size = Vector2(2, 2)
	render_quad.layers = render_layer
	render_quad.mesh.surface_set_material(0, mat)
	
	mat.shader = load(get_script().resource_path.replace(".gd", ".shader"))
	mat.set_shader_param("fovx", fovx)
	mat.set_shader_param("lens", lens)
#	mat.set_shader_param("resolution", camera_resolution)
	
	for i in range(num_cameras):
		var viewport = Viewport.new()
		add_child(viewport)
		viewport.size = camera_resolution * Vector2.ONE
		viewport.keep_3d_linear = true
#		viewport.shadow_atlas_size = 4096
		viewport.transparent_bg = true
		viewport.msaa = Viewport.MSAA_8X
		viewports.append(viewport)
		mat.set_shader_param("Texture%d" % [i], viewport.get_texture())
		
		var camera = Camera.new()
		viewport.add_child(camera)
		camera.fov = 90
		camera.near = clip_near
		camera.far = clip_far
		camera.cull_mask -= render_layer
		cameras.append(camera)
	
	if num_cameras < 6:
		for i in range(num_cameras + 1, 6):
			mat.set_shader_param("Texture%d" % [i], Texture.new())

func update_size(new_size):
#	make_new(new_size)
	var max_d = max(new_size.x, new_size.y)

	for i in range(num_cameras):
		viewports[i].size = max_d * Vector2.ONE

func _process(delta):
	for camera in cameras:
		camera.global_transform = global_transform
	if num_cameras >= 2:
		cameras[1].rotate_object_local(Vector3.UP, PI/2)
	if num_cameras >= 3:
		cameras[2].rotate_object_local(Vector3.UP, -PI/2)
	if num_cameras >= 4:
		cameras[3].rotate_object_local(Vector3.RIGHT, -PI/2)
	if num_cameras >= 5:
		cameras[4].rotate_object_local(Vector3.RIGHT, PI/2)
	if num_cameras >= 6:
		cameras[5].rotate_object_local(Vector3.UP, PI)


func set_fovx(x: float):
	fovx = x
	if fovx < 10:
		fovx = 10
	if fovx > 360:
		fovx = 360
	mat.set_shader_param("fovx", fovx)


func set_lens(l: int):
	lens = l
	if lens > Lens.size() - 1:
		lens = 0
	mat.set_shader_param("lens", lens)
