{{
    config(
        materialized = 'view'
    )
}}

with fonte_clientes as (

    select
        id_cliente,
        nome_cliente,
        email,
        cidade,
        estado,
        data_cadastro
    from {{ ref('raw_clientes') }}
    where id_cliente is not null

),

clientes_padronizados as (

    select
        safe_cast(id_cliente as int64) as cliente_id,
        trim(cast(nome_cliente as string)) as nome_cliente,
        trim(cast(email as string)) as email,
        trim(cast(cidade as string)) as cidade,
        trim(cast(estado as string)) as uf,
        coalesce(
            safe_cast(data_cadastro as date),
            safe.parse_date('%Y-%m-%d', trim(cast(data_cadastro as string)))
        ) as data_cadastro
    from fonte_clientes

)

select
    cliente_id,
    nome_cliente,
    email,
    cidade,
    uf,
    data_cadastro
from clientes_padronizados
where cliente_id is not null

