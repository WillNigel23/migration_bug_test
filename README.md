## Context

Regarding this changelog: https://github.com/rails/rails/blob/8-0-stable/activerecord/CHANGELOG.md

```
When running db:migrate on a fresh database, load the databases schemas before running migrations.
```

Seems like, calling db:migrate now first loads the current `db/schema.rb` first, rebuild the db from that before running migrations after current schema version.

This causes issues when:

- db migrations have some CRUD operations (understandably not suggested, but is still common practice)

- when we need to edit old migrations, then expecting `db:drop db:create db:migrate` to re-run those older migrations. seems like it does not re-run old migrations, rather loads the schema declared in db/schema.rb

## Reproduction Steps

1. Run `rails g migration TestMigration`

2. Create any table with columns you want

3. Run `db:migrate` for the first time after creating the `TestMigration`. This will create `db/schema.rb` containing the columns initially declared in migration. This will also produce logs like below:

```
== 20241127000358 TestMigration: migrating ====================================
-- create_table(:some_models)
   -> 0.0570s
== 20241127000358 TestMigration: migrated (0.0572s) ===========================
```

4. Run `db:drop db:create`.

5. Edit `TestMigration` to include some additional changes (maybe add some more columns)

6. Run `db:migrate`. Now this should now not show any logs like the one in `3`

The expected result is that, the added columns are not present. This is likely because `db/schema.rb` is now present and we load from that rather than running the migrations from scratch.

## Workaround

We can re-run old migrations by deleting db/schema.rb first then re-running `db:migrate`.

## Test it yourself

In this branch, assume we have already done steps 1-5 in Reproduction steps.

Running `db:migrate` here should not add the `:some_other_text` column to the `:some_models` table.
