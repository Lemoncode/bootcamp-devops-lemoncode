
exports.up = function(knex) {
  return knex.schema.table('todos', (t) => {
      t.datetime('due_date');
      t.integer('order');
  });
};

exports.down = function(knex) {
    return knex.schema.table('todos', (t) => {
        t.dropColumn('due_date');
        t.dropColumn('order');
    });
};
