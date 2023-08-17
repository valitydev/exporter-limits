create table if not exists dw.flyway_schema_history
(
    installed_rank integer                 not null
        constraint flyway_schema_history_pk
            primary key,
    version        varchar(50),
    description    varchar(200)            not null,
    type           varchar(20)             not null,
    script         varchar(1000)           not null,
    checksum       integer,
    installed_by   varchar(100)            not null,
    installed_on   timestamp default now() not null,
    execution_time integer                 not null,
    success        boolean                 not null
);

alter table dw.flyway_schema_history
    owner to postgres;

create index if not exists flyway_schema_history_s_idx
    on dw.flyway_schema_history (success);

create table if not exists dw.adjustment
(
    id                           bigserial
        primary key,
    event_created_at             timestamp                                      not null,
    domain_revision              bigint                                         not null,
    adjustment_id                varchar                                        not null,
    payment_id                   varchar                                        not null,
    invoice_id                   varchar                                        not null,
    party_id                     varchar                                        not null,
    shop_id                      varchar                                        not null,
    created_at                   timestamp                                      not null,
    status                       dw.adjustment_status                           not null,
    status_captured_at           timestamp,
    status_cancelled_at          timestamp,
    reason                       varchar                                        not null,
    wtime                        timestamp default timezone('utc'::text, now()) not null,
    current                      boolean   default true                         not null,
    party_revision               bigint,
    sequence_id                  bigint,
    change_id                    integer,
    payment_status               dw.payment_status,
    amount                       bigint                                         not null,
    provider_amount_diff         bigint    default 0,
    system_amount_diff           bigint    default 0,
    external_income_amount_diff  bigint    default 0,
    external_outcome_amount_diff bigint    default 0,
    constraint adjustment_uniq
        unique (invoice_id, sequence_id, change_id)
);

alter table dw.adjustment
    owner to postgres;

create index if not exists adjustment_created_at
    on dw.adjustment (created_at);

create index if not exists adjustment_event_created_at
    on dw.adjustment (event_created_at);

create index if not exists adjustment_invoice_id
    on dw.adjustment (invoice_id);

create index if not exists adjustment_party_id
    on dw.adjustment (party_id);

create index if not exists adjustment_status
    on dw.adjustment (status);

create table if not exists dw.cash_flow_link
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    payment_id       varchar                                        not null,
    sequence_id      bigint,
    change_id        integer,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    current          boolean   default false                        not null,
    constraint cash_flow_link_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.cash_flow_link
    owner to postgres;

create table if not exists dw.cash_flow
(
    id                             bigserial
        primary key,
    obj_id                         bigint                 not null,
    obj_type                       dw.payment_change_type not null,
    adj_flow_type                  dw.adjustment_cash_flow_type,
    source_account_type            dw.cash_flow_account   not null,
    source_account_type_value      varchar                not null,
    source_account_id              bigint                 not null,
    destination_account_type       dw.cash_flow_account   not null,
    destination_account_type_value varchar                not null,
    destination_account_id         bigint                 not null,
    amount                         bigint                 not null,
    currency_code                  varchar                not null,
    details                        varchar
);

alter table dw.cash_flow
    owner to postgres;

create index if not exists cash_flow_idx
    on dw.cash_flow (obj_id, obj_type);

create table if not exists dw.calendar
(
    id                bigserial
        primary key,
    version_id        bigint                                         not null,
    calendar_ref_id   integer                                        not null,
    name              varchar                                        not null,
    description       varchar,
    timezone          varchar                                        not null,
    holidays_json     varchar                                        not null,
    first_day_of_week integer,
    wtime             timestamp default timezone('utc'::text, now()) not null,
    current           boolean   default true                         not null
);

alter table dw.calendar
    owner to postgres;

create index if not exists calendar_idx
    on dw.calendar (calendar_ref_id);

create index if not exists calendar_version_id
    on dw.calendar (version_id);

create table if not exists dw.category
(
    id              bigserial
        primary key,
    version_id      bigint                                         not null,
    category_ref_id integer                                        not null,
    name            varchar                                        not null,
    description     varchar                                        not null,
    type            varchar,
    wtime           timestamp default timezone('utc'::text, now()) not null,
    current         boolean   default true                         not null
);

alter table dw.category
    owner to postgres;

create index if not exists category_idx
    on dw.category (category_ref_id);

create index if not exists category_version_id
    on dw.category (version_id);

create table if not exists dw.challenge
(
    id                    bigserial
        primary key,
    event_created_at      timestamp                                      not null,
    event_occured_at      timestamp                                      not null,
    sequence_id           integer                                        not null,
    identity_id           varchar                                        not null,
    challenge_id          varchar                                        not null,
    challenge_class_id    varchar                                        not null,
    challenge_status      dw.challenge_status                            not null,
    challenge_resolution  dw.challenge_resolution,
    challenge_valid_until timestamp,
    wtime                 timestamp default timezone('utc'::text, now()) not null,
    current               boolean   default true                         not null,
    proofs_json           varchar,
    constraint challenge_uniq
        unique (challenge_id, identity_id, sequence_id)
);

alter table dw.challenge
    owner to postgres;

create index if not exists challenge_event_created_at_idx
    on dw.challenge (event_created_at);

create index if not exists challenge_event_occured_at_idx
    on dw.challenge (event_occured_at);

create index if not exists challenge_id_idx
    on dw.challenge (challenge_id);

create table if not exists dw.chargeback
(
    id                 bigserial
        primary key,
    sequence_id        bigint                                         not null,
    change_id          integer                                        not null,
    domain_revision    bigint                                         not null,
    party_revision     bigint,
    chargeback_id      varchar                                        not null,
    payment_id         varchar                                        not null,
    invoice_id         varchar                                        not null,
    shop_id            varchar                                        not null,
    party_id           varchar                                        not null,
    external_id        varchar,
    event_created_at   timestamp                                      not null,
    created_at         timestamp                                      not null,
    status             dw.chargeback_status                           not null,
    levy_amount        bigint,
    levy_currency_code varchar,
    amount             bigint,
    currency_code      varchar,
    reason_code        varchar,
    reason_category    dw.chargeback_category                         not null,
    stage              dw.chargeback_stage                            not null,
    current            boolean   default true                         not null,
    context            bytea,
    wtime              timestamp default timezone('utc'::text, now()) not null,
    constraint chargeback_uniq
        unique (invoice_id, sequence_id, change_id)
);

alter table dw.chargeback
    owner to postgres;

create index if not exists chargeback_created_at
    on dw.chargeback (created_at);

create index if not exists chargeback_event_created_at
    on dw.chargeback (event_created_at);

create index if not exists chargeback_invoice_id
    on dw.chargeback (invoice_id);

create index if not exists chargeback_party_id
    on dw.chargeback (party_id);

create index if not exists chargeback_status
    on dw.chargeback (status);

