# Godot Path to Particles
Godot plugin to bake curve data to textures that can then be fetched in a GPU-Particle system.
Adds `PathBaker3D` node to bake position and up-vector data from Curve3D to textures. Use the `GPUParticlePathNode3D` to spawn GPU particles that follow a pre-baked curve.

<img width="100%" height="100%" alt="ezgif com-optimize" src="https://github.com/user-attachments/assets/26af24c9-fca6-452e-a06b-5d8f96d951fa" />

## Installation
Plugin activation workflow

## Quick start
Add a `PathBakerNode3D` to your scene. Add some curve points and adjust the texture size as needed. Hit 'Bake Path' button to bake the position and up-vector textures. Spawn the particles via the 'Spawn Particle System' button. In case you need to debug the baked data, open the `Debugging` inspector group and click on `Spawn Debugger` button. This will spawn meshes along the curve that are also oriented along the curve. When done debugging, click the 'Delete Debugger' button.

## Known Issues
- Particle count tied to texture resolution 
  - Spawning more particles as the x-resolution of the baked texture will result in particles overlapping.
- For open curves, particle start position varies slightly over time
