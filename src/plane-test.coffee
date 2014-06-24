"use strict";
window.THREE = require("THREE")
require("plugins/Physijs/physi.js")
require("shaders/ocean/water-material.js")

Physijs.scripts.worker = "src/plugins/Physijs/physijs_worker.js";
Physijs.scripts.ammo = "examples/js/ammo.js";

initScene = undefined
render = undefined
renderer = undefined
scene = undefined
camera = undefined
boxFocus = undefined
ground_material = undefined
ground_geometry = undefined
ground = undefined
water = undefined
planeMesh = undefined
retorMesh = undefined

#Turning Speed
turningSpeed = 0.1
leftRightRot = 0
upDownRot = 0

#Keyboard control
keyDown = new Array()
i = 0
while i < 300
  keyDown[i] = false
  i++
document.onkeydown = (event) ->
  console.log "## Keyboard keyDown"
  console.log "Keycode :" + event.keyCode
  keyDown[event.keyCode] = true
  return

document.onkeyup = (event) ->
  console.log "## Keyboard keyUp"
  console.log "Keycode :" + event.keyCode
  keyDown[event.keyCode] = false
  return

planeSrc = {}

loader = new THREE.JSONLoader()
loader.load "src/objects/plane-no-retor.js", (plane, plane_materials) ->
  loader.load "src/objects/retor.js", (retor, retor_materials) ->
    planeSrc = 
      material: plane_materials
      vectrices: plane
      retor:
        material: retor_materials
        vectrices: retor
    initScene()
    return

  return

initScene = ->
  projector = new THREE.Projector
  renderer = new THREE.WebGLRenderer(antialias: true)
  renderer.setSize window.innerWidth, window.innerHeight
  renderer.shadowMapEnabled = true
  renderer.shadowMapSoft = true
  document.getElementById("viewport").appendChild renderer.domElement

  scene = new Physijs.Scene
  scene.setGravity new THREE.Vector3(0, -30, 0)
  scene.addEventListener "update", ->
    scene.simulate `undefined`, 2
    return

  camera = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 1, 1000)
  camera.position.set 60, 50, 60
  camera.lookAt scene.position
  scene.add camera

  # Light
  light = new THREE.DirectionalLight(0xFFFFFF)
  light.position.set 20, 40, -15
  light.target.position.copy scene.position
  light.castShadow = true
  light.shadowCameraLeft = -60
  light.shadowCameraTop = -60
  light.shadowCameraRight = 60
  light.shadowCameraBottom = 60
  light.shadowCameraNear = 20
  light.shadowCameraFar = 200
  light.shadowBias = -.0001
  light.shadowMapWidth = light.shadowMapHeight = 2048
  light.shadowDarkness = .7
  scene.add light
 

  # Materials
  # high friction
  ground_material = Physijs.createMaterial(new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture("src/shaders/ocean/assets/img/waternormals.jpg")), .8, .4) # low restitution
  ground_material.map.wrapS = ground_material.map.wrapT = THREE.RepeatWrapping
  ground_material.map.repeat.set 3, 3

  waterNormals = new THREE.ImageUtils.loadTexture('src/shaders/ocean/assets/img/waternormals.jpg');
  waterNormals.wrapS = waterNormals.wrapT = THREE.RepeatWrapping;

  water = new THREE.Water(renderer, camera, scene,
    textureWidth: 512
    textureHeight: 512
    waterNormals: waterNormals
    alpha: 0.8
    sunDirection: light.position.normalize()
    sunColor: 0xffffff
    waterColor: 0x001e0f
    distortionScale: 10.0
  )

  # low friction
  box_material = Physijs.createMaterial(new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture("src/plugins/Physijs/examples/images/plywood.jpg")), .4, .6) # high restitution
  box_material.map.wrapS = ground_material.map.wrapT = THREE.RepeatWrapping
  box_material.map.repeat.set .25, .25

  # Ground
  #NoiseGen = new SimplexNoise
  ground_geometry = new THREE.PlaneGeometry(1000000, 1000000, 100, 100)
  ###
  i = 0

  while i < ground_geometry.vertices.length
    vertex = ground_geometry.vertices[i]
    i++

  #vertex.y = NoiseGen.noise( vertex.x / 30, vertex.z / 30 ) * 1;
  ground_geometry.computeFaceNormals()
  ground_geometry.computeVertexNormals()
  ###



  planeMaterial = Physijs.createMaterial(new THREE.MeshFaceMaterial(planeSrc.material), 0, 0)
  planeMesh = new Physijs.BoxMesh(planeSrc.vectrices, planeMaterial, 1)
  retorMesh = new THREE.Mesh(planeSrc.retor.vectrices, new THREE.MeshFaceMaterial(planeSrc.retor.material))
  retorMesh.position.set 0, 1, 0
  # Scale-up the model so that we can see it:
  #planeMesh.scale.x = planeMesh.scale.y = planeMesh.scale.z = 5.0
  
  #console.log( retorMesh )
  planeMesh.add retorMesh
  retorMesh.position.y = 5
  retorMesh.position.z = 7.2
  retorMesh.position.x = 0.1

  scene.add planeMesh

  # If your plane is not square as far as face count then the HeightfieldMesh
  # takes two more arguments at the end: # of x faces and # of z faces that were passed to THREE.PlaneMaterial
  ground = new Physijs.HeightfieldMesh(ground_geometry, ground_material, 0) # mass
  ground.rotation.x = -Math.PI / 2
  ground.position.set 0, 0, 0
  ground.receiveShadow = true
  scene.add ground
  
  aMeshMirror = new THREE.Mesh(
    new THREE.PlaneGeometry(1000000, 1000000, 100, 100),
    water.material
  )
  aMeshMirror.add water
  aMeshMirror.position.set 0, 1, 0
  aMeshMirror.rotation.x = -Math.PI / 2
  scene.add aMeshMirror

  i = 0
  while i < 50
    size = Math.random() * 2 + .5
    box = new Physijs.BoxMesh(new THREE.CubeGeometry(size, size, size), box_material, -5)
    box.castShadow = box.receiveShadow = true
    box.position.set Math.random() * 25 - 50, 50, Math.random() * 25 - 50
    scene.add box
    i++

  aCubeMap = THREE.ImageUtils.loadTextureCube([
    "src/shaders/ocean/demo/assets/img/px.jpg"
    "src/shaders/ocean/demo/assets/img/nx.jpg"
    "src/shaders/ocean/demo/assets/img/py.jpg"
    "src/shaders/ocean/demo/assets/img/ny.jpg"
    "src/shaders/ocean/demo/assets/img/pz.jpg"
    "src/shaders/ocean/demo/assets/img/nz.jpg"
  ])

  aCubeMap.format = THREE.RGBFormat
  
  aShader = THREE.ShaderLib["cube"]
  aShader.uniforms["tCube"].value = aCubeMap
  
  aSkyBoxMaterial = new THREE.ShaderMaterial(
    fragmentShader: aShader.fragmentShader
    vertexShader: aShader.vertexShader
    uniforms: aShader.uniforms
    depthWrite: false
    side: THREE.BackSide
  )
  
  aSkybox = new THREE.Mesh(new THREE.BoxGeometry(1000000, 1000000, 1000000), aSkyBoxMaterial)
  
  scene.add aSkybox

  requestAnimationFrame render
  return

render = ->
  
  water.material.uniforms.time.value += 1.0 / 60.0;

  scene.simulate() # run physics
  camera.lookAt planeMesh.position
  renderer.render scene, camera # render the scene
  requestAnimationFrame render
  return

#window.onload = initScene