MINIMAL_INIT=tests/minimal_init.lua
TESTS_DIR=tests
NO_UTIL_SPEC=checks

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${MINIMAL_INIT}' }"

test-watch:
	nodemon -e lua -x "$(MAKE) test || exit 1"

typecheck:
	luacheck . --globals vim it describe before_each --exclude-files tests/fixtures --max-comment-line-length 140

no-utils:
	@nvim \
		--headless \
		--noplugin \
		-u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${NO_UTIL_SPEC} { minimal_init = '${MINIMAL_INIT}' }"

# Run this to be sure all's well
check: test typecheck no-utils
