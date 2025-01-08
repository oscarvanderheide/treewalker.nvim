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

ensure-no-util-r:
	! grep --exclude-dir=.git -r --exclude test.yml --exclude TODO.md 'util.R' | grep -v '\-\-'

typecheck:
	luacheck . --globals vim it describe --exclude-files tests/fixtures --max-comment-line-length 140

# Run this to be sure all's well
pass: test ensure-no-util-r typecheck
