"""Thin MPFB API consumer for the V0 asset probe; run in factory-startup Blender.

The humanoid, clothing fit, weights, helper masks and rig are supplied by MPFB.
Local dependency paths are CLI inputs. This does not install an addon or save
Blender preferences. Output meshes are CC0; the MPFB tool source is separate.
"""
import argparse
import json
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

parser = argparse.ArgumentParser()
parser.add_argument("--mpfb-src", required=True)
parser.add_argument("--assets-root", required=True)
parser.add_argument("--output-root", required=True)
args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:])
src = Path(args.mpfb_src).resolve()
assets = Path(args.assets_root).resolve()
output = Path(args.output_root).resolve()
output.mkdir(parents=True, exist_ok=True)
sys.path.insert(0, str(src))

import mpfb
from mpfb._preferences import MpfbPreferences

# The factory-startup process has disposable preferences. Configure the official
# data-path property before its service initializes, without changing user files.
bpy.utils.register_class(MpfbPreferences)
addon = bpy.context.preferences.addons.new()
addon.module = "mpfb"
addon.preferences.mpfb_user_data = str(output / "tool_state")
mpfb.register()

from mpfb.services.humanservice import HumanService
from mpfb.services.targetservice import TargetService
from mpfb.services.rigservice import RigService

def plain_material(name, color):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = (*color, 1.0)
    principled.inputs["Roughness"].default_value = 0.95
    return material

results = []
for name, gender, age, outfit, hair in [
    ("woman_sample", 0.0, 0.65, "female_casualsuit02", "ponytail01"),
    ("adult_sample", 1.0, 0.35, "male_worksuit01", "short02"),
]:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    phenotype = TargetService.get_default_macro_info_dict()
    phenotype.update(gender=gender, age=age, muscle=0.35, weight=0.48)
    human = HumanService.create_human(scale=0.1, macro_detail_dict=phenotype)
    human.name = name
    HumanService.add_builtin_rig(human, "game_engine")
    rig = human.parent
    assert rig is not None and rig.type == "ARMATURE"
    human.data.materials.clear()
    human.data.materials.append(plain_material("sample_skin", (0.49, 0.34, 0.25)))
    for asset_type, relative in [
        ("Clothes", f"clothes/{outfit}/{outfit}.mhclo"),
        ("Clothes", "clothes/shoes01/shoes01.mhclo"),
        ("Hair", f"hair/{hair}/{hair}.mhclo"),
        ("Eyes", "eyes/low-poly/low-poly.mhclo"),
    ]:
        filename = assets / relative
        assert filename.is_file(), filename
        loaded = HumanService.add_mhclo_asset(str(filename), human,
            asset_type=asset_type, subdiv_levels=0,
            material_type="MAKESKIN" if asset_type != "Eyes" else "NONE")
        if asset_type == "Eyes":
            loaded.data.materials.clear()
            loaded.data.materials.append(plain_material("sample_eyes", (0.18, 0.15, 0.12)))
    bones = [bone.name for bone in rig.pose.bones]
    print("SAMPLE_BONES", name, json.dumps(bones))
    # Relax the library's spread-arm bind pose. Use the library's existing
    # rest-pose bake so the clothing and body retain matching skin weights.
    for side in ("l", "r"):
        bone = rig.pose.bones["upperarm_" + side]
        direction = (bone.tail - bone.head).normalized()
        desired = Vector((0.13 if bone.head.x > 0 else -0.13, 0, -1)).normalized()
        turn = direction.rotation_difference(desired).to_matrix().to_4x4()
        bone.matrix = Matrix.Translation(bone.head) @ turn @ Matrix.Translation(-bone.head) @ bone.matrix
        bpy.context.view_layer.update()
    RigService.apply_pose_as_rest_pose(rig)
    bpy.ops.file.pack_all()
    bpy.ops.wm.save_as_mainfile(filepath=str(output / (name + ".blend")))
    bpy.ops.export_scene.gltf(filepath=str(output / (name + ".glb")),
        export_format="GLB", export_apply=True, export_morph=False,
        export_animations=False, export_yup=True)
    result = {"name": name, "phenotype": phenotype, "outfit": outfit,
        "hair": hair, "bones": len(bones),
        "meshes": [{"name": obj.name, "vertices": len(obj.data.vertices),
                    "polygons": len(obj.data.polygons)}
                   for obj in bpy.data.objects if obj.type == "MESH"]}
    results.append(result)
    print("SAMPLE_EXPORTED", json.dumps(result))
(output / "build.json").write_text(json.dumps({"blender": bpy.app.version_string,
    "mpfb": "v2.0-a3 / 077d44f", "samples": results}, indent=2), encoding="utf-8")