create table if not exists dw.contract
(
    id                                                         bigserial
        primary key,
    event_created_at                                           timestamp                                      not null,
    contract_id                                                varchar                                        not null,
    party_id                                                   varchar                                        not null,
    payment_institution_id                                     integer,
    created_at                                                 timestamp                                      not null,
    valid_since                                                timestamp,
    valid_until                                                timestamp,
    status                                                     dw.contract_status                             not null,
    status_terminated_at                                       timestamp,
    terms_id                                                   integer                                        not null,
    legal_agreement_signed_at                                  timestamp,
    legal_agreement_id                                         varchar,
    legal_agreement_valid_until                                timestamp,
    report_act_schedule_id                                     integer,
    report_act_signer_position                                 varchar,
    report_act_signer_full_name                                varchar,
    report_act_signer_document                                 dw.representative_document,
    report_act_signer_doc_power_of_attorney_signed_at          timestamp,
    report_act_signer_doc_power_of_attorney_legal_agreement_id varchar,
    report_act_signer_doc_power_of_attorney_valid_until        timestamp,
    contractor_id                                              varchar,
    wtime                                                      timestamp default timezone('utc'::text, now()) not null,
    current                                                    boolean   default true                         not null,
    sequence_id                                                integer,
    change_id                                                  integer,
    claim_effect_id                                            integer,
    constraint contract_uniq
        unique (party_id, contract_id, sequence_id, change_id, claim_effect_id)
);

alter table dw.contract
    owner to postgres;

create index if not exists contract_contract_id
    on dw.contract (contract_id);

create index if not exists contract_created_at
    on dw.contract (created_at);

create index if not exists contract_event_created_at
    on dw.contract (event_created_at);

create index if not exists contract_party_id
    on dw.contract (party_id);

create table if not exists dw.contract_adjustment
(
    id                     bigserial
        primary key,
    cntrct_id              bigint    not null,
    contract_adjustment_id varchar   not null,
    created_at             timestamp not null,
    valid_since            timestamp,
    valid_until            timestamp,
    terms_id               integer   not null
);

alter table dw.contract_adjustment
    owner to postgres;

create index if not exists contract_adjustment_idx
    on dw.contract_adjustment (cntrct_id);

create table if not exists dw.contract_revision
(
    id       bigserial
        primary key,
    obj_id   bigint                                         not null,
    revision bigint                                         not null,
    wtime    timestamp default timezone('utc'::text, now()) not null
);

alter table dw.contract_revision
    owner to postgres;

create unique index if not exists contract_revision_idx
    on dw.contract_revision (obj_id, revision);

create table if not exists dw.contractor
(
    id                                             bigserial
        primary key,
    event_created_at                               timestamp                                      not null,
    party_id                                       varchar                                        not null,
    contractor_id                                  varchar                                        not null,
    type                                           dw.contractor_type                             not null,
    identificational_level                         varchar,
    registered_user_email                          varchar,
    legal_entity                                   dw.legal_entity,
    russian_legal_entity_registered_name           varchar,
    russian_legal_entity_registered_number         varchar,
    russian_legal_entity_inn                       varchar,
    russian_legal_entity_actual_address            varchar,
    russian_legal_entity_post_address              varchar,
    russian_legal_entity_representative_position   varchar,
    russian_legal_entity_representative_full_name  varchar,
    russian_legal_entity_representative_document   varchar,
    russian_legal_entity_russian_bank_account      varchar,
    russian_legal_entity_russian_bank_name         varchar,
    russian_legal_entity_russian_bank_post_account varchar,
    russian_legal_entity_russian_bank_bik          varchar,
    international_legal_entity_legal_name          varchar,
    international_legal_entity_trading_name        varchar,
    international_legal_entity_registered_address  varchar,
    international_legal_entity_actual_address      varchar,
    international_legal_entity_registered_number   varchar,
    private_entity                                 dw.private_entity,
    russian_private_entity_first_name              varchar,
    russian_private_entity_second_name             varchar,
    russian_private_entity_middle_name             varchar,
    russian_private_entity_phone_number            varchar,
    russian_private_entity_email                   varchar,
    wtime                                          timestamp default timezone('utc'::text, now()) not null,
    current                                        boolean   default true                         not null,
    sequence_id                                    integer,
    change_id                                      integer,
    claim_effect_id                                integer,
    international_legal_entity_country_code        varchar,
    constraint contractor_uniq
        unique (party_id, contractor_id, sequence_id, change_id, claim_effect_id)
);

alter table dw.contractor
    owner to postgres;

create index if not exists contractor_contractor_id
    on dw.contractor (contractor_id);

create index if not exists contractor_event_created_at
    on dw.contractor (event_created_at);

create index if not exists contractor_party_id
    on dw.contractor (party_id);

create table if not exists dw.contractor_revision
(
    id       bigserial
        primary key,
    obj_id   bigint                                         not null,
    revision bigint                                         not null,
    wtime    timestamp default timezone('utc'::text, now()) not null
);

alter table dw.contractor_revision
    owner to postgres;

create unique index if not exists contractor_revision_idx
    on dw.contractor_revision (obj_id, revision);

create table if not exists dw.country
(
    id             bigserial
        primary key,
    version_id     bigint                                         not null,
    country_ref_id varchar                                        not null,
    name           varchar                                        not null,
    trade_bloc     text[]                                         not null,
    wtime          timestamp default timezone('utc'::text, now()) not null,
    current        boolean   default true                         not null
);

alter table dw.country
    owner to postgres;

create table if not exists dw.currency
(
    id              bigserial
        primary key,
    version_id      bigint                                         not null,
    currency_ref_id varchar                                        not null,
    name            varchar                                        not null,
    symbolic_code   varchar                                        not null,
    numeric_code    smallint                                       not null,
    exponent        smallint                                       not null,
    wtime           timestamp default timezone('utc'::text, now()) not null,
    current         boolean   default true                         not null
);

alter table dw.currency
    owner to postgres;

create index if not exists currency_idx
    on dw.currency (currency_ref_id);

create index if not exists currency_version_id
    on dw.currency (version_id);

create table if not exists dw.deposit
(
    id                      bigserial
        primary key,
    event_created_at        timestamp                                      not null,
    event_occured_at        timestamp                                      not null,
    sequence_id             integer                                        not null,
    source_id               varchar                                        not null,
    wallet_id               varchar                                        not null,
    deposit_id              varchar                                        not null,
    amount                  bigint                                         not null,
    fee                     bigint,
    provider_fee            bigint,
    currency_code           varchar                                        not null,
    deposit_status          dw.deposit_status                              not null,
    deposit_transfer_status dw.deposit_transfer_status,
    wtime                   timestamp default timezone('utc'::text, now()) not null,
    current                 boolean   default true                         not null,
    external_id             varchar,
    constraint deposit_uniq
        unique (deposit_id, sequence_id)
);

