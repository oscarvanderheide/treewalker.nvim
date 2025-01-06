TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests

.PHONY: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}', sequential = false, keep_going = false }"

test-watch:
	nodemon -e lua -x "$(MAKE) test || exit 1"

ensure-no-util-r:
	! grep --exclude-dir=.git -r --exclude test.yml 'util.R' | grep -v '\-\-'

# Run this to be sure all's well
pass: test ensure-no-util-r
