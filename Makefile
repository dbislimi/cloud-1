TF_DIR = ./srcs/terraform

tf-init:
	$(MAKE) -C $(TF_DIR) init

tf-apply:
	$(MAKE) -C $(TF_DIR) apply

tf-off:
	$(MAKE) -C $(TF_DIR) off

tf-destroy:
	$(MAKE) -C $(TF_DIR) destroy

tf-fmt:
	$(MAKE) -C $(TF_DIR) fmt

all : up

up : create-volumes
	docker compose -f ./srcs/docker-compose.yml up -d --build

down :
	docker compose -f ./srcs/docker-compose.yml down -v

re: fclean up

status : 
	@echo "\033[1;32mDOCKER:\033[0m"
	@docker ps
	@echo "\n\033[1;32mNETWORK:\033[0m"
	@docker network ls
	@echo "\n\033[1;32mIMAGES:\033[0m"
	@docker images

clear :

	@sudo rm -rf /home/$(shell whoami)/data/db
	@sudo rm -rf /home/$(shell whoami)/data/wp
	@docker system prune -af --volumes
	@docker volume rm -f srcs_db || true
	@docker volume rm -f srcs_wp || true


clean :
	@docker ps -q | xargs -r docker stop
	@docker ps -a -q | xargs -r docker rm
	@docker images -q | xargs -r docker rmi
	@docker network prune -f

fclean: clean clear

create-volumes:
	@mkdir -p /home/$(shell whoami)/data/db
	@mkdir -p /home/$(shell whoami)/data/wp

.PHONY: all clean fclean re status create-volumes generate-user tf-off tf-on tf-destroy tf-fmt