# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jalombar <jalombar@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/23 12:47:29 by jalombar          #+#    #+#              #
#    Updated: 2025/11/04 11:53:03 by jalombar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception
COMPOSE_FILE=srcs/docker-compose.yml

all:
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi all

re: clean all