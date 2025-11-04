# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jalombar <jalombar@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/23 12:47:29 by jalombar          #+#    #+#              #
#    Updated: 2025/11/04 13:27:39 by jalombar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception
COMPOSE_FILE=srcs/docker-compose.yml
DATA_DIR=/home/$(USER)/data

all: init_dirs
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi all

fclean: clean
	sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	sudo rm -rf /var/lib/mysql

re: clean all

init_dirs:
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo mkdir -p $(DATA_DIR)/wordpress
	sudo chown -R $(USER):$(USER) $(DATA_DIR)