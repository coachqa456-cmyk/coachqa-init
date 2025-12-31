docker exec -it coachqa-frontend-dev sh
docker exec -it coachqa-backend-dev sh
docker exec -it coachqa-postgres-dev sh
docker exec -it coachqa-postgres-dev psql -U postgres


Tenant - Login
-------------------------
user@demo.com
Demo@123


docker restart coachqa-frontend-dev
docker restart coachqa-backend-dev
