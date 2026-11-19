-- Santé : taille, année de naissance, poids cible (calcul de l'IMC, objectif de la courbe).
alter table health_profiles
  add column height_cm int check (height_cm between 80 and 250),
  add column birth_year int check (birth_year between 1900 and 2100),
  add column goal_weight_kg numeric(4, 1) check (goal_weight_kg between 30 and 300);

-- Fichiers envoyés (photos de repas, photos de messages, documents). Le contenu est sur disque.
create table files (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references users (id) on delete cascade,
  kind text not null check (kind in ('meal_photo', 'chat_photo', 'document')),
  content_type text not null,
  size_bytes int not null,
  path text not null,
  created_at timestamptz not null default now()
);

create table meals (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references users (id) on delete cascade,
  eaten_at timestamptz not null,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'snack', 'dinner')),
  name text not null check (char_length(name) between 1 and 120),
  kcal int not null check (kcal between 0 and 5000),
  protein int not null default 0 check (protein between 0 and 500),
  carbs int not null default 0 check (carbs between 0 and 1000),
  fat int not null default 0 check (fat between 0 and 500),
  photo_file_id uuid references files (id),
  mood int check (mood between 0 and 4),
  symptoms int[] not null default '{}',
  created_at timestamptz not null default now()
);
create index meals_patient_idx on meals (patient_id, eaten_at);

-- Objectifs du jour cochés (indices 0..2 de la liste d'objectifs).
create table daily_goals (
  patient_id uuid not null references users (id) on delete cascade,
  day date not null,
  done int[] not null default '{}',
  primary key (patient_id, day)
);

create table measurements (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references users (id) on delete cascade,
  measured_on date not null,
  weight_kg numeric(4, 1) check (weight_kg between 20 and 400),
  waist_cm numeric(4, 1) check (waist_cm between 30 and 300),
  glucose_gl numeric(3, 2) check (glucose_gl between 0.2 and 9),
  created_at timestamptz not null default now(),
  unique (patient_id, measured_on)
);

-- Compte rendu de séance (rédigé par la diététicienne, visible par la patiente une fois envoyé).
create table reports (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references users (id) on delete cascade,
  dietitian_id text not null references dietitians (id),
  session_no int not null,
  held_on date not null,
  mode text not null default 'video' check (mode in ('video', 'office')),
  summary text not null default '',
  goals jsonb not null default '[]',   -- [{"text": "...", "done": true}]
  plan jsonb not null default '[]',    -- 7 jours : [{"meals": [{"text": "...", "kcal": 330}]}]
  measures jsonb not null default '{}',
  status text not null default 'draft' check (status in ('draft', 'sent')),
  updated_at timestamptz not null default now(),
  sent_at timestamptz
);
create index reports_patient_idx on reports (patient_id, held_on desc);

create table documents (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references users (id) on delete cascade,
  name text not null,
  meta text not null default '',
  file_id uuid references files (id),
  created_at timestamptz not null default now()
);
create index documents_patient_idx on documents (patient_id, created_at desc);

create table notifications (
  id bigserial primary key,
  user_id uuid not null references users (id) on delete cascade,
  kind text not null,
  title text not null,
  body text not null default '',
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create index notifications_user_idx on notifications (user_id, id desc);

-- Notes privées de la diététicienne sur un patient (jamais visibles du patient).
create table patient_notes (
  patient_id uuid not null references users (id) on delete cascade,
  dietitian_id text not null references dietitians (id),
  body text not null default '',
  updated_at timestamptz not null default now(),
  primary key (patient_id, dietitian_id)
);

-- Messages avec photo : le texte peut être vide si une photo est jointe.
alter table messages add column file_id uuid references files (id);
alter table messages drop constraint messages_body_check;
alter table messages add constraint messages_body_check
  check (char_length(body) <= 2000 and (char_length(body) > 0 or file_id is not null));
