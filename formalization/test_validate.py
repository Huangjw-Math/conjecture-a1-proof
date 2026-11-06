"""Regression tests for the source-diagnostic masker; no Lean runtime required."""
import unittest

from validate import FORBIDDEN, mask


class MaskTests(unittest.TestCase):
    def assert_masked(self, source):
        result = mask(source)
        self.assertEqual(len(result), len(source))
        self.assertEqual(result.count('\n'), source.count('\n'))
        self.assertEqual(FORBIDDEN.findall(result), [])

    def test_nested_and_line_comments(self):
        self.assert_masked('-- sorry\n/- axiom /- admit -/ unsafe\n native_decide -/')

    def test_escaped_string(self):
        self.assert_masked(r'"sorry \"admit\" unsafe native_decide"')

    def test_raw_strings(self):
        self.assert_masked('r"sorry" r##"axiom "admit" native_decide"##')

    def test_quoted_identifier(self):
        self.assert_masked('\u00absorry axiom unsafe native_decide\u00bb')

    def test_real_code_token_survives(self):
        source = '-- axiom\n\u00abadmit\u00bb "unsafe" /- native_decide -/ sorry'
        self.assertEqual(FORBIDDEN.findall(mask(source)), ['sorry'])


if __name__ == '__main__':
    unittest.main()
