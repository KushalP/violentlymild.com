clean:
	rm -rf public

build:
	hugo -v

gh-pages:
	git subtree push --prefix public origin gh-pages
