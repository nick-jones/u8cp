#include <stdlib.h>
#include <check.h>
#include "codepoint.h"

START_TEST(test_characters) {
  ck_assert_uint_eq(utf8_to_codepoint("\xF0\x9F\x92\xA9"), 128169);
  ck_assert_uint_eq(utf8_to_codepoint("\xEF\xB8\x8F"), 65039);
  ck_assert_uint_eq(utf8_to_codepoint("\xC6\xA7"), 423);
  ck_assert_uint_eq(utf8_to_codepoint("\x61"), 97);
}
END_TEST

Suite * codepoint_suite() {
  Suite *s = suite_create("codepoint");
  TCase *tc_core = tcase_create("Core");
  tcase_add_test(tc_core, test_characters);
  suite_add_tcase(s, tc_core);
  return s;
}

int main() {
  Suite *s = codepoint_suite();
  SRunner *sr = srunner_create(s);
  srunner_run_all(sr, CK_NORMAL);
  int number_failed = srunner_ntests_failed(sr);
  srunner_free(sr);
  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
