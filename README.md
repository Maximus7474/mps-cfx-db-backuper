# Cfx server Database Backup resource

For those who want to have a resource handle database backups, this will run within your FiveM or RedM server and create backups of your database.

## Usage

Currently this script only has a server console command to generate a backup within the `backups/` directory, more will come.

```bash
# file name without the extension, the script will add it itself
# if no filename is passed it'll generate one based on current date & time
backup_database [backup_filename]
```

## Config fields

### Database Operations

* **`QuerySize`**:
  * Defines the row count for each query batch when extracting data from tables.
  * **Default**: `100`


* **`ExcludedTables`**:
  * A list of table names to skip during the backup process.
  * **Default**: `nil` — Accepts: `string[] | false | nil`


* **`ExclusiveTables`**:
  * If defined, the script will **only** backup these tables and ignore all others.
  * **Default**: `nil` — Accepts: `string[] | false | nil`


### Cron (Automated Scheduling)

> [!INFO]
> This feature requires [`ox_lib`](https://github.com/CommunityOx/ox_lib) to be installed and running on your server.

* **`Cron.Enabled`**:
  * Toggles the automated backup scheduler.
  * **Default**: `false`


* **`Cron.Frequency`**:
  * Sets the timing logic. Accepts `"daily"` or `"hourly"`.


* **`Cron.Interval`**:
  * If Frequency is `daily`: The hour of the day (0-23) to run the backup.
  * If Frequency is `hourly`: Runs every X hours (e.g., `6` runs every 6 hours).


* **`Cron.ExpressionOverride`**:
  * Allows for a custom Cron Expression (e.g., `"0 0 * * *"`). This overrides Frequency and Interval settings.


### Archiver (Retention & Cleanup)

* **`Archiver.Enabled`**:
  * Toggles the automatic deletion of old backup files.
  * **Default**: `true`


* **`Archiver.ClearAfter`**:
  * How long to keep a backup before it is considered expired.
  * **Format**: `<number><unit>` (e.g., `"7d"` for 7 days, `"12h"` for 12 hours).


* **`Archiver.KeepMinimum`**:
  * A safety buffer that prevents the script from deleting files if the total count is at or below this number, regardless of age.
  * **Default**: `3`
