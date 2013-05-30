default: generate

generate:
	rm -rf lib/*
	coffee -o lib -c src

.PHONY: generate
