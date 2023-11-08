subscription-manager remove --all
subscription-manager unregister
subscription-manager clean
sleep 5
subscription-manager register --username "lii.luis.ramirez" --password "NuevoProyecto.11"
subscription-manager attach --pool=2c94868c8379b71b01838536544d43f8
