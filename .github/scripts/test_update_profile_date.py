import unittest
from datetime import datetime, timezone

from update_profile_date import END, START, refresh


class ProfileDateTests(unittest.TestCase):
    def test_wib_rollover_preserves_surrounding_content(self):
        content = f"Intro\n{START}\nold\n{END}\nFooter\n"
        now = datetime(2026, 10, 21, 18, tzinfo=timezone.utc)
        updated = refresh(content, now)
        self.assertIn("22 October 2026", updated)
        self.assertTrue(updated.startswith(f"Intro\n{START}"))
        self.assertTrue(updated.endswith(f"{END}\nFooter\n"))
        self.assertIn('<sub>22 October 2026 · WIB (UTC+7)</sub>', updated)
        self.assertNotIn('automatically', updated)
        self.assertEqual(refresh(updated, now), updated)

    def test_invalid_markers_fail(self):
        for content in ("no markers", START, END + START, START + START + END):
            with self.subTest(content=content), self.assertRaises(ValueError):
                refresh(content, datetime.now(timezone.utc))


if __name__ == "__main__":
    unittest.main()
