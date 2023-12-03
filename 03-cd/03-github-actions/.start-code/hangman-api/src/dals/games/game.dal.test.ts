import { Knex } from 'knex';
import { getDbReference, closeConnection, startConnection } from '../database-manager';
import { gameDALFactory } from './game.dal';
import { playerDALFactory } from '../players/player.dal';
import { wordDALFactory } from '../words/word.dal';

let db: Knex;

beforeAll(() => {
  startConnection();
  db = getDbReference();
});

afterAll(async () => {
  await closeConnection();
});

beforeEach(async () => {
  await db.from('games').delete();
  await db.from('players').delete();
  await db.from('words').delete();
});

describe('game.dal', () => {
  describe('getGames', () => {
    test('returns the games related to a player', async () => {
      // Arrange
      const playersDAL = playerDALFactory(db);
      const wordsDAL = wordDALFactory(db);
      const gamesDAL = gameDALFactory(db);

      await Promise.all([
        playersDAL.addPlayer({ name: 'joe', id: 1 }),
        wordsDAL.addWord({ id: 1, entry: 'car', word_category: 'vehicles' }),
      ]);
      await gamesDAL.addGame({ game_state: 'not_started', player_id: 1, word_id: 1 });
      
      // Act 
      const [game] = await gamesDAL.getGames(1);
      const { game_state, player_id, word_id } = game;

      // Assert
      expect(player_id).toBe(1);
      expect(word_id).toBe(1);
      expect(game_state).toBe('not_started');
    });
  });
});
