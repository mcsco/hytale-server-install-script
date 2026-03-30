# Tips for your Hytale Server

## Enabling Autoupdates
Add the following block of code inside the... ```"Update": {},```
```
"Enabled": true,
"CheckIntervalSeconds": 3600,
"NotifyPlayersOnAvailable": true,
"Patchline": null,
"RunBackupBeforeUpdate": true,
"BackupConfigBeforeUpdate": true,
"AutoApplyMode": "WhenEmpty",
"AutoApplyDelayMinutes": 30
```

You can Adjust the "AutoApplyMode" to the following options ```"Disabled", "WhenEmpty", or "Scheduled"```

## Enabling No Item Loss and Durability Loss After Death
Make sure your server is not running
```
sudo systemctl stop hytale
```
Look for the config.json for the world you would like to edit
For Example:
```
nano /opt/hytale-server/universe/worlds/default/config.json
```

Add the following block of code after... ```"GameplayConfig": "Default",```
```
  "Death": {
    "RespawnController": {
      "Type": "HomeOrSpawnPoint"
    },
    "ItemsLossMode": "None",
    "ItemsAmountLossPercentage": 0.0,
    "ItemsDurabilityLossPercentage": 0.0
  },
```

Make sure to save the file && start the server
```
sudo systemctl start hytale
```
