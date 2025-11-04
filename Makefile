# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jalombar <jalombar@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/23 12:47:29 by jalombar          #+#    #+#              #
#    Updated: 2025/11/04 15:24:12 by jalombar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception
COMPOSE_FILE=srcs/docker-compose.yml
DATA_DIR=/home/$(USER)/data

all: build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

build:
	docker compose -f $(COMPOSE_FILE) up -d --build

clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi all

fclean: clean
	sudo rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/*
	sudo rm -rf /var/lib/mysql/*

re: fclean build
