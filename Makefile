.PHONY: version changelog update git-tag-version

version:
	@echo ${shell git describe --tags 2> /dev/null}

changelog:
	@cat CHANGELOG.md

update:
	@git pull

git-tag-version:
	git tag -a $(VERSION) -m $(VERSION)
	git push origin $(VERSION)
