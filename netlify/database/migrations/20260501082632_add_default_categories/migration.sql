INSERT INTO "categories" ("name", "slug", "description", "order") VALUES
  ('自然风光', 'nature', '山川湖海，自然美景', 1),
  ('城市建筑', 'city', '都市风光，建筑艺术', 2),
  ('动物世界', 'animals', '可爱萌宠，野生动物', 3),
  ('抽象艺术', 'abstract', '几何图形，抽象表达', 4),
  ('星空宇宙', 'space', '星河灿烂，宇宙奥秘', 5),
  ('极简风格', 'minimal', '简约美学，留白之美', 6)
ON CONFLICT (slug) DO NOTHING;
