.PHONY: run-test

example: codepoint.s example.c
	gcc $^ -o $@

test: codepoint.s codepoint_test.c
	gcc $^ -lcheck -o $@

run-test: test
	./$^
