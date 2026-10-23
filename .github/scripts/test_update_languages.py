import unittest
from unittest.mock import patch

from update_languages import START, END, fetch_repos, fetch_languages, refresh


class LanguageTests(unittest.TestCase):
    def test_percentages_use_all_bytes_and_preserve_content(self):
        content = f"Intro\n{START}\nold\n{END}\nFooter"
        result = refresh(content, {"Java": 600, "Python": 300, "Go": 100})
        self.assertIn("| Java | 60.00% |", result)
        self.assertIn("| Python | 30.00% |", result)
        self.assertIn("| Go | 10.00% |", result)
        self.assertLess(result.index("Java"), result.index("Python"))
        self.assertTrue(result.startswith("Intro\n"))
        self.assertTrue(result.endswith("\nFooter"))
        self.assertEqual(refresh(result, {"Java": 600, "Python": 300, "Go": 100}), result)

    def test_aggregation_excludes_forks_and_private_repos(self):
        repos = [
            {"name": "one"}, {"name": "two"}, {"name": "empty"},
            {"name": "fork", "fork": True},
            {"name": "private", "private": True},
        ]
        with patch("update_languages.fetch_json", side_effect=[
            {"Java": 300, "Python": 100}, {"Java": 300}, {}
        ]):
            self.assertEqual(fetch_languages("adnannpm", repos),
                             {"Java": 600, "Python": 100})

    def test_api_errors_propagate(self):
        with patch("update_languages.fetch_json", side_effect=OSError("API failed")):
            with self.assertRaises(OSError):
                fetch_languages("adnannpm", [{"name": "one"}])

    def test_invalid_markers_fail(self):
        for content in ("", END + START, START + START + END):
            with self.subTest(content=content), self.assertRaises(ValueError):
                refresh(content, {})

    def test_pagination(self):
        with patch("update_languages.fetch_json", side_effect=[
            [{"name": str(i)} for i in range(100)], [{"name": "last"}]
        ]):
            self.assertEqual(len(fetch_repos("adnannpm")), 101)

    def test_empty_state(self):
        self.assertIn("No language data yet", refresh(START + END, {}))

    def test_all_languages_and_ties_and_escaping(self):
        totals = {"Z": 10, "A": 10, "C|<x>": 10, "D": 10, "E": 10, "F": 10}
        result = refresh(START + END, totals)
        self.assertLess(result.index("| A |"), result.index("| Z |"))
        self.assertIn("C&#124;&lt;x&gt;", result)
        self.assertEqual(result.count("16.67%"), 6)


if __name__ == "__main__":
    unittest.main()
