.PHONY: dev-up dev-down

dev-up:
	docker-compose.yaml up -d

dev-down:
	docker-compose.yaml down