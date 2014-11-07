drop table if exists users;
create table users(
  id integer primary key,
  name text,
  nickname text,
  Password text,
  email text,
  twitter_id text,
  card_id text, -- FeliCa
  created_at timestamp,
  updated_at timestamp
);

drop table if exists conditions;
create table conditions(
  id integer primary key,
  user_id integer,
  entrance_time datetime, -- 入室時刻
  exit_time datetime,     -- 退室時刻
  staytus boolean,
  access_times integer,   -- 訪問回数
  staying_time integer,   -- 合計滞在時間[分]
  created_at timestamp,
  updated_at timestamp
);