begin;
    -- https://github.com/khulnasoft/pg_graphql/issues/300
    create role api;

    create table project (
        id serial primary key,
        title text not null,
        created_at int not null default '1',
        updated_at int not null default '2'
    );

    grant usage on schema graphql to api;
    grant usage on all sequences in schema public to api;

    revoke all on table project from api;
    grant select on table project to api;
    grant insert (id, title) on table project to api;
    grant update (title) on table project to api;
    grant delete on table project to api;

    set role to 'api';

    select jsonb_pretty(
        graphql.resolve($$

    mutation CreateProject {
      insertIntoProjectCollection(objects: [
        {title: "foo"}
      ]) {
        affectedCount
        records {
          id
          title
          createdAt
          updatedAt
        }
      }
    }
    $$
        )
    );

rollback;
