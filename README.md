# Godot Path to Particles
Godot plugin to bake curve data to textures that can then be fetched in a GPU-Particle system.
Adds `PathBaker3D` node to bake position and up-vector data from Curve3D to textures. Use the `GPUParticlePathNode3D` to spawn GPU particles that follow a pre-baked curve.

<img width="40%" height="40%" alt="Peek 2026-10-03 21-07" src="https://github.com/user-attachments/assets/ac0b1b2e-2b4d-43b1-8062-c5932e120663" />
<img width="40%" height="40%" alt="Peek 2026-10-03 21-12" src="https://github.com/user-attachments/assets/d1e8d048-04a3-446f-ac3a-1b383ac07db7" />

<img width="40%" height="40%" alt="image" src="https://github.com/user-attachments/assets/67239eba-f12c-42b9-8d3d-80904e554398" />

## Installation
Plugin activation workflow

## Quick start
Add a `PathBakerNode3D` to your scene. Add some curve points and adjust the texture size as needed. Hit 'Bake Path' button to bake the position and up-vector textures. Spawn the particles via the 'Spawn Particle System' button. In case you need to debug the baked data, open the `Debugging` inspector group and click on `Spawn Debugger` button. This will spawn meshes along the curve that are also oriented along the curve. When done debugging, click the 'Delete Debugger' button.

## Known Issues
- Particle count tied to texture resolution 
  - Spawning more particles as the x-resolution of the baked texture will result in particles overlapping.
- For open curves, particle start position varies slightly over time
