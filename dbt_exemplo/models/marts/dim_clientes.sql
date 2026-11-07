{{
    config(
        materialized = 'table'
    )
}}

with clientes as (

    select
        cliente_id,
        nome_cliente,
        email,
        cidade,
        uf,
        data_cadastro
    from {{ ref('stg_clientes') }}

),

metricas_pedidos as (

    select
        cliente_id,
        total_pedidos,
        pedidos_concluidos,
        receita_total,
        ticket_medio,
        data_primeiro_pedido,
        data_ultimo_pedido
    from {{ ref('int_pedidos_por_cliente') }}

),

clientes_enriquecidos as (

    select
        c.cliente_id,
        c.nome_cliente,
        c.email,
        c.cidade,
        c.uf,
        c.data_cadastro,
        coalesce(m.total_pedidos, 0) as total_pedidos,
        coalesce(m.pedidos_concluidos, 0) as pedidos_concluidos,
        coalesce(m.receita_total, 0) as receita_total,
        coalesce(m.ticket_medio, 0) as ticket_medio,
        m.data_primeiro_pedido,
        m.data_ultimo_pedido
    from clientes as c
    left join metricas_pedidos as m
        on c.cliente_id = m.cliente_id

)

select
    cliente_id,
    nome_cliente,
    email,
    cidade,
    uf,
    data_cadastro,
    total_pedidos,
    pedidos_concluidos,
    receita_total,
    ticket_medio,
    data_primeiro_pedido,
    data_ultimo_pedido,
    case
        when receita_total >= 1000 then 'VIP'
        when pedidos_concluidos >= 1 then 'Ativo'
        else 'Sem Compras Concluidas'
    end as segmento_cliente
from clientes_enriquecidos

