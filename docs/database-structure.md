# Database Structure

This site uses Netlify Database, which provisions a Postgres database for the Netlify project and applies SQL migrations from `netlify/database/migrations`.

It is possible to edit the database structure outside this agent through GitHub or Cursor by adding new migration folders under `netlify/database/migrations`. The existing applied migrations must remain on disk with their original content. To change an existing table, add a new migration that rolls the schema forward.

## Existing Core Tables

- `categories`: Wallpaper categories shown in navigation and category pages.
- `wallpapers`: Main wallpaper records, including image blob keys, metadata, category, counts, and feature flags.

## Added Tables

- `app_users`: Optional user/admin profile records for uploads, favorites, moderation, and future account features.
- `wallpaper_variants`: Generated or uploaded image sizes for each wallpaper, such as thumbnail, mobile, desktop, or original.
- `tags`: Normalized tag names and slugs.
- `wallpaper_tag_links`: Many-to-many relationship between wallpapers and normalized tags.
- `collections`: Curated wallpaper groups for homepage sections, campaigns, or editorial pages.
- `collection_wallpapers`: Ordered wallpapers inside each collection.
- `favorites`: User-saved wallpapers.
- `wallpaper_events`: View, download, share, and other event tracking for analytics.
- `wallpaper_reports`: User or admin reports for moderation workflows.
- `site_settings`: Small JSON configuration values for site behavior.

## Added Wallpaper Fields

- `slug`: Stable URL-friendly identifier.
- `status`: Publishing state, defaulting to `draft`.
- `source_url`: Optional credit or source link.
- `license`: Optional license label.
- `alt_text`: Accessible image description.
- `uploaded_by`: Optional uploader reference.
- `published_at`: Publication timestamp.

## Recommended Editing Workflow

Add future schema changes as new migration folders with a `migration.sql` file. Do not edit or remove migrations that have already been applied to a Netlify database branch.
