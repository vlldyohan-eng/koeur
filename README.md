# Koeur Android

Projet Android prêt à être compilé automatiquement par GitHub Actions.

## Générer l'APK
1. Mettre ce projet dans le dépôt GitHub `koeur`.
2. Aller dans **Actions**.
3. Lancer **Build Koeur APK** avec **Run workflow**.
4. Une fois terminé, ouvrir le workflow puis **Artifacts** et télécharger `koeur-debug-apk`.

L'APK est un build de démonstration signé avec la clé debug. Pour Google Play, il faudra créer une clé de signature de production et un Android App Bundle (.aab), puis configurer la fiche Play Console.
