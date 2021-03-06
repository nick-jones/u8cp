#include <stdlib.h>
#include <check.h>
#include "codepoint.h"

START_TEST(test_utf8_to_codepoint) {
  ck_assert_uint_eq(utf8_to_codepoint("\xF0\x9F\x92\xA9"), 128169);
  ck_assert_uint_eq(utf8_to_codepoint("\xEF\xB8\x8F"), 65039);
  ck_assert_uint_eq(utf8_to_codepoint("\xC6\xA7"), 423);
  ck_assert_uint_eq(utf8_to_codepoint("\x61"), 97);
}
END_TEST

START_TEST(test_codepoint_to_utf8) {
  char result[5];
  ck_assert_int_eq(codepoint_to_utf8(128169, result), 0);
  ck_assert_str_eq(result, "\xF0\x9F\x92\xA9\x00");
  ck_assert_int_eq(codepoint_to_utf8(65039, result), 0);
  ck_assert_str_eq(result, "\xEF\xB8\x8F\x00");
  ck_assert_int_eq(codepoint_to_utf8(423, result), 0);
  ck_assert_str_eq(result, "\xC6\xA7\x00");
  ck_assert_int_eq(codepoint_to_utf8(97, result), 0);
  ck_assert_str_eq(result, "\x61\x00");
  ck_assert_int_eq(codepoint_to_utf8(1114112, result), 1);
}
END_TEST

START_TEST(test_utf16be_to_codepoint) {
  ck_assert_uint_eq(utf16be_to_codepoint("\xDB\xFF\xDF\xFF"), 1114111);
  ck_assert_uint_eq(utf16be_to_codepoint("\xD8\x00\xDC\x00"), 65536);
  ck_assert_uint_eq(utf16be_to_codepoint("\xFF\xFF"), 65535);
  ck_assert_uint_eq(utf16be_to_codepoint("\xE0\x00"), 57344);
  ck_assert_uint_eq(utf16be_to_codepoint("\xD7\xFF"), 55295);
  ck_assert_uint_eq(utf16be_to_codepoint("\x00\x61"), 97);
}
END_TEST

START_TEST(test_utf16le_to_codepoint) {
  ck_assert_uint_eq(utf16le_to_codepoint("\xFF\xDB\xFF\xDF"), 1114111);
  ck_assert_uint_eq(utf16le_to_codepoint("\x00\xD8\x00\xDC"), 65536);
  ck_assert_uint_eq(utf16le_to_codepoint("\xFF\xFF"), 65535);
  ck_assert_uint_eq(utf16le_to_codepoint("\x00\xE0"), 57344);
  ck_assert_uint_eq(utf16le_to_codepoint("\xFF\xD7"), 55295);
  ck_assert_uint_eq(utf16le_to_codepoint("\x61\x00"), 97);
}
END_TEST

Suite * codepoint_suite() {
  Suite *s = suite_create("codepoint");
  TCase *tc_core = tcase_create("Core");
  tcase_add_test(tc_core, test_utf8_to_codepoint);
  tcase_add_test(tc_core, test_codepoint_to_utf8);
  tcase_add_test(tc_core, test_utf16be_to_codepoint);
  tcase_add_test(tc_core, test_utf16le_to_codepoint);
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
