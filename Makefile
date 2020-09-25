.DEFAULT_GOAL = build

build:
	@echo -e '\033[32mRunning build\033[0m'
	@moonc ./commands ./plugins ./tests
test:
	@echo -e '\033[32mRunning tests\033[0m'
	@cd tests && luvit main.lua && cd ..
docker:
	@echo -e '\033[32mRunning Docker\033[0m'
	@sudo docker-compose up
docker-d:
	@echo -e '\033[32mRunning Docker detached\033[0m'
	@sudo docker-compose up -d