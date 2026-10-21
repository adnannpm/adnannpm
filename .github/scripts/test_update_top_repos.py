import unittest
from unittest.mock import patch

from update_top_repos import START, END, fetch_repos, refresh


def repo(name, stars, **extra):
    return dict(name=name, stargazers_count=stars, fork=False,
                html_url=f"https://github.com/adnannpm/{name}",
                description="A | tool\nwith <markup>", language="Python", **extra)


class TopReposTests(unittest.TestCase):
    def test_ranking_limit_escaping_and_idempotency(self):
        repos = [repo("z", 3), repo("a", 3), repo("winner", 9)]
        repos += [repo(f"other{i}", 0) for i in range(6)]
        fork = repo("fork", 100)
        fork["fork"] = True
        content = f"Intro\n{START}\nold\n{END}\nFooter"
        result = refresh(content, repos + [fork])
        self.assertLess(result.index("[winner]"), result.index("[a]"))
        self.assertLess(result.index("[a]"), result.index("[z]"))
        self.assertNotIn("[fork]", result)
        self.assertEqual(result.count("https://github.com/"), 5)
        self.assertIn("A &#124; tool with &lt;markup&gt;", result)
        self.assertTrue(result.startswith("Intro\n"))
        self.assertTrue(result.endswith("\nFooter"))
        self.assertEqual(refresh(result, repos), result)

    def test_invalid_markers_fail(self):
        for content in ("", END + START, START + START + END):
            with self.subTest(content=content), self.assertRaises(ValueError):
                refresh(content, [])

    def test_pagination(self):
        with patch("update_top_repos.fetch_page", side_effect=[
            [repo(str(i), 0) for i in range(100)], [repo("last", 9)]
        ]) as fetch:
            self.assertEqual(len(fetch_repos("adnannpm")), 101)
            self.assertEqual(fetch.call_args_list[1].args, ("adnannpm", 2))

    def test_empty_state(self):
        result = refresh(START + END, [])
        self.assertIn("No public repositories", result)


if __name__ == "__main__":
    unittest.main()
