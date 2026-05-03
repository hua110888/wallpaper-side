CREATE TABLE "categories" (
	"id" serial PRIMARY KEY,
	"name" varchar(100) NOT NULL,
	"slug" varchar(100) NOT NULL UNIQUE,
	"description" text,
	"cover_key" varchar(500),
	"order" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "wallpapers" (
	"id" serial PRIMARY KEY,
	"title" varchar(200) NOT NULL,
	"description" text,
	"blob_key" varchar(500) NOT NULL,
	"thumbnail_key" varchar(500),
	"width" integer,
	"height" integer,
	"file_size" integer,
	"mime_type" varchar(50),
	"category_id" integer,
	"tags" json DEFAULT '[]',
	"featured" boolean DEFAULT false,
	"daily_featured" boolean DEFAULT false,
	"daily_featured_date" varchar(20),
	"download_count" integer DEFAULT 0,
	"view_count" integer DEFAULT 0,
	"color" varchar(50),
	"is_hot" boolean DEFAULT false,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "wallpapers" ADD CONSTRAINT "wallpapers_category_id_categories_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id");