alter table dw.deposit
    owner to postgres;

create index if not exists deposit_event_created_at_idx
    on dw.deposit (event_created_at);

create index if not exists deposit_event_occured_at_idx
    on dw.deposit (event_occured_at);

create index if not exists deposit_id_idx
    on dw.deposit (deposit_id);

create table if not exists dw.deposit_adjustment
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    event_occured_at timestamp                                      not null,
    sequence_id      integer                                        not null,
    source_id        varchar                                        not null,
    wallet_id        varchar                                        not null,
    deposit_id       varchar                                        not null,
    adjustment_id    varchar                                        not null,
    amount           bigint,
    fee              bigint,
    provider_fee     bigint,
    currency_code    varchar,
    status           dw.deposit_adjustment_status                   not null,
    transfer_status  dw.deposit_transfer_status,
    deposit_status   dw.deposit_status,
    external_id      varchar,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    current          boolean   default true                         not null,
    party_revision   bigint    default 0                            not null,
    domain_revision  bigint    default 0                            not null,
    constraint deposit_adjustment_uniq
        unique (deposit_id, adjustment_id, sequence_id)
);

alter table dw.deposit_adjustment
    owner to postgres;

create index if not exists deposit_adjustment_event_created_at_idx
    on dw.deposit_adjustment (event_created_at);

create index if not exists deposit_adjustment_id_idx
    on dw.deposit_adjustment (deposit_id);

create table if not exists dw.deposit_revert
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    event_occured_at timestamp                                      not null,
    sequence_id      integer                                        not null,
    source_id        varchar                                        not null,
    wallet_id        varchar                                        not null,
    deposit_id       varchar                                        not null,
    revert_id        varchar                                        not null,
    amount           bigint                                         not null,
    fee              bigint,
    provider_fee     bigint,
    currency_code    varchar                                        not null,
    status           dw.deposit_revert_status                       not null,
    transfer_status  dw.deposit_transfer_status,
    reason           varchar,
    external_id      varchar,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    current          boolean   default true                         not null,
    party_revision   bigint    default 0                            not null,
    domain_revision  bigint    default 0                            not null,
    constraint deposit_revert_uniq
        unique (deposit_id, revert_id, sequence_id)
);

alter table dw.deposit_revert
    owner to postgres;

create index if not exists deposit_revert_event_created_at_idx
    on dw.deposit_revert (event_created_at);

create index if not exists deposit_revert_id_idx
    on dw.deposit_revert (deposit_id);

create table if not exists dw.destination
(
    id                                bigserial
        primary key,
    event_created_at                  timestamp                                      not null,
    event_occured_at                  timestamp                                      not null,
    sequence_id                       integer                                        not null,
    destination_id                    varchar                                        not null,
    destination_name                  varchar                                        not null,
    destination_status                dw.destination_status                          not null,
    resource_bank_card_token          varchar,
    resource_bank_card_payment_system varchar,
    resource_bank_card_bin            varchar,
    resource_bank_card_masked_pan     varchar,
    account_id                        varchar,
    identity_id                       varchar,
    party_id                          varchar,
    accounter_account_id              bigint,
    currency_code                     varchar,
    wtime                             timestamp default timezone('utc'::text, now()) not null,
    current                           boolean   default true                         not null,
    external_id                       varchar,
    created_at                        timestamp,
    context_json                      varchar,
    resource_crypto_wallet_id         varchar,
    resource_crypto_wallet_type       varchar,
    resource_type                     dw.destination_resource_type                   not null,
    resource_crypto_wallet_data       varchar,
    resource_bank_card_type           varchar,
    resource_bank_card_issuer_country varchar,
    resource_bank_card_bank_name      varchar,
    resource_digital_wallet_id        varchar,
    resource_digital_wallet_data      varchar,
    constraint destination_uniq
        unique (destination_id, sequence_id)
);

alter table dw.destination
    owner to postgres;

create index if not exists destination_event_created_at_idx
    on dw.destination (event_created_at);

create index if not exists destination_event_occured_at_idx
    on dw.destination (event_occured_at);

create index if not exists destination_id_idx
    on dw.destination (destination_id);

create table if not exists dw.fistful_cash_flow
(
    id                             bigserial
        primary key,
    obj_id                         bigint                           not null,
    source_account_type            dw.cash_flow_account             not null,
    source_account_type_value      varchar                          not null,
    source_account_id              varchar                          not null,
    destination_account_type       dw.cash_flow_account             not null,
    destination_account_type_value varchar                          not null,
    destination_account_id         varchar                          not null,
    amount                         bigint                           not null,
    currency_code                  varchar                          not null,
    details                        varchar,
    obj_type                       dw.fistful_cash_flow_change_type not null
);

alter table dw.fistful_cash_flow
    owner to postgres;

create index if not exists fistful_cash_flow_obj_id_idx
    on dw.fistful_cash_flow (obj_id);

create table if not exists dw.identity
(
    id                             bigserial
        primary key,
    event_created_at               timestamp                                      not null,
    event_occured_at               timestamp                                      not null,
    sequence_id                    integer                                        not null,
    party_id                       varchar                                        not null,
    party_contract_id              varchar,
    identity_id                    varchar                                        not null,
    identity_provider_id           varchar                                        not null,
    identity_effective_chalenge_id varchar,
    identity_level_id              varchar,
    wtime                          timestamp default timezone('utc'::text, now()) not null,
    current                        boolean   default true                         not null,
    external_id                    varchar,
    blocked                        boolean,
    context_json                   varchar,
    constraint identity_uniq
        unique (identity_id, sequence_id)
);

alter table dw.identity
    owner to postgres;

create index if not exists identity_event_created_at_idx
    on dw.identity (event_created_at);

create index if not exists identity_event_occured_at_idx
    on dw.identity (event_occured_at);

create index if not exists identity_id_idx
    on dw.identity (identity_id);

create index if not exists identity_party_id_idx
    on dw.identity (party_id);

create table if not exists dw.inspector
(
    id                    bigserial
        primary key,
    version_id            bigint                                         not null,
    inspector_ref_id      integer                                        not null,
    name                  varchar                                        not null,
    description           varchar                                        not null,
    proxy_ref_id          integer                                        not null,
    proxy_additional_json varchar                                        not null,
    fallback_risk_score   varchar,
    wtime                 timestamp default timezone('utc'::text, now()) not null,
    current               boolean   default true                         not null
);

alter table dw.inspector
    owner to postgres;

create index if not exists inspector_idx
    on dw.inspector (inspector_ref_id);

create index if not exists inspector_version_id
    on dw.inspector (version_id);

