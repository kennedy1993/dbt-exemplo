{{
    config(
        materialized = 'view'
    )
}}

with pedidos as (

    select
        pedido_id,
        cliente_id,
        data_pedido,
        status_pedido,
        valor_pedido,
        (status_pedido = 'concluido') as is_concluido
    from {{ ref('stg_pedidos') }}
    where cliente_id is not null

),

agregado_por_cliente as (

    select
        cliente_id,
        count(pedido_id) as total_pedidos,
        countif(is_concluido) as pedidos_concluidos,
        coalesce(sum(if(is_concluido, valor_pedido, 0)), 0) as receita_total,
        round(coalesce(avg(if(is_concluido, valor_pedido, null)), 0), 2) as ticket_medio,
        min(data_pedido) as data_primeiro_pedido,
        max(data_pedido) as data_ultimo_pedido
    from pedidos
    group by cliente_id

)

select
    cliente_id,
    total_pedidos,
    pedidos_concluidos,
    receita_total,
    ticket_medio,
    data_primeiro_pedido,
    data_ultimo_pedido
from agregado_por_cliente

