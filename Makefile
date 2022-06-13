IMAGE_NAME=url_shortener
CONTAINER_NAME=url_shortener
PORT=8000

build:
	docker build -f Dockerfile -t ${IMAGE_NAME} .

run-dev: build
	poetry run uvicorn src.url_shortener.app:app --reload

local-up:
	docker run --rm -d -p ${PORT}:${PORT} --name ${CONTAINER_NAME} ${IMAGE_NAME}

local-down:
	docker stop ${CONTAINER_NAME}