create table if not exists dw.invoice
(
    id                  bigserial
        primary key,
    event_created_at    timestamp                                      not null,
    invoice_id          varchar                                        not null,
    party_id            varchar                                        not null,
    shop_id             varchar                                        not null,
    party_revision      bigint,
    created_at          timestamp                                      not null,
    details_product     varchar                                        not null,
    details_description varchar,
    due                 timestamp                                      not null,
    amount              bigint                                         not null,
    currency_code       varchar                                        not null,
    context             bytea,
    template_id         varchar,
    wtime               timestamp default timezone('utc'::text, now()) not null,
    sequence_id         bigint,
    change_id           integer,
    external_id         varchar,
    constraint invoice_uniq
        unique (invoice_id, sequence_id, change_id)
);

alter table dw.invoice
    owner to postgres;

create index if not exists invoice_created_at
    on dw.invoice (created_at);

create index if not exists invoice_event_created_at
    on dw.invoice (event_created_at);

create index if not exists invoice_external_id_idx
    on dw.invoice (external_id)
    where (external_id IS NOT NULL);

create index if not exists invoice_invoice_id
    on dw.invoice (invoice_id);

create index if not exists invoice_party_id
    on dw.invoice (party_id);

create table if not exists dw.invoice_status_info
(
    id               bigserial
        constraint invoice_status_pkey
            primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    status           dw.invoice_status                              not null,
    details          varchar,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    current          boolean   default false                        not null,
    sequence_id      bigint,
    change_id        integer,
    external_id      varchar,
    constraint invoice_status_uniq
        unique (invoice_id, sequence_id, change_id)
);

alter table dw.invoice_status_info
    owner to postgres;

create index if not exists invoice_status
    on dw.invoice_status_info (status);

create table if not exists dw.invoice_cart
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    product          varchar,
    quantity         integer                                        not null,
    amount           bigint                                         not null,
    currency_code    varchar                                        not null,
    metadata_json    varchar                                        not null,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    sequence_id      bigint,
    change_id        integer
);

alter table dw.invoice_cart
    owner to postgres;

create index if not exists invoice_cart_invoice_id
    on dw.invoice_cart (invoice_id);

create table if not exists dw.party
(
    id                         bigserial
        primary key,
    event_created_at           timestamp                                      not null,
    party_id                   varchar                                        not null,
    contact_info_email         varchar                                        not null,
    created_at                 timestamp                                      not null,
    blocking                   dw.blocking                                    not null,
    blocking_unblocked_reason  varchar,
    blocking_unblocked_since   timestamp,
    blocking_blocked_reason    varchar,
    blocking_blocked_since     timestamp,
    suspension                 dw.suspension                                  not null,
    suspension_active_since    timestamp,
    suspension_suspended_since timestamp,
    revision                   bigint                                         not null,
    revision_changed_at        timestamp,
    party_meta_set_ns          varchar,
    party_meta_set_data_json   varchar,
    wtime                      timestamp default timezone('utc'::text, now()) not null,
    current                    boolean   default true                         not null,
    sequence_id                integer,
    change_id                  integer,
    constraint party_uniq
        unique (party_id, sequence_id, change_id)
);

alter table dw.party
    owner to postgres;

create index if not exists party_contact_info_email
    on dw.party (contact_info_email);

create index if not exists party_created_at
    on dw.party (created_at);

create index if not exists party_current
    on dw.party (current);

create index if not exists party_event_created_at
    on dw.party (event_created_at);

create index if not exists party_party_id
    on dw.party (party_id);

