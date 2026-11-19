create extension if not exists pgcrypto;

-- Comptes : un numéro de téléphone = un compte (pas de mot de passe).
create table users (
  id uuid primary key default gen_random_uuid(),
  phone text unique not null,
  full_name text not null default '',
  role text not null default 'patient' check (role in ('patient', 'dietitian')),
  created_at timestamptz not null default now()
);

-- Codes SMS à usage unique, stockés hachés (HMAC), jamais en clair.
create table otp_codes (
  id bigserial primary key,
  phone text not null,
  name text,
  code_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0,
  consumed boolean not null default false,
  created_at timestamptz not null default now()
);
create index otp_codes_phone_idx on otp_codes (phone, created_at desc);

create table refresh_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users (id) on delete cascade,
  token_hash text unique not null,
  expires_at timestamptz not null,
  revoked boolean not null default false,
  created_at timestamptz not null default now()
);

create table dietitians (
  id text primary key,
  user_id uuid references users (id),
  initials text not null,
  name text not null,
  specialties_fr text not null,
  specialties_en text not null,
  languages_fr text not null,
  languages_en text not null,
  video boolean not null default true,
  in_person boolean not null default true,
  avatar_bg text not null,
  avatar_fg text not null
);

-- Créneaux hebdomadaires récurrents (1 = lundi … 5 = vendredi), heure locale Africa/Douala.
create table availability (
  dietitian_id text not null references dietitians (id) on delete cascade,
  weekday int not null check (weekday between 1 and 7),
  start_time time not null,
  primary key (dietitian_id, weekday, start_time)
);

create table holidays (
  month int not null,
  day int not null,
  primary key (month, day)
);

create table appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references users (id),
  dietitian_id text not null references dietitians (id),
  starts_at timestamptz not null,
  mode text not null check (mode in ('video', 'office')),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'refused', 'cancelled')),
  price_fcfa int not null,
  created_at timestamptz not null default now()
);
-- Un créneau ne peut être pris qu'une fois (rendez-vous en attente ou confirmé).
create unique index appointments_slot_unique
  on appointments (dietitian_id, starts_at) where status in ('pending', 'confirmed');
create index appointments_patient_idx on appointments (patient_id, starts_at);

create table payments (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references appointments (id),
  method text not null check (method in ('orange_money', 'mtn_momo', 'card')),
  amount_fcfa int not null,
  phone text,
  status text not null check (status in ('pending', 'paid', 'failed', 'refunded')),
  provider text not null,
  provider_ref text,
  created_at timestamptz not null default now()
);

create table health_profiles (
  user_id uuid primary key references users (id) on delete cascade,
  goal int check (goal between 0 and 3),
  conditions int[] not null default '{}',
  allergies int[] not null default '{}',
  updated_at timestamptz not null default now()
);

create table recipes (
  id text primary key,
  name_fr text not null,
  name_en text not null,
  kcal int not null,
  time text not null,
  tags int[] not null default '{}',
  c1 text not null, c2 text not null, c3 text not null, tint text not null,
  servings int not null,
  difficulty text not null check (difficulty in ('easy', 'medium')),
  protein int not null, carbs int not null, fat int not null,
  detail_title_fr text,
  detail_title_en text,
  detail_kcal int
);

create table recipe_ingredients (
  recipe_id text not null references recipes (id) on delete cascade,
  position int not null,
  name_fr text not null, name_en text not null,
  qty_fr text not null, qty_en text not null,
  primary key (recipe_id, position)
);

create table messages (
  id bigserial primary key,
  patient_id uuid not null references users (id),
  dietitian_id text not null references dietitians (id),
  sender_id uuid not null references users (id),
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index messages_conv_idx on messages (patient_id, dietitian_id, id);

-- Journal d'accès aux données de santé (qui a fait quoi, quand).
create table audit_log (
  id bigserial primary key,
  user_id uuid,
  action text not null,
  resource text not null,
  at timestamptz not null default now()
);
