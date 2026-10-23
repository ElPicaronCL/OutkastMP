"""Repository checks use fixtures so they also run without engine/submodules."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


CHECKER = Path(__file__).resolve().parents[1] / "tools/check_repository.py"


class RepositoryStructureTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.resource = self.root / "mods/resources/core"
        self.resource.mkdir(parents=True)
        (self.root / "neon.project.json").write_text(json.dumps({
            "resources": [{"name": "core", "path": "mods/resources/core"}]
        }))
        (self.resource / "meta.xml").write_text(
            '<meta><script src="server.lua" type="server" /></meta>'
        )
        (self.resource / "server.lua").write_text("-- fixture\n")
        (self.root / ".gitmodules").write_text(
            '[submodule "scripts/library"]\n'
            '\tpath = scripts/library\n'
            '\turl = https://example.invalid/library\n'
        )
        spec = importlib.util.spec_from_file_location("check_repository", CHECKER)
        self.checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.checker)

    def check(self, **kwargs):
        return self.checker.check_repository(self.root, **kwargs)

    def test_registered_resource_and_script_exist(self):
        errors, pending = self.check()
        self.assertEqual((errors, pending), ([], []))

    def test_missing_declared_script_is_an_error(self):
        (self.resource / "server.lua").unlink()
        errors, _ = self.check()
        self.assertTrue(any("server.lua" in e and "missing" in e for e in errors))

    def test_missing_registered_resource_is_an_error(self):
        (self.resource / "meta.xml").unlink()
        errors, _ = self.check()
        self.assertTrue(any("meta.xml" in e for e in errors))

    def test_absolute_links_are_rejected_on_posix_and_windows(self):
        for target in ["/home/author/library", "C:\\author\\library"]:
            with self.subTest(target=target):
                link = self.root / "library"
                link.symlink_to(target)
                errors, _ = self.check()
                self.assertTrue(any("absolute" in e for e in errors))
                link.unlink()

    def test_relative_link_cannot_escape_repository(self):
        (self.root / "library").symlink_to("../outside")
        errors, _ = self.check()
        self.assertTrue(any("outside repository" in e for e in errors))

    def test_omitted_submodule_is_pending_and_strict_mode_fails(self):
        (self.root / "library").symlink_to("scripts/library/runtime")
        errors, pending = self.check()
        self.assertEqual(errors, [])
        self.assertEqual(len(pending), 1)
        self.assertIn("scripts/library", pending[0])
        errors, _ = self.check(require_dependencies=True)
        self.assertTrue(any("dependency" in e for e in errors))

    def test_missing_target_outside_submodule_is_an_error(self):
        (self.root / "library").symlink_to("missing/runtime")
        errors, pending = self.check()
        self.assertTrue(any("missing" in e for e in errors))
        self.assertEqual(pending, [])

    def test_initialized_submodule_missing_runtime_is_an_error(self):
        library = self.root / "scripts/library"
        library.mkdir(parents=True)
        (library / ".git").write_text("gitdir: ../../.git/modules/library\n")
        (self.root / "library").symlink_to("scripts/library/runtime")
        errors, pending = self.check()
        self.assertTrue(any("missing" in e for e in errors))
        self.assertEqual(pending, [])

    def test_malformed_xml_is_an_error(self):
        (self.resource / "meta.xml").write_text("<meta>")
        errors, _ = self.check()
        self.assertTrue(any("XML" in e for e in errors))

    def test_manifest_path_cannot_escape_resource(self):
        (self.resource / "meta.xml").write_text(
            '<meta><script src="../outside.lua" type="server" /></meta>'
        )
        errors, _ = self.check()
        self.assertTrue(any("outside resource" in e for e in errors))

    def test_invalid_script_side_is_an_error(self):
        (self.resource / "meta.xml").write_text(
            '<meta><script src="server.lua" type="browser" /></meta>'
        )
        errors, _ = self.check()
        self.assertTrue(any("script side" in e for e in errors))

    def test_script_side_must_be_explicit(self):
        (self.resource / "meta.xml").write_text(
            '<meta><script src="server.lua" /></meta>'
        )
        errors, _ = self.check()
        self.assertTrue(any("script side" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