create table if not exists dw.payment
(
    id                              bigserial
        primary key,
    event_created_at                timestamp                                      not null,
    invoice_id                      varchar                                        not null,
    payment_id                      varchar                                        not null,
    created_at                      timestamp                                      not null,
    party_id                        varchar                                        not null,
    shop_id                         varchar                                        not null,
    domain_revision                 bigint                                         not null,
    party_revision                  bigint,
    amount                          bigint                                         not null,
    currency_code                   varchar                                        not null,
    make_recurrent                  boolean,
    sequence_id                     bigint,
    change_id                       integer,
    wtime                           timestamp default timezone('utc'::text, now()) not null,
    external_id                     varchar,
    payment_flow_type               dw.payment_flow_type                           not null,
    payment_flow_on_hold_expiration varchar,
    payment_flow_held_until         timestamp,
    constraint payment_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment
    owner to postgres;

create index if not exists payment_created_at
    on dw.payment (created_at);

create index if not exists payment_event_created_at
    on dw.payment (event_created_at);

create index if not exists payment_external_id_idx
    on dw.payment (external_id)
    where (external_id IS NOT NULL);

create index if not exists payment_invoice_id
    on dw.payment (invoice_id);

create index if not exists payment_party_id
    on dw.payment (party_id);

create table if not exists dw.payment_fee
(
    id                bigserial
        primary key,
    event_created_at  timestamp                                      not null,
    invoice_id        varchar                                        not null,
    payment_id        varchar                                        not null,
    fee               bigint,
    provider_fee      bigint,
    external_fee      bigint,
    guarantee_deposit bigint,
    current           boolean   default false                        not null,
    wtime             timestamp default timezone('utc'::text, now()) not null,
    sequence_id       bigint,
    change_id         integer,
    constraint payment_fee_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_fee
    owner to postgres;

create table if not exists dw.payment_route
(
    id                bigserial
        primary key,
    event_created_at  timestamp                                      not null,
    invoice_id        varchar                                        not null,
    payment_id        varchar                                        not null,
    route_provider_id integer,
    route_terminal_id integer,
    sequence_id       bigint,
    change_id         integer,
    wtime             timestamp default timezone('utc'::text, now()) not null,
    current           boolean   default false                        not null,
    constraint payment_route_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_route
    owner to postgres;

create table if not exists dw.payment_status_info
(
    id               bigserial
        constraint payment_status_pkey
            primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    payment_id       varchar                                        not null,
    status           dw.payment_status                              not null,
    reason           varchar,
    amount           bigint,
    currency_code    varchar,
    cart_json        varchar,
    current          boolean   default false                        not null,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    sequence_id      bigint,
    change_id        integer,
    constraint payment_status_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_status_info
    owner to postgres;

create index if not exists payment_status_info_idx
    on dw.payment_status_info (status, event_created_at);

create table if not exists dw.payment_payer_info
(
    id                           bigserial
        constraint payment_payment_payer_info_pkey
            primary key,
    event_created_at             timestamp                                      not null,
    invoice_id                   varchar,
    payment_id                   varchar,
    payer_type                   dw.payer_type                                  not null,
    payment_tool_type            dw.payment_tool_type                           not null,
    bank_card_token              varchar,
    bank_card_payment_system     varchar,
    bank_card_bin                varchar,
    bank_card_masked_pan         varchar,
    bank_card_token_provider     varchar,
    payment_terminal_type        varchar,
    digital_wallet_provider      varchar,
    digital_wallet_id            varchar,
    payment_session_id           varchar,
    ip_address                   varchar,
    fingerprint                  varchar,
    phone_number                 varchar,
    email                        varchar,
    customer_id                  varchar,
    customer_binding_id          varchar,
    customer_rec_payment_tool_id varchar,
    recurrent_parent_invoice_id  varchar,
    recurrent_parent_payment_id  varchar,
    crypto_currency_type         varchar,
    mobile_phone_cc              varchar,
    mobile_phone_ctn             varchar,
    issuer_country               varchar,
    bank_name                    varchar,
    bank_card_cardholder_name    varchar,
    mobile_operator              varchar,
    wtime                        timestamp default timezone('utc'::text, now()) not null,
    sequence_id                  bigint,
    change_id                    integer,
    constraint payment_payment_payer_info_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_payer_info
    owner to postgres;

create table if not exists dw.payment_additional_info
(
    id                    bigserial
        primary key,
    event_created_at      timestamp                                      not null,
    invoice_id            varchar                                        not null,
    payment_id            varchar                                        not null,
    transaction_id        varchar,
    extra_json            varchar,
    rrn                   varchar,
    approval_code         varchar,
    acs_url               varchar,
    md                    varchar,
    term_url              varchar,
    eci                   varchar,
    cavv                  varchar,
    xid                   varchar,
    cavv_algorithm        varchar,
    three_ds_verification varchar,
    current               boolean   default false                        not null,
    wtime                 timestamp default timezone('utc'::text, now()) not null,
    sequence_id           bigint,
    change_id             integer,
    constraint payment_additional_info_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_additional_info
    owner to postgres;

create table if not exists dw.payment_recurrent_info
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    payment_id       varchar                                        not null,
    token            varchar,
    current          boolean   default false                        not null,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    sequence_id      bigint,
    change_id        integer,
    constraint payment_recurrent_info_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_recurrent_info
    owner to postgres;

create table if not exists dw.payment_risk_data
(
    id               bigserial
        primary key,
    event_created_at timestamp                                      not null,
    invoice_id       varchar                                        not null,
    payment_id       varchar                                        not null,
    risk_score       dw.risk_score                                  not null,
    current          boolean   default false                        not null,
    wtime            timestamp default timezone('utc'::text, now()) not null,
    sequence_id      bigint,
    change_id        integer,
    constraint payment_risk_data_uniq
        unique (invoice_id, payment_id, sequence_id, change_id)
);

alter table dw.payment_risk_data
    owner to postgres;

create table if not exists dw.payment_institution
(
    id                                    bigserial
        primary key,
    version_id                            bigint                                         not null,
    payment_institution_ref_id            integer                                        not null,
    name                                  varchar                                        not null,
    description                           varchar,
    calendar_ref_id                       integer,
    system_account_set_json               varchar                                        not null,
    default_contract_template_json        varchar                                        not null,
    default_wallet_contract_template_json varchar,
    providers_json                        varchar,
    inspector_json                        varchar                                        not null,
    realm                                 varchar                                        not null,
    residences_json                       varchar                                        not null,
    wtime                                 timestamp default timezone('utc'::text, now()) not null,
    current                               boolean   default true                         not null
);

alter table dw.payment_institution
    owner to postgres;

create index if not exists payment_institution_idx
    on dw.payment_institution (payment_institution_ref_id);

create index if not exists payment_institution_version_id
    on dw.payment_institution (version_id);

create table if not exists dw.payment_method
(
    id                    bigserial
        primary key,
    version_id            bigint                                         not null,
    payment_method_ref_id varchar                                        not null,
    name                  varchar                                        not null,
    description           varchar                                        not null,
    type                  dw.payment_method_type                         not null,
    wtime                 timestamp default timezone('utc'::text, now()) not null,
    current               boolean   default true                         not null
);

alter table dw.payment_method
    owner to postgres;

create index if not exists payment_method_idx
    on dw.payment_method (payment_method_ref_id);

create index if not exists payment_method_version_id
    on dw.payment_method (version_id);

create table if not exists dw.payment_routing_rule
(
    id                     bigserial
        primary key,
    rule_ref_id            integer                                        not null,
    name                   varchar                                        not null,
    description            varchar,
    wtime                  timestamp default timezone('utc'::text, now()) not null,
    current                boolean   default true                         not null,
    routing_decisions_json varchar                                        not null,
    version_id             bigint                                         not null
);

alter table dw.payment_routing_rule
    owner to postgres;

create index if not exists payment_routing_rule_ref_id
    on dw.payment_routing_rule (rule_ref_id);

create table if not exists dw.payout
(
    id                bigserial
        constraint payout_id_pkey
            primary key,
    payout_id         varchar                                        not null,
    event_created_at  timestamp                                      not null,
    sequence_id       integer                                        not null,
    created_at        timestamp                                      not null,
    party_id          varchar                                        not null,
    shop_id           varchar                                        not null,
    status            dw.payout_status                               not null,
    payout_tool_id    varchar                                        not null,
    amount            bigint                                         not null,
    fee               bigint    default 0                            not null,
    currency_code     varchar                                        not null,
    cancelled_details varchar,
    wtime             timestamp default timezone('utc'::text, now()) not null,
    current           boolean   default true                         not null,
    constraint payout_payout_id_ukey
        unique (payout_id, sequence_id)
);

alter table dw.payout
    owner to postgres;

create table if not exists dw.payout_method
(
    id                   bigserial
        primary key,
    version_id           bigint                                         not null,
    payout_method_ref_id varchar                                        not null,
    name                 varchar                                        not null,
    description          varchar                                        not null,
    wtime                timestamp default timezone('utc'::text, now()) not null,
    current              boolean   default true                         not null
);

alter table dw.payout_method
    owner to postgres;

create index if not exists payout_method_idx
    on dw.payout_method (payout_method_ref_id);

create index if not exists payout_method_version_id
    on dw.payout_method (version_id);

create table if not exists dw.payout_tool
(
    id                                                             bigserial
        primary key,
    cntrct_id                                                      bigint              not null,
    payout_tool_id                                                 varchar             not null,
    created_at                                                     timestamp           not null,
    currency_code                                                  varchar             not null,
    payout_tool_info                                               dw.payout_tool_info not null,
    payout_tool_info_russian_bank_account                          varchar,
    payout_tool_info_russian_bank_name                             varchar,
    payout_tool_info_russian_bank_post_account                     varchar,
    payout_tool_info_russian_bank_bik                              varchar,
    payout_tool_info_international_bank_account_holder             varchar,
    payout_tool_info_international_bank_name                       varchar,
    payout_tool_info_international_bank_address                    varchar,
    payout_tool_info_international_bank_iban                       varchar,
    payout_tool_info_international_bank_bic                        varchar,
    payout_tool_info_international_bank_local_code                 varchar,
    payout_tool_info_international_bank_number                     varchar,
    payout_tool_info_international_bank_aba_rtn                    varchar,
    payout_tool_info_international_bank_country_code               varchar,
    payout_tool_info_international_correspondent_bank_account      varchar,
    payout_tool_info_international_correspondent_bank_name         varchar,
    payout_tool_info_international_correspondent_bank_address      varchar,
    payout_tool_info_international_correspondent_bank_bic          varchar,
    payout_tool_info_international_correspondent_bank_iban         varchar,
    payout_tool_info_international_correspondent_bank_number       varchar,
    payout_tool_info_international_correspondent_bank_aba_rtn      varchar,
    payout_tool_info_international_correspondent_bank_country_code varchar,
    payout_tool_info_wallet_info_wallet_id                         varchar
);

alter table dw.payout_tool
    owner to postgres;

create index if not exists payout_tool_idx
    on dw.payout_tool (cntrct_id);

create table if not exists dw.provider
(
    id                           bigserial
        primary key,
    version_id                   bigint                                         not null,
    provider_ref_id              integer                                        not null,
    name                         varchar                                        not null,
    description                  varchar                                        not null,
    proxy_ref_id                 integer                                        not null,
    terminal_json                varchar,
    abs_account                  varchar,
    payment_terms_json           varchar,
    recurrent_paytool_terms_json varchar,
    accounts_json                varchar,
    wtime                        timestamp default timezone('utc'::text, now()) not null,
    current                      boolean   default true                         not null,
    identity                     varchar,
    wallet_terms_json            varchar,
    params_schema_json           varchar
);

alter table dw.provider
    owner to postgres;

create index if not exists provider_idx
    on dw.provider (provider_ref_id);

create index if not exists provider_version_id
    on dw.provider (version_id);

create table if not exists dw.proxy
(
    id           bigserial
        primary key,
    version_id   bigint                                         not null,
    proxy_ref_id integer                                        not null,
    name         varchar                                        not null,
    description  varchar                                        not null,
    url          varchar                                        not null,
    wtime        timestamp default timezone('utc'::text, now()) not null,
    current      boolean   default true                         not null
);

alter table dw.proxy
    owner to postgres;

create index if not exists proxy_idx
    on dw.proxy (proxy_ref_id);

create index if not exists proxy_version_id
    on dw.proxy (version_id);

create table if not exists dw.rate
(
    id                        bigserial
        primary key,
    event_created_at          timestamp                                      not null,
    source_id                 varchar                                        not null,
    lower_bound_inclusive     timestamp                                      not null,
    upper_bound_exclusive     timestamp                                      not null,
    source_symbolic_code      varchar                                        not null,
    source_exponent           smallint                                       not null,
    destination_symbolic_code varchar                                        not null,
    destination_exponent      smallint                                       not null,
    exchange_rate_rational_p  bigint                                         not null,
    exchange_rate_rational_q  bigint                                         not null,
    wtime                     timestamp default timezone('utc'::text, now()) not null,
    current                   boolean   default true                         not null,
    sequence_id               bigint
);

alter table dw.rate
    owner to postgres;

create index if not exists rate_event_created_at_idx
    on dw.rate (event_created_at);

create index if not exists rate_source_id_idx
    on dw.rate (source_id);

create unique index if not exists rate_ukey
    on dw.rate (source_id, sequence_id, source_symbolic_code, destination_symbolic_code);

create table if not exists dw.recurrent_payment_tool
(
    id                                                        bigserial
        primary key,
    sequence_id                                               integer                                        not null,
    change_id                                                 integer                                        not null,
    event_created_at                                          timestamp                                      not null,
    recurrent_payment_tool_id                                 varchar                                        not null,
    created_at                                                timestamp                                      not null,
    party_id                                                  varchar                                        not null,
    shop_id                                                   varchar                                        not null,
    party_revision                                            bigint,
    domain_revision                                           bigint                                         not null,
    status                                                    dw.recurrent_payment_tool_status               not null,
    status_failed_failure                                     varchar,
    payment_tool_type                                         dw.payment_tool_type                           not null,
    bank_card_token                                           varchar,
    bank_card_payment_system                                  varchar,
    bank_card_bin                                             varchar,
    bank_card_masked_pan                                      varchar,
    bank_card_token_provider                                  varchar,
    bank_card_issuer_country                                  varchar,
    bank_card_bank_name                                       varchar,
    bank_card_metadata_json                                   varchar,
    bank_card_is_cvv_empty                                    boolean,
    bank_card_exp_date_month                                  integer,
    bank_card_exp_date_year                                   integer,
    bank_card_cardholder_name                                 varchar,
    payment_terminal_type                                     varchar,
    digital_wallet_provider                                   varchar,
    digital_wallet_id                                         varchar,
    digital_wallet_token                                      varchar,
    crypto_currency                                           varchar,
    mobile_commerce_operator_legacy                           dw.mobile_operator_type,
    mobile_commerce_phone_cc                                  varchar,
    mobile_commerce_phone_ctn                                 varchar,
    payment_session_id                                        varchar,
    client_info_ip_address                                    varchar,
    client_info_fingerprint                                   varchar,
    rec_token                                                 varchar,
    route_provider_id                                         integer,
    route_terminal_id                                         integer,
    amount                                                    bigint,
    currency_code                                             varchar,
    risk_score                                                varchar,
    session_payload_transaction_bound_trx_id                  varchar,
    session_payload_transaction_bound_trx_extra_json          varchar,
    session_payload_transaction_bound_trx_additional_info_rrn varchar,
    wtime                                                     timestamp default timezone('utc'::text, now()) not null,
    current                                                   boolean   default true                         not null,
    mobile_commerce_operator                                  varchar,
    constraint recurrent_payment_tool_uniq
        unique (recurrent_payment_tool_id, sequence_id, change_id)
);

alter table dw.recurrent_payment_tool
    owner to postgres;

create index if not exists recurrent_payment_tool_id_idx
    on dw.recurrent_payment_tool (recurrent_payment_tool_id);

create table if not exists dw.refund
(
    id                                               bigserial
        primary key,
    event_created_at                                 timestamp                                      not null,
    domain_revision                                  bigint                                         not null,
    refund_id                                        varchar                                        not null,
    payment_id                                       varchar                                        not null,
    invoice_id                                       varchar                                        not null,
    party_id                                         varchar                                        not null,
    shop_id                                          varchar                                        not null,
    created_at                                       timestamp                                      not null,
    status                                           dw.refund_status                               not null,
    status_failed_failure                            varchar,
    amount                                           bigint,
    currency_code                                    varchar,
    reason                                           varchar,
    wtime                                            timestamp default timezone('utc'::text, now()) not null,
    current                                          boolean   default true                         not null,
    session_payload_transaction_bound_trx_id         varchar,
    session_payload_transaction_bound_trx_extra_json varchar,
    fee                                              bigint,
    provider_fee                                     bigint,
    external_fee                                     bigint,
    party_revision                                   bigint,
    sequence_id                                      bigint,
    change_id                                        integer,
    external_id                                      varchar,
    constraint refund_uniq
        unique (invoice_id, sequence_id, change_id)
);

alter table dw.refund
    owner to postgres;

create index if not exists refund_created_at
    on dw.refund (created_at);

create index if not exists refund_event_created_at
    on dw.refund (event_created_at);

create index if not exists refund_external_id_idx
    on dw.refund (external_id)
    where (external_id IS NOT NULL);

create index if not exists refund_invoice_id
    on dw.refund (invoice_id);

create index if not exists refund_party_id
    on dw.refund (party_id);

create index if not exists refund_status
    on dw.refund (status);

create table if not exists dw.shedlock
(
    name       varchar(64) not null
        primary key,
    lock_until timestamp(3),
    locked_at  timestamp(3),
    locked_by  varchar(255)
);

alter table dw.shedlock
    owner to postgres;

create table if not exists dw.shop
(
    id                         bigserial
        primary key,
    event_created_at           timestamp                                      not null,
    party_id                   varchar                                        not null,
    shop_id                    varchar                                        not null,
    created_at                 timestamp                                      not null,
    blocking                   dw.blocking                                    not null,
    blocking_unblocked_reason  varchar,
    blocking_unblocked_since   timestamp,
    blocking_blocked_reason    varchar,
    blocking_blocked_since     timestamp,
    suspension                 dw.suspension                                  not null,
    suspension_active_since    timestamp,
    suspension_suspended_since timestamp,
    details_name               varchar                                        not null,
    details_description        varchar,
    location_url               varchar                                        not null,
    category_id                integer                                        not null,
    account_currency_code      varchar,
    account_settlement         bigint,
    account_guarantee          bigint,
    account_payout             bigint,
    contract_id                varchar                                        not null,
    payout_tool_id             varchar,
    payout_schedule_id         integer,
    wtime                      timestamp default timezone('utc'::text, now()) not null,
    current                    boolean   default true                         not null,
    sequence_id                integer,
    change_id                  integer,
    claim_effect_id            integer,
    constraint shop_uniq
        unique (party_id, shop_id, sequence_id, change_id, claim_effect_id)
);

alter table dw.shop
    owner to postgres;

create index if not exists shop_created_at
    on dw.shop (created_at);

create index if not exists shop_event_created_at
    on dw.shop (event_created_at);

create index if not exists shop_party_id
    on dw.shop (party_id);

create index if not exists shop_shop_id
    on dw.shop (shop_id);

create table if not exists dw.shop_revision
(
    id       bigserial
        primary key,
    obj_id   bigint                                         not null,
    revision bigint                                         not null,
    wtime    timestamp default timezone('utc'::text, now()) not null
);

alter table dw.shop_revision
    owner to postgres;

create unique index if not exists shop_revision_idx
    on dw.shop_revision (obj_id, revision);

create table if not exists dw.source
(
    id                        bigserial
        primary key,
    event_created_at          timestamp                                      not null,
    event_occured_at          timestamp                                      not null,
    sequence_id               integer                                        not null,
    source_id                 varchar                                        not null,
    source_name               varchar                                        not null,
    source_status             dw.source_status                               not null,
    resource_internal_details varchar,
    account_id                varchar,
    identity_id               varchar,
    party_id                  varchar,
    accounter_account_id      bigint,
    currency_code             varchar,
    wtime                     timestamp default timezone('utc'::text, now()) not null,
    current                   boolean   default true                         not null,
    external_id               varchar,
    constraint source_uniq
        unique (source_id, sequence_id)
);

alter table dw.source
    owner to postgres;

create index if not exists source_event_created_at_idx
    on dw.source (event_created_at);

create index if not exists source_event_occured_at_idx
    on dw.source (event_occured_at);

create index if not exists source_id_idx
    on dw.source (source_id);

create table if not exists dw.term_set_hierarchy
(
    id                        bigserial
        primary key,
    version_id                bigint                                         not null,
    term_set_hierarchy_ref_id integer                                        not null,
    name                      varchar,
    description               varchar,
    parent_terms_ref_id       integer,
    term_sets_json            varchar                                        not null,
    wtime                     timestamp default timezone('utc'::text, now()) not null,
    current                   boolean   default true                         not null
);

alter table dw.term_set_hierarchy
    owner to postgres;

create index if not exists term_set_hierarchy_idx
    on dw.term_set_hierarchy (term_set_hierarchy_ref_id);

create index if not exists term_set_hierarchy_version_id
    on dw.term_set_hierarchy (version_id);

create table if not exists dw.terminal
(
    id                       bigserial
        primary key,
    version_id               bigint                                         not null,
    terminal_ref_id          integer                                        not null,
    name                     varchar                                        not null,
    description              varchar                                        not null,
    risk_coverage            varchar,
    terms_json               varchar,
    wtime                    timestamp default timezone('utc'::text, now()) not null,
    current                  boolean   default true                         not null,
    external_terminal_id     varchar,
    external_merchant_id     varchar,
    mcc                      varchar,
    terminal_provider_ref_id integer
);

alter table dw.terminal
    owner to postgres;

create index if not exists terminal_idx
    on dw.terminal (terminal_ref_id);

create index if not exists terminal_version_id
    on dw.terminal (version_id);

create table if not exists dw.trade_bloc
(
    id                bigserial
        primary key,
    version_id        bigint                                         not null,
    trade_bloc_ref_id varchar                                        not null,
    name              varchar                                        not null,
    description       varchar,
    wtime             timestamp default timezone('utc'::text, now()) not null,
    current           boolean   default true                         not null
);

alter table dw.trade_bloc
    owner to postgres;

create table if not exists dw.wallet
(
    id                   bigserial
        primary key,
    event_created_at     timestamp                                      not null,
    event_occured_at     timestamp                                      not null,
    sequence_id          integer                                        not null,
    wallet_id            varchar                                        not null,
    wallet_name          varchar                                        not null,
    identity_id          varchar,
    party_id             varchar,
    currency_code        varchar,
    wtime                timestamp default timezone('utc'::text, now()) not null,
    current              boolean   default true                         not null,
    account_id           varchar,
    accounter_account_id bigint,
    external_id          varchar,
    constraint wallet_uniq
        unique (wallet_id, sequence_id)
);

alter table dw.wallet
    owner to postgres;

create index if not exists wallet_event_created_at_idx
    on dw.wallet (event_created_at);

create index if not exists wallet_event_occured_at_idx
    on dw.wallet (event_occured_at);

create index if not exists wallet_id_idx
    on dw.wallet (wallet_id);

create table if not exists dw.withdrawal
(
    id                                    bigserial
        primary key,
    event_created_at                      timestamp                                      not null,
    event_occured_at                      timestamp                                      not null,
    sequence_id                           integer                                        not null,
    wallet_id                             varchar                                        not null,
    destination_id                        varchar                                        not null,
    withdrawal_id                         varchar                                        not null,
    provider_id_legacy                    varchar,
    amount                                bigint                                         not null,
    currency_code                         varchar                                        not null,
    withdrawal_status                     dw.withdrawal_status                           not null,
    withdrawal_transfer_status            dw.withdrawal_transfer_status,
    wtime                                 timestamp default timezone('utc'::text, now()) not null,
    current                               boolean   default true                         not null,
    fee                                   bigint,
    provider_fee                          bigint,
    external_id                           varchar,
    context_json                          varchar,
    withdrawal_status_failed_failure_json varchar,
    provider_id                           integer,
    terminal_id                           varchar,
    constraint withdrawal_uniq
        unique (withdrawal_id, sequence_id)
);

alter table dw.withdrawal
    owner to postgres;

create index if not exists withdrawal_event_created_at_idx
    on dw.withdrawal (event_created_at);

create index if not exists withdrawal_event_occured_at_idx
    on dw.withdrawal (event_occured_at);

create index if not exists withdrawal_id_idx
    on dw.withdrawal (withdrawal_id);

create table if not exists dw.withdrawal_provider
(
    id                         bigserial
        primary key,
    version_id                 bigint                                         not null,
    withdrawal_provider_ref_id integer                                        not null,
    name                       varchar                                        not null,
    description                varchar,
    proxy_ref_id               integer                                        not null,
    identity                   varchar,
    withdrawal_terms_json      varchar,
    accounts_json              varchar,
    wtime                      timestamp default timezone('utc'::text, now()) not null,
    current                    boolean   default true                         not null
);

alter table dw.withdrawal_provider
    owner to postgres;

create index if not exists withdrawal_provider_idx
    on dw.withdrawal_provider (withdrawal_provider_ref_id);

create index if not exists withdrawal_provider_version_id
    on dw.withdrawal_provider (version_id);

create table if not exists dw.withdrawal_session
(
    id                                bigserial
        constraint withdrawal_session_pk
            primary key,
    event_created_at                  timestamp                                      not null,
    event_occured_at                  timestamp                                      not null,
    sequence_id                       integer                                        not null,
    withdrawal_session_id             varchar                                        not null,
    withdrawal_session_status         dw.withdrawal_session_status                   not null,
    provider_id_legacy                varchar,
    withdrawal_id                     varchar                                        not null,
    destination_card_token            varchar,
    destination_card_payment_system   varchar,
    destination_card_bin              varchar,
    destination_card_masked_pan       varchar,
    amount                            bigint                                         not null,
    currency_code                     varchar                                        not null,
    sender_party_id                   varchar,
    sender_provider_id                varchar,
    sender_class_id                   varchar,
    sender_contract_id                varchar,
    receiver_party_id                 varchar,
    receiver_provider_id              varchar,
    receiver_class_id                 varchar,
    receiver_contract_id              varchar,
    adapter_state                     varchar,
    tran_info_id                      varchar,
    tran_info_timestamp               timestamp,
    tran_info_json                    varchar,
    wtime                             timestamp default timezone('utc'::text, now()) not null,
    current                           boolean   default true                         not null,
    failure_json                      varchar,
    resource_type                     dw.destination_resource_type                   not null,
    resource_crypto_wallet_id         varchar,
    resource_crypto_wallet_type       varchar,
    resource_crypto_wallet_data       varchar,
    resource_bank_card_type           varchar,
    resource_bank_card_issuer_country varchar,
    resource_bank_card_bank_name      varchar,
    tran_additional_info              varchar,
    tran_additional_info_rrn          varchar,
    tran_additional_info_json         varchar,
    provider_id                       integer,
    resource_digital_wallet_id        varchar,
    resource_digital_wallet_data      varchar,
    constraint withdrawal_session_uniq
        unique (withdrawal_session_id, sequence_id)
);

alter table dw.withdrawal_session
    owner to postgres;

create index if not exists withdrawal_session_event_created_at_idx
    on dw.withdrawal_session (event_created_at);

create index if not exists withdrawal_session_event_occured_at_idx
    on dw.withdrawal_session (event_occured_at);

create index if not exists withdrawal_session_id_idx
    on dw.withdrawal_session (withdrawal_session_id);

create table if not exists dw.limit_config
(
    id                                         bigserial
        constraint limit_config_id_pkey
            primary key,
    source_id                                  varchar                                        not null,
    sequence_id                                integer                                        not null,
    event_occured_at                           timestamp                                      not null,
    event_created_at                           timestamp                                      not null,
    limit_config_id                            varchar                                        not null,
    processor_type                             varchar                                        not null,
    created_at                                 timestamp                                      not null,
    started_at                                 timestamp                                      not null,
    shard_size                                 bigint                                         not null,
    time_range_type                            dw.limit_config_time_range_type                not null,
    time_range_type_calendar                   dw.limit_config_time_range_type_calendar,
    time_range_type_interval_amount            bigint,
    limit_context_type                         dw.limit_config_limit_context_type             not null,
    limit_type_turnover_metric                 dw.limit_config_limit_type_turnover_metric,
    limit_type_turnover_metric_amount_currency varchar,
    limit_scope                                dw.limit_config_limit_scope,
    limit_scope_types_json                     text,
    description                                varchar,
    operation_limit_behaviour                  dw.limit_config_operation_limit_behaviour,
    wtime                                      timestamp default timezone('utc'::text, now()) not null,
    current                                    boolean   default true                         not null,
    constraint limit_config_limit_config_id_ukey
        unique (limit_config_id, sequence_id)
);

alter table dw.limit_config
    owner to postgres;

create table if not exists dw.ex_rate
(
    id                                 bigserial,
    event_id                           uuid      not null
        unique,
    event_created_at                   timestamp not null,
    source_currency_symbolic_code      varchar   not null,
    source_currency_exponent           smallint  not null,
    destination_currency_symbolic_code varchar   not null,
    destination_currency_exponent      smallint  not null,
    rational_p                         bigint    not null,
    rational_q                         bigint    not null,
    rate_timestamp                     timestamp not null
);

alter table dw.ex_rate
    owner to postgres;

create index if not exists rate_timestamp_idx
    on dw.ex_rate (rate_timestamp);

create index if not exists source_currency_sc_destination_currency_sc_timestamp_idx
    on dw.ex_rate (source_currency_symbolic_code, destination_currency_symbolic_code, rate_timestamp);

create table if not exists dw.dominant_last_version_id
(
    version_id bigint                                         not null,
    wtime      timestamp default timezone('utc'::text, now()) not null
);

alter table dw.dominant_last_version_id
    owner to postgres;
