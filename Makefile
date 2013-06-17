default: generate

generate:
	coffee -o js -c src/coffee
	scss -t compressed --update src/scss:css

.PHONY: generate
