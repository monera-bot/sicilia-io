install: .gitmodules
	git submodule update --init --recursive

clean: www/index.html
	rm -rf www/*

server: www/index.html
	docker-compose up -d www

server-stop: www/index.html
	docker-compose kill www

update-modules: .gitmodules
	cd generator && \
	git fetch --all && \
	git reset --hard origin/master && \
	cd ../style && \
	git fetch --all && \
	git reset --hard origin/master && \
	cd ../ && \
	git commit -am 'Update submodules' && \
	git push origin $(git rev-parse --abbrev-ref HEAD)

dev: docker-compose.yml
	mkdir -p ./www && \
	docker-compose run generator dev

build: docker-compose.yml
	mkdir -p ./www && \
	docker-compose build generator && \
	docker-compose run generator build

publish-gh-pages: docker-compose.yml
	git branch -D gh-pages 2>/dev/null || true && \
	git branch -D draft 2>/dev/null || true && \
	git checkout -b draft && \
	git add -f www && \
	git commit -am "Deploy on gh-pages" && \
	git subtree split --prefix www -b gh-pages && \
	git checkout origin/master -- ./CNAME && \
	git add ./CNAME && \
	git commit -am "Add latest CNAME" && \
	git push -f origin gh-pages:gh-pages && \
	git checkout master && \
	git submodule update --init

stop: docker-compose.yml
	docker-compose kill && \
	docker-compose rm -f

.PHONY: dev
