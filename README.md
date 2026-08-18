# Koeur Android — vrais comptes/profils

Cette version utilise Supabase Auth et PostgreSQL directement depuis l'application.
Fonctions actuellement branchées : création de compte, connexion, profil, découverte de profils, Koeur (like), XP/éléments.

Avant utilisation : exécuter le SQL `001_koeur.sql` du backend Koeur V2 dans Supabase. Activer l'inscription Email. Ne jamais mettre une clé `service_role`/secret dans l'application.
Le moteur de compatibilité avancé, la messagerie temps réel, les photos Storage, la vérification d'identité et Google Play Billing restent à brancher pour une version production.
