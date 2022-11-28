

exports.up = function(knex) {
    return knex.schema.createTable('todos', function(table) {
        table.increments('id');
        table.string('title', 255).notNullable();
        table.boolean('completed').notNullable();
    });
};

exports.down = function(knex) {
    return knex.schema.dropTable('users');
};

