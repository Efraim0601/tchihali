-- Notifications : on garde le type + des données, l'application les affiche dans la langue de l'utilisateur.
alter table notifications add column data jsonb not null default '{}';

-- Un seul brouillon de compte rendu par patient et diététicien.
create unique index reports_one_draft on reports (patient_id, dietitian_id) where status = 'draft';
