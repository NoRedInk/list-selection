.PHONY: all
all: test documentation.json

.PHONY: clean
clean:
	rm -rf elm-stuff tests/elm-stuff documentation.json

documentation.json: $(shell find src -name '*.elm' -type f)
	elm make --warn --yes --docs=$@

.PHONY: test
test: tests/elm-stuff
	elm-verify-examples
	elm test

tests/elm-stuff: tests/elm-package.json
	cd tests && elm package install --yes
