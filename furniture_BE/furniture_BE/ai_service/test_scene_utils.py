from __future__ import annotations

import unittest

import numpy as np
from PIL import Image

from app import _analyze_lighting, _estimate_plane, _make_depth_grid, _occlusion_mask


class SceneUtilityTests(unittest.TestCase):
    def test_depth_grid_has_fixed_compact_shape(self):
        depth = np.linspace(0, 1, 80 * 120, dtype=np.float32).reshape(80, 120)
        grid = _make_depth_grid(depth)
        self.assertEqual(grid["width"], 32)
        self.assertEqual(grid["height"], 24)
        self.assertEqual(len(grid["values"]), 768)
        self.assertGreater(max(grid["values"]), min(grid["values"]))

    def test_plane_estimation_returns_four_normalized_points(self):
        mask = np.zeros((120, 180), dtype=bool)
        mask[45:115, 25:165] = True
        plane = _estimate_plane(mask, "floor")
        self.assertIsNotNone(plane)
        self.assertEqual(len(plane["points"]), 4)
        for point in plane["points"]:
            self.assertGreaterEqual(point["x"], 0)
            self.assertLessEqual(point["x"], 1)
            self.assertGreaterEqual(point["y"], 0)
            self.assertLessEqual(point["y"], 1)

        # The placement envelope must recover floor strips commonly missed at
        # the lower sides by semantic segmentation.
        self.assertEqual(plane["points"][2]["x"], 1.0)
        self.assertEqual(plane["points"][2]["y"], 1.0)
        self.assertEqual(plane["points"][3]["x"], 0.0)
        self.assertEqual(plane["points"][3]["y"], 1.0)
        self.assertLess(plane["points"][0]["x"], 25 / 180)
        self.assertGreater(plane["points"][1]["x"], 164 / 180)
        self.assertGreaterEqual(
            plane["points"][1]["x"] - plane["points"][0]["x"], 0.81
        )

    def test_occlusion_mask_keeps_furniture_but_excludes_structure(self):
        labels = np.zeros((100, 100), dtype=np.uint8)  # wall
        labels[20:80, 20:80] = 23  # sofa
        mask = _occlusion_mask(labels)
        self.assertFalse(bool(mask[5, 5]))
        self.assertTrue(bool(mask[50, 50]))

    def test_lighting_grid_and_source_are_bounded(self):
        pixels = np.zeros((120, 160, 3), dtype=np.uint8)
        pixels[:] = [60, 55, 50]
        pixels[5:45, 10:55] = [255, 245, 220]
        lighting = _analyze_lighting(Image.fromarray(pixels, mode="RGB"))
        self.assertEqual(len(lighting["grid"]["values"]), 192)
        self.assertLess(lighting["lightPosition"]["x"], 0.5)
        self.assertLess(lighting["lightPosition"]["y"], 0.5)
        self.assertGreaterEqual(lighting["shadowSoftness"], 0.2)
        self.assertLessEqual(lighting["shadowSoftness"], 1)


if __name__ == "__main__":
    unittest.main()
