build:
	docker-compose -f docker/docker-compose.yml build
start:
	docker-compose -f docker/docker-compose.yml --compatibility up
monitor:
	docker-compose -f docker/docker-compose.yml exec producer ruby /app/pub-sub/monitor.rb
