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



# Terminal 1: Start your backend
cd qenabler-backend
npm run dev

# Terminal 2: Forward Stripe webhooks
stripe listen --forward-to localhost:9002/api/webhooks/stripe

# Terminal 3: Test webhooks (optional)
stripe trigger checkout.session.completed
stripe trigger payment_intent.succeeded
stripe trigger invoice.payment_succeeded


Serveur / Host: access-5019307025.webspace-host.com
Port: 22
Protocole: SFTP + SSH
Nom d’utilisateur: su303905


