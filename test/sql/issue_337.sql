begin;

-- A computed field function written in SQL and marked stable might return stale results.
-- Directly from the postgres docs(https://www.postgresql.org/docs/current/xfunc-volatility.html):

--For functions written in SQL or in any of the standard procedural languages,
--there is a second important property determined by the volatility category,
--namely the visibility of any data changes that have been made by the SQL
--command that is calling the function. A VOLATILE function will see such
--changes, a STABLE or IMMUTABLE function will not. This behavior is
--implemented using the snapshotting behavior of MVCC (see Chapter 13): STABLE
--and IMMUTABLE functions use a snapshot established as of the start of the
--calling query, whereas VOLATILE functions obtain a fresh snapshot at the
--start of each query they execute.

--The solution is to mark these functions as volatile

create table parent
(
    id uuid primary key default gen_random_uuid(),
    count int2
);

create table child
(
    id uuid primary key default gen_random_uuid(),
    parent_id uuid references parent not null,
    count int2
);

-- note that the function is marked stable and in written in sql
create or replace function _count(rec parent)
    returns smallint
    stable
    language sql
as
$$
    select sum(count)
    from child
    where parent_id = rec.id
$$;

insert into parent (id, count)
values ('8bcf0ee4-95ed-445f-808f-17b8194727ca', 1);

insert into child (id, parent_id, count)
values ('57738181-3d0f-45ad-96dd-3ba799b2d21d', '8bcf0ee4-95ed-445f-808f-17b8194727ca', 2),
       ('cb5993ff-e693-49cd-9114-a6510707e628', '8bcf0ee4-95ed-445f-808f-17b8194727ca', 3);

select jsonb_pretty(
  graphql.resolve($$
    query ParentQuery {
      parentCollection {
        edges {
          node {
            id
            count
            childCollection {
              edges {
                node {
                  count
                }
              }
            }
          }
        }
      }
    }
  $$)
);

-- since _count is stable, the value returned in parent.count field will be stale
-- i.e. parent.count is still 5 instead of (3 + 5) = 8
select jsonb_pretty(
  graphql.resolve($$
    mutation ChildMutation {
      updateChildCollection(
        filter: { id: { eq: "57738181-3d0f-45ad-96dd-3ba799b2d21d" } }
        set: { count: 5 }
      ) {
        records {
          id
          count
          parent {
            id
            count
          }
        }
      }
    }
  $$)
);

-- note that the function is marked volatile
create or replace function _count(rec parent)
    returns smallint
    volatile
    language sql
as
$$
    select sum(count)
    from child
    where parent_id = rec.id
$$;

-- since _count is volatile, the value returned in parent.count field will be fresh
-- i.e. parent.count is correctly at (3 + 7) 10
select jsonb_pretty(
  graphql.resolve($$
    mutation ChildMutation {
      updateChildCollection(
        filter: { id: { eq: "57738181-3d0f-45ad-96dd-3ba799b2d21d" } }
        set: { count: 7 }
      ) {
        records {
          id
          count
          parent {
            id
            count
          }
        }
      }
    }
  $$)
);

rollback;
