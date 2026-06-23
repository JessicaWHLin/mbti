create table if not exists mbti_results (
  id bigserial primary key,
  name text not null,
  type text not null check (type ~ '^[EI][SN][TF][JP]$'),
  totals jsonb not null,
  question_ids jsonb not null,
  answers jsonb not null,
  created_at timestamptz not null default now()
);

create index if not exists mbti_results_created_at_idx
  on mbti_results (created_at desc);
