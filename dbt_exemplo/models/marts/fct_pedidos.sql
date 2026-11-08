{{
    config(
        materialized = 'table',
        partition_by = {
            "field": "data_pedido",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by = ["status_pedido", "cliente_id"]
    )
}}

with pedidos as (

    select
        pedido_id,
        cliente_id,
        data_pedido,
        status_pedido,
        valor_pedido,
        metodo_pagamento
    from {{ ref('stg_pedidos') }}

),

clientes as (

    select
        cliente_id,
        nome_cliente,
        cidade,
        uf
    from {{ ref('stg_clientes') }}

)

select
    p.pedido_id,
    p.cliente_id,
    c.nome_cliente,
    c.cidade,
    c.uf,
    p.data_pedido,
    p.status_pedido,
    p.metodo_pagamento,
    p.valor_pedido,
    if(p.status_pedido = 'concluido', p.valor_pedido, 0) as valor_receita_liquida,
    (p.status_pedido = 'concluido') as is_pedido_concluido
from pedidos as p
left join clientes as c
    on p.cliente_id = c.cliente_id

