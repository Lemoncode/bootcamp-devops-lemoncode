
exports.seed = function(knex) {
  // Deletes ALL existing entries
  return knex('todos').delete()
    .then(function () {
      // Inserts seed entries
      return knex('todos').insert([
        { title: 'Learn GitHub Actions', completed: false},
        { title: 'Learn Groovy', completed: false},
        { title: 'Learn EKS', completed: false}
      ]);
    });
};
