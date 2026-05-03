CREATE TABLE IF NOT EXISTS "app_users" (
  "id" serial PRIMARY KEY,
  "external_id" varchar(200) UNIQUE,
  "email" varchar(255) UNIQUE,
  "display_name" varchar(120),
  "avatar_url" text,
  "role" varchar(40) NOT NULL DEFAULT 'viewer',
  "status" varchar(40) NOT NULL DEFAULT 'active',
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "slug" varchar(220);
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "status" varchar(40) NOT NULL DEFAULT 'draft';
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "source_url" text;
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "license" varchar(120);
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "alt_text" varchar(300);
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "uploaded_by" integer;
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD COLUMN IF NOT EXISTS "published_at" timestamp;
--> statement-breakpoint
UPDATE "wallpapers"
SET "slug" = lower(regexp_replace(regexp_replace("title", '[^a-zA-Z0-9]+', '-', 'g'), '(^-|-$)', '', 'g')) || '-' || "id"
WHERE "slug" IS NULL;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "wallpapers_slug_unique_idx" ON "wallpapers" ("slug") WHERE "slug" IS NOT NULL;
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD CONSTRAINT "wallpapers_uploaded_by_app_users_id_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "app_users"("id") ON DELETE SET NULL;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "wallpaper_variants" (
  "id" serial PRIMARY KEY,
  "wallpaper_id" integer NOT NULL REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "variant_type" varchar(40) NOT NULL,
  "blob_key" varchar(500) NOT NULL,
  "width" integer,
  "height" integer,
  "file_size" integer,
  "mime_type" varchar(80),
  "created_at" timestamp DEFAULT now(),
  UNIQUE ("wallpaper_id", "variant_type")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "tags" (
  "id" serial PRIMARY KEY,
  "name" varchar(100) NOT NULL,
  "slug" varchar(100) NOT NULL UNIQUE,
  "created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "wallpaper_tag_links" (
  "wallpaper_id" integer NOT NULL REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "tag_id" integer NOT NULL REFERENCES "tags"("id") ON DELETE CASCADE,
  "created_at" timestamp DEFAULT now(),
  PRIMARY KEY ("wallpaper_id", "tag_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "collections" (
  "id" serial PRIMARY KEY,
  "title" varchar(160) NOT NULL,
  "slug" varchar(160) NOT NULL UNIQUE,
  "description" text,
  "cover_wallpaper_id" integer REFERENCES "wallpapers"("id") ON DELETE SET NULL,
  "is_featured" boolean NOT NULL DEFAULT false,
  "sort_order" integer NOT NULL DEFAULT 0,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "collection_wallpapers" (
  "collection_id" integer NOT NULL REFERENCES "collections"("id") ON DELETE CASCADE,
  "wallpaper_id" integer NOT NULL REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "position" integer NOT NULL DEFAULT 0,
  "added_at" timestamp DEFAULT now(),
  PRIMARY KEY ("collection_id", "wallpaper_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "favorites" (
  "id" serial PRIMARY KEY,
  "user_id" integer NOT NULL REFERENCES "app_users"("id") ON DELETE CASCADE,
  "wallpaper_id" integer NOT NULL REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "created_at" timestamp DEFAULT now(),
  UNIQUE ("user_id", "wallpaper_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "wallpaper_events" (
  "id" bigserial PRIMARY KEY,
  "wallpaper_id" integer REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "user_id" integer REFERENCES "app_users"("id") ON DELETE SET NULL,
  "event_type" varchar(40) NOT NULL,
  "session_id" varchar(160),
  "ip_hash" varchar(160),
  "user_agent" text,
  "date_key" date NOT NULL DEFAULT CURRENT_DATE,
  "created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "wallpaper_reports" (
  "id" serial PRIMARY KEY,
  "wallpaper_id" integer NOT NULL REFERENCES "wallpapers"("id") ON DELETE CASCADE,
  "reporter_email" varchar(255),
  "reason" varchar(120) NOT NULL,
  "details" text,
  "status" varchar(40) NOT NULL DEFAULT 'open',
  "created_at" timestamp DEFAULT now(),
  "reviewed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "site_settings" (
  "key" varchar(120) PRIMARY KEY,
  "value" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpapers_category_id_idx" ON "wallpapers" ("category_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpapers_status_created_at_idx" ON "wallpapers" ("status", "created_at");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpapers_featured_idx" ON "wallpapers" ("featured") WHERE "featured" = true;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpapers_daily_featured_date_idx" ON "wallpapers" ("daily_featured_date");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpapers_uploaded_by_idx" ON "wallpapers" ("uploaded_by");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpaper_variants_wallpaper_id_idx" ON "wallpaper_variants" ("wallpaper_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpaper_tag_links_tag_id_idx" ON "wallpaper_tag_links" ("tag_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "collection_wallpapers_wallpaper_id_idx" ON "collection_wallpapers" ("wallpaper_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "favorites_wallpaper_id_idx" ON "favorites" ("wallpaper_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpaper_events_wallpaper_id_created_at_idx" ON "wallpaper_events" ("wallpaper_id", "created_at");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "wallpaper_events_type_date_idx" ON "wallpaper_events" ("event_type", "date_key");
--> statement-breakpoint
INSERT INTO "site_settings" ("key", "value") VALUES
  ('homepage', '{"featuredLimit": 12, "latestLimit": 24, "showDailyFeatured": true}'::jsonb),
  ('uploads', '{"allowedMimeTypes": ["image/jpeg", "image/png", "image/webp"], "maxFileSizeMb": 25}'::jsonb)
ON CONFLICT ("key") DO NOTHING;
