{{
    config(
        materialized = 'view'
    )
}}

with fonte_pedidos as (

    select
        id_pedido,
        id_cliente,
        data_pedido,
        status_pedido,
        valor_pedido,
        metodo_pagamento
    from {{ ref('raw_pedidos') }}
    where id_pedido is not null

),

pedidos_padronizados as (

    select
        safe_cast(id_pedido as int64) as pedido_id,
        safe_cast(id_cliente as int64) as cliente_id,
        coalesce(
            safe_cast(data_pedido as date),
            safe.parse_date('%Y-%m-%d', trim(cast(data_pedido as string)))
        ) as data_pedido,
        trim(cast(status_pedido as string)) as status_pedido,
        safe_cast(valor_pedido as numeric) as valor_pedido,
        trim(cast(metodo_pagamento as string)) as metodo_pagamento
    from fonte_pedidos

)

select
    pedido_id,
    cliente_id,
    data_pedido,
    status_pedido,
    valor_pedido,
    metodo_pagamento
from pedidos_padronizados
where pedido_id is not null

