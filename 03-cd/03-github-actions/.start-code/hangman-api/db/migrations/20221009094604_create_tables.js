/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function (knex) {
    return knex.schema
        .createTable('players', function (table) {
            table.increments();
            table.string('name').notNullable();
            table.timestamp('created_at').defaultTo(knex.fn.now());
            table.timestamp('updated_at').defaultTo(knex.fn.now());
        })
        .createTable('words', function (table) {
            table.increments();
            table.string('entry').notNullable();
            table.enu('word_category', ['clothes', 'sports', 'vehicles'], { useNative: true, enumName: 'category' });
            table.timestamp('created_at').defaultTo(knex.fn.now());
            table.timestamp('updated_at').defaultTo(knex.fn.now());
        })
        .createTable('games', function (table) {
            table.increments();
            table.integer('player_id').references('id').inTable('players');
            table.integer('word_id').references('id').inTable('words');
            table.enu('game_state', ['not_started', 'started', 'finished'], { useNative: true, enumName: 'progress' });
            table.timestamp('created_at').defaultTo(knex.fn.now());
            table.timestamp('updated_at').defaultTo(knex.fn.now());
        });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function (knex) {

};
