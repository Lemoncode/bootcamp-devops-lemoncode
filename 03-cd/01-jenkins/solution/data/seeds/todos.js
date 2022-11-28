
exports.seed = function(knex) {
    // Deletes ALL existing entries
    return knex('todos').truncate()
      .then(function () {
        // Inserts seed entries
        return knex('todos').insert([
          {id: 1, title: 'Learn GitHub Actions', completed: false},
          {id: 2, title: 'Learn Groovy', completed: false},
          {id: 3, title: 'Learn EKS', completed: false}
        ]);
      });
  };
  