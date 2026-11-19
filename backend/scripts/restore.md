# Restaurer une sauvegarde

```bash
age -d -i cle-privee.txt db-AAAAMMJJ-HHMMSS.sql.gz.age | gunzip | \
  docker compose -f docker-compose.prod.yml exec -T db psql -U tchihali tchihali
age -d -i cle-privee.txt files-AAAAMMJJ-HHMMSS.tar.gz.age | \
  docker compose -f docker-compose.prod.yml exec -T api tar -C /data -xz
```

Testez la restauration sur une machine de test **avant** d'en avoir besoin.
