begin;

    create table account(
        id serial primary key,
        email varchar(255) not null,
        encrypted_password varchar(255) not null,
        created_at timestamp not null,
        updated_at timestamp not null
    );


    select jsonb_pretty(
        graphql.resolve($$
        {
          __type(name: "Account") {
            kind
            fields {
                name
            }
          }
        }
        $$)
    );

    select jsonb_pretty(
        graphql.resolve($$
        {
          __type(name: "DoesNotExist") {
            kind
            fields {
                name
            }
          }
        }
        $$)
    );

rollback;
