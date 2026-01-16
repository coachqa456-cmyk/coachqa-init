docker exec -it qenabler-frontend-dev sh
docker exec -it qenabler-backend-dev sh
docker exec -it qenabler-postgres-dev sh
docker exec -it qenabler-postgres-dev psql -U postgres


Tenant - Login
-------------------------
user@demo.com
Demo@123


docker restart qenabler-frontend-dev
docker restart qenabler-backend-dev
