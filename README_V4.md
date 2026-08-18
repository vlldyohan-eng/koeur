# Koeur V4 — complet

Cette build ajoute :
- profils réels Supabase
- likes + matchs
- messagerie temps réel
- upload photo vers Supabase Storage (bucket `profile-photos`)
- signalement / blocage
- score de compatibilité indicatif et explicable
- certification (demande enregistrée)
- écran Premium

Configuration Supabase requise :
1. Exécuter la migration SQL Koeur.
2. Activer Email Auth.
3. Créer le bucket Storage `profile-photos`.
4. Activer Realtime sur `messages`.
5. Vérifier les politiques RLS des tables et du bucket.

Important : la certification d'identité réelle et Google Play Billing ne peuvent pas être « simulés ». Ils nécessitent respectivement un prestataire de vérification et la configuration d'un produit d'abonnement dans Google Play Console. L'application ne doit pas présenter un faux badge de vérification.
