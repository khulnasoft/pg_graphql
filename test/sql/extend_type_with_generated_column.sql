begin;
    comment on schema public is '@graphql({"inflect_names": true})';

    create table public.account(
        id serial primary key,
        first_name varchar(255) not null,
        last_name varchar(255) not null,
        -- Computed Column
        full_name text generated always as (first_name || ' ' ||  last_name) stored
    );

    insert into public.account(first_name, last_name)
    values
        ('Foo', 'Fooington');


    select jsonb_pretty(
        graphql.resolve($$
    {
      accountCollection {
        edges {
          node {
            id
            firstName
            lastName
            fullName
          }
        }
      }
    }
        $$)
    );

rollback;
