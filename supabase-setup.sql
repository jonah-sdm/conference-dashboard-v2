-- ============================================================================
-- SDM Conference Dashboard v2 — Supabase Setup
-- Run this in the Supabase SQL Editor (https://supabase.com/dashboard)
-- ============================================================================

-- 1. CONFERENCES
CREATE TABLE conferences (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text UNIQUE NOT NULL,
  location   text,
  quarter    text CHECK (quarter IN ('Q1','Q2','Q3','Q4')),
  status     text DEFAULT 'Planning' CHECK (status IN ('Planning','Completed')),
  created_at timestamptz DEFAULT now()
);

-- 2. PEOPLE
CREATE TABLE people (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text UNIQUE NOT NULL,
  initials     text NOT NULL,
  base_location text,
  role         text,
  note         text,
  color_text   text,
  color_bg     text,
  color_border text,
  created_at   timestamptz DEFAULT now()
);

-- 3. EXPENSES
CREATE TABLE expenses (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conference_id uuid NOT NULL REFERENCES conferences(id) ON DELETE CASCADE,
  person_id     uuid NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  category      text NOT NULL CHECK (category IN (
    'Flights',
    'Hotel / Lodging',
    'Conference Ticket',
    'Meals / Per Diem',
    'Ground Transport',
    'Misc'
  )),
  budgeted      numeric DEFAULT 0,
  actual        numeric DEFAULT 0,
  quarter       text,
  created_at    timestamptz DEFAULT now()
);

-- 4. THREADS (comments)
CREATE TABLE threads (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_key text NOT NULL,
  thread_id  text NOT NULL,
  text       text NOT NULL,
  ts         bigint NOT NULL,
  resolved   boolean DEFAULT false,
  replies    jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- ============================================================================
-- ROW LEVEL SECURITY — open read/write for internal team (no auth)
-- ============================================================================

ALTER TABLE conferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE people      ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses    ENABLE ROW LEVEL SECURITY;
ALTER TABLE threads     ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_all_conferences" ON conferences FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_people"      ON people      FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_expenses"    ON expenses    FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_threads"     ON threads     FOR ALL TO anon USING (true) WITH CHECK (true);

-- 5. EXPLORE CONFERENCES (discovery / prospect list)
CREATE TABLE explore_conferences (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  location    text,
  start_date  date,
  end_date    date,
  url         text,
  thumbnail   text,
  description text,
  tags        text,
  source      text DEFAULT 'manual' CHECK (source IN ('manual','csv','api')),
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE explore_conferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_all_explore" ON explore_conferences FOR ALL TO anon USING (true) WITH CHECK (true);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_expenses_conference ON expenses(conference_id);
CREATE INDEX idx_expenses_person     ON expenses(person_id);
CREATE INDEX idx_threads_key         ON threads(thread_key);

-- ============================================================================
-- SEED DATA — Team Members
-- ============================================================================

INSERT INTO people (name, initials, base_location, role, note, color_text, color_bg, color_border) VALUES
  ('Mostafa', 'MO', 'Toronto / Miami',      'CEO',           'Toronto/Miami-based — North American conferences are low cost. European and international stops carry full flight premium.',              '#F5C125', 'rgba(245,193,37,0.12)',  'rgba(245,193,37,0.3)'),
  ('Zach',    'ZA', 'Toronto, ON',           'BD Lead',       'Toronto-based — North American conferences are cost-efficient; international conferences carry full transatlantic flight cost.',         '#3b82f6', 'rgba(59,130,246,0.12)',  'rgba(59,130,246,0.3)'),
  ('Yacine',  'YA', 'Toronto, ON',           'Strategy',      'Toronto-based — same home base as Zach. North American events are cost-efficient; European and Middle Eastern routes carry full flight cost.', '#a78bfa', 'rgba(167,139,250,0.12)', 'rgba(167,139,250,0.3)'),
  ('Alan',    'AL', 'Fort Lauderdale, FL',   'Finance',       'Fort Lauderdale-based — Florida conferences have near-zero travel cost. US domestic travel is efficient; international adds flight premium.',   '#10b981', 'rgba(16,185,129,0.12)',  'rgba(16,185,129,0.3)'),
  ('Moe',     'M2', 'Toronto, ON',           'Sales',         'Toronto-based — North American conference travel is cost-efficient. Cyprus and European stops require transatlantic routing.',           '#fb923c', 'rgba(251,146,60,0.12)',  'rgba(251,146,60,0.3)'),
  ('Matt',    'MT', 'London, UK',            'Payments Lead', 'London-based — UK and European conferences have no flight cost vs. North American team members.',                                       '#f43f5e', 'rgba(244,63,94,0.12)',   'rgba(244,63,94,0.3)'),
  ('Fred',    'FR', 'Porto, Portugal',       'Payments',      'Porto-based — European conferences are low cost. UK events are a short flight. US and international stops carry full transatlantic premium.', '#22d3ee', 'rgba(34,211,238,0.12)',  'rgba(34,211,238,0.3)');
