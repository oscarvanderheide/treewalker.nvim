MINIMAL_INIT=tests/minimal_init.lua
TESTS_DIR=tests

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${MINIMAL_INIT}' }"

test-watch:
	nodemon -e lua -x "$(MAKE) test || exit 1"

typecheck:
	luacheck . --globals vim it describe --exclude-files tests/fixtures --max-comment-line-length 140

# Run this to be sure all's well
pass: test typecheck
