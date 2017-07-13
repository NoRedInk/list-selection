.PHONY: all
all: test

.PHONY: clean
clean:
	rm -rf elm-stuff tests/elm-stuff

.PHONY: test
test: tests/elm-stuff
	elm test

tests/elm-stuff: tests/elm-package.json
	cd tests && elm package install --yes
