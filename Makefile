.PHONY: dev-up dev-down

dev-up:
	docker-compose up -d

dev-down:
	docker-compose down -v