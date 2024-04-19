begin;
    -- https://github.com/khulnasoft/pg_graphql/issues/237
    savepoint a;
    create table blog_post(
        id int primary key,
        a text,
        b text,
        c text,
        d text,
        e text,
        f text
    );
    insert into public.blog_post
    values (1, 'a', 'b', 'c', 'd', 'e', 'f');
    select jsonb_pretty(
      graphql.resolve($$
        query {
          blogPostCollection {
            edges {
              node {
                a
                ...c_query
                ... @include(if: true) {
                  e
                }
              }
            }
          }
          blogPostCollection {
            edges {
              node {
                b
                ...d_query
                ... @include(if: true) {
                  f
                }
              }
            }
          }
        }

        fragment c_query on BlogPost {
          c
        }

        fragment d_query on BlogPost {
          d
        }
      $$)
    );

    rollback to savepoint a;

    create table account(
        id serial primary key,
        email varchar(255) not null
    );

    insert into public.account(email)
    values
        ('aardvark@x.com');

    create table blog(
        id serial primary key,
        owner_id integer not null references account(id),
        name varchar(255) not null
    );

    insert into blog(owner_id, name)
    values
        (1, 'A: Blog 1');

    select jsonb_pretty(graphql.resolve($$ {
        accountCollection {
            edges {
                node {
                    email
                    email
                    id_alias: id
                    id_alias: id
                }
            }
        }
    }$$));

    select jsonb_pretty(graphql.resolve($$ {
        accountCollection(first: 1) {
            edges {
                node {
                    id
                    email
                }
            }
        }
        accountCollection(first: 1) {
            edges {
                node {
                    id
                    email
                }
            }
        }
    }$$));

    select jsonb_pretty(graphql.resolve($$ {
        accountCollection(first: $count) {
            edges {
                node {
                    id
                    email
                }
            }
        }
        accountCollection(first: $count) {
            edges {
                node {
                    id
                    email
                }
            }
        }
    }$$,
    jsonb_build_object(
        'count', 1
    )));

    select jsonb_pretty(graphql.resolve($$ {
        accountCollection {
            edges {
                ... on AccountEdge {
                    cursor
                    cursor
                    node {
                        id
                        email
                    }
                }
                ... on AccountEdge {
                    cursor
                    cursor
                    node {
                        id
                        email
                    }
                }
                ... cursorsFragment
                ... anotherCursorsFragment
                cursor
                cursor
                node {
                    id
                    email
                }
            }
        }
    }
    fragment cursorsFragment on AccountEdge {
        cursor
        cursor
        node {
            id
            email
        }
    }
    fragment anotherCursorsFragment on AccountEdge {
        cursor
        cursor
        node {
            id
            email
        }
    }
    $$));

    select jsonb_pretty(graphql.resolve($$ {
        accountCollection {
            edges {
                cursor
                cursor
                node {
                    id
                    email
                }
                node {
                    id
                    email
                }
            }
            edges {
                cursor
                cursor
                node {
                    id
                    email
                }
                node {
                    id
                    email
                }
            }
        }
    }
    $$));

    select graphql.encode('["public", "account", 1]'::jsonb);
    select graphql.encode('["public", "blog", 1]'::jsonb);

    select jsonb_pretty(graphql.resolve($$ {
        node(nodeId: "WyJwdWJsaWMiLCAiYWNjb3VudCIsIDFd") {
            nodeId
            ... on Account {
                id
                str: email
            }
            ... on Blog {
                id
                str: name
            }
        }
    }
    $$));

    select jsonb_pretty(graphql.resolve($$ {
        node(nodeId: "WyJwdWJsaWMiLCAiYmxvZyIsIDFd") {
            nodeId
            ... on Account {
                id
                str: email
            }
            ... on Blog {
                id
                str: name
            }
        }
    }
    $$));

rollback;
