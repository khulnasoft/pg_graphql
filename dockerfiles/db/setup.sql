create extension pg_graphql;

create role anon;

grant usage on schema public to anon;
alter default privileges in schema public grant all on tables to anon;
alter default privileges in schema public grant all on functions to anon;
alter default privileges in schema public grant all on sequences to anon;

grant usage on schema graphql to anon;
grant all on function graphql.resolve to anon;

alter default privileges in schema graphql grant all on tables to anon;
alter default privileges in schema graphql grant all on functions to anon;
alter default privileges in schema graphql grant all on sequences to anon;


-- GraphQL Entrypoint
create function graphql(
    "operationName" text default null,
    query text default null,
    variables jsonb default null,
    extensions jsonb default null
)
    returns jsonb
    language sql
as $$
    select graphql.resolve(
        query := query,
        variables := coalesce(variables, '{}'),
        "operationName" := "operationName",
        extensions := extensions
    );
$$;


create table account(
    id serial primary key,
    email varchar(255) not null,
    created_at timestamp not null
);


create table blog(
    id serial primary key,
    owner_id integer not null references account(id) on delete cascade,
    name varchar(255) not null,
    description varchar(255),
    created_at timestamp not null
);


create type blog_post_status as enum ('PENDING', 'RELEASED');


create table blog_post(
    id uuid not null default gen_random_uuid() primary key,
    blog_id integer not null references blog(id) on delete cascade,
    title varchar(255) not null,
    body varchar(10000),
    status blog_post_status not null,
    created_at timestamp not null
);


-- 5 Accounts
insert into public.account(email, created_at)
values
    ('aardvark@x.com', now()),
    ('bat@x.com', now()),
    ('cat@x.com', now()),
    ('dog@x.com', now()),
    ('elephant@x.com', now());

insert into blog(owner_id, name, description, created_at)
values
    ((select id from account where email ilike 'a%'), 'A: Blog 1', 'a desc1', now()),
    ((select id from account where email ilike 'a%'), 'A: Blog 2', 'a desc2', now()),
    ((select id from account where email ilike 'a%'), 'A: Blog 3', 'a desc3', now()),
    ((select id from account where email ilike 'b%'), 'B: Blog 3', 'b desc1', now());


comment on schema public is '@graphql({"inflect_names": true})';
