# Cfx server Database Backup resource

For those who want to have a resource handle database backups, this will run within your FiveM or RedM server and create backups of your database.

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

```bash
clear_kvp
```


#### `load_kvp`

Reads the `archiveData.json` file from the resource directory and restores it into the active KVP storage.

* **Requirement**: An `archiveData.json` file must exist (created via `dump_kvp`).
* **Use Case**: Restoring database tracking after a server wipe or migration.

```bash
load_kvp
```


---

### Technical Implementation Details

The Archiver uses a **Sorted-Minimum-Retention** logic. When `ClearAfter` is triggered:

1. It identifies files older than your configured threshold ($7d$, $24h$, etc.).
2. It sorts them by age (oldest first).
3. It deletes expired files one by one **only if** the remaining count stays above your `KeepMinimum` setting.

---

## Config fields

* `QuerySize`:
  * Defines the size of each query batch within the system that obtains the data from the tables
  * Default: `100`
* `ExcludedTables`:
  * List the tables that shouldn't be backed up by the script
  * Default: `nil` - Accepts: `string[] | false | nil`
* `ExclusiveTables`:
  * List the only tables that should be backed up, all others will be ignored 
  * Default: `nil` - Accepts: `string[] | false | nil`
