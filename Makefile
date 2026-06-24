NAME          = inception
COMPOSE       = docker compose -f srcs/docker-compose.yml
DATA_PATH     = /home/mchemari/data

all: up

up: create_dirs
	@echo "Lancement de l'infrastructure ..."
	@$(COMPOSE) up -d --build
	@echo "\033[32m[OK] Les conteneurs sont lancés en arrière-plan.\033[0m"

create_dirs:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

down:
	@echo "Arrêt des conteneurs..."
	@$(COMPOSE) down

clean: down

fclean: clean
	@echo "Nettoyage complet du système Docker et des volumes..."
	@$(COMPOSE) down -v --rmi all --remove-orphans
	@if [ -d "$(DATA_PATH)" ]; then \
		sudo rm -rf $(DATA_PATH)/mariadb; \
		sudo rm -rf $(DATA_PATH)/wordpress; \
		echo "Dossiers physiques de données supprimés."; \
	fi
	@docker system prune -f

re: fclean all

shell-%:
	@echo "Connexion au shell du conteneur $*..."
	@$(COMPOSE) exec $* sh

build-%:
	@echo "🔧 Re-build spécifique du conteneur $*..."
	@$(COMPOSE) up -d --build $*

.PHONY: all up down clean fclean re create_dirs
