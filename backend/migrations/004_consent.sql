-- Consentement aux conditions d'utilisation et à la politique de confidentialité (preuve datée et versionnée).
alter table users
  add column terms_accepted_at timestamptz,
  add column terms_version text;
alter table otp_codes add column terms_version text;
