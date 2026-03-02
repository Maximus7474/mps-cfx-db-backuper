# Cfx server Database Backup resource

For those who want to have a resource handle database backups, this will run within your FiveM or RedM server and create backups of your database.

> [!NOTE]  
> All suggestions, be it for improvements, security or even requesting new features are welcomed.
> There is no need for such a resource to be paid, escrowed as it should offer full transparency in it's features and behaviour

---

## Usage

The Archiver provides several server console commands to manage database backups and metadata. These commands are restricted to the **Server Console** (source 0) or players with the appropriate **ACE permissions**.

### Backup Commands

#### `backup_database [filename]`

Generates a full snapshot of the database and saves it to the `backups/` directory.

* **[filename]** *(Optional)*: The name of the file without an extension.
* **Default**: If no name is provided, the script generates a timestamped name (e.g., `backup_2026-03-02_16-41.sql`).

```bash
# example with custom name
backup_database Monday_Maintenance

# example with auto-generated name
backup_database
```

---

### Administrative Commands

These commands manage the **KVP (Key-Value Pair)** metadata used to track file ages for the auto-deletion logic.


#### `dump_kvp`

Exports all current backup metadata (filenames and Unix timestamps) into a readable JSON file.

* **Output Path**: `[resource_name]/archiveData.json`
* **Use Case**: Debugging or migrating metadata between servers.


#### `clear_kvp`

Wipes the internal database tracking. **Warning:** This does not delete physical files, but the script will no longer know how old they are, effectively preventing them from being auto-cleared.


#### `load_kvp`

Reads the `archiveData.json` file from the resource directory and restores it into the active KVP storage.

* **Requirement**: An `archiveData.json` file must exist (created via `dump_kvp`).
* **Use Case**: Restoring database tracking after a server wipe or migration.


---

### Technical Implementation Details

The Archiver uses a **Sorted-Minimum-Retention** logic. When `ClearAfter` is triggered:

1. It identifies files older than your configured threshold ($7d$, $24h$, etc.).
2. It sorts them by age (oldest first).
3. It deletes expired files one by one **only if** the remaining count stays above your `KeepMinimum` setting.

---

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
