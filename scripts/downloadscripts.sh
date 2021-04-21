mkdir scripts
cd scripts
wget https://raw.githubusercontent.com/VeerMuchandi/MigratingFromOpenShiftToGKE/main/scripts/migrateScript1.sh
wget https://raw.githubusercontent.com/VeerMuchandi/MigratingFromOpenShiftToGKE/main/scripts/migrateScript2.sh
wget https://raw.githubusercontent.com/VeerMuchandi/MigratingFromOpenShiftToGKE/main/scripts/exportApplicationManifests.sh
wget https://raw.githubusercontent.com/VeerMuchandi/MigratingFromOpenShiftToGKE/main/scripts/exportSecrets.sh
chmod +x *.sh
cd ..