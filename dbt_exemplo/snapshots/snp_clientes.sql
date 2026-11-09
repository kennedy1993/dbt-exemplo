{% snapshot snp_clientes %}

{{
    config(
        target_schema='dbt_dev',
        unique_key='cliente_id',
        strategy='check',
        check_cols=['cidade', 'uf', 'email']
    )
}}

select
    cliente_id,
    nome_cliente,
    email,
    cidade,
    uf,
    data_cadastro
from {{ ref('stg_clientes') }}

{% endsnapshot %